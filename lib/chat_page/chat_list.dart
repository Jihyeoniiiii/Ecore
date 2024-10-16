import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecore/chat_page/select_chat_room.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import '../models/firestore/chat_model.dart';
import '../cosntants/firestore_key.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final StreamController<List<ChatModel>> _chatController =
      StreamController<List<ChatModel>>.broadcast();
  Map<String, Map<String, String>> _userCache = {};
  final Map<String, String> _userIdCache = {};

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _sendSubscription;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _receiveSubscription;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _marketSendSubscription;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _marketReceiveSubscription;

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  void _setupStreams() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;

    try {
      final marketId = await _getMarketIdForUser(userId);

      final userChatsQuery = FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where('users', arrayContains: userId)
          .snapshots();

      final marketChatsQuery = FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where('users', arrayContains: marketId)
          .snapshots();

      CombineLatestStream.list([userChatsQuery, marketChatsQuery])
          .listen((snapshots) {
        final userChatsSnapshot = snapshots[0];
        final marketChatsSnapshot = snapshots[1];

        List<Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>>
            messageStreams = [];

        for (var chatDoc in userChatsSnapshot.docs) {
          final chatId = chatDoc.id;

          final sentMessagesStream = FirebaseFirestore.instance
              .collection(COLLECTION_CHATS)
              .doc(chatId)
              .collection(COLLECTION_MESSAGES)
              .where(KEY_SEND_USERID, isEqualTo: userId)
              .snapshots()
              .map((snapshot) => snapshot.docs);

          final receivedMessagesStream = FirebaseFirestore.instance
              .collection(COLLECTION_CHATS)
              .doc(chatId)
              .collection(COLLECTION_MESSAGES)
              .where(KEY_RECEIVE_USERID, isEqualTo: userId)
              .snapshots()
              .map((snapshot) => snapshot.docs);

          messageStreams.add(sentMessagesStream);
          messageStreams.add(receivedMessagesStream);
        }

        for (var chatDoc in marketChatsSnapshot.docs) {
          final chatId = chatDoc.id;

          final marketSentMessagesStream = FirebaseFirestore.instance
              .collection(COLLECTION_CHATS)
              .doc(chatId)
              .collection(COLLECTION_MESSAGES)
              .where(KEY_SEND_USERID, isEqualTo: marketId)
              .snapshots()
              .map((snapshot) => snapshot.docs);

          final marketReceivedMessagesStream = FirebaseFirestore.instance
              .collection(COLLECTION_CHATS)
              .doc(chatId)
              .collection(COLLECTION_MESSAGES)
              .where(KEY_RECEIVE_USERID, isEqualTo: marketId)
              .snapshots()
              .map((snapshot) => snapshot.docs);

          messageStreams.add(marketSentMessagesStream);
          messageStreams.add(marketReceivedMessagesStream);
        }

        CombineLatestStream.list(messageStreams).listen((snapshots) {
          final allMessages = snapshots
              .expand((snapshot) =>
                  snapshot as List<QueryDocumentSnapshot<Map<String, dynamic>>>)
              .toList();

          _processChatUpdates(allMessages, allMessages, userId, marketId!);
        });
      });
    } catch (error) {
      print('Error setting up streams: $error');
    }
  }

  Future<String?> _getMarketIdForUser(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final marketId = data?['marketId'] as String?;
        return marketId;
      }
    } catch (e) {
      print('Error fetching market ID: $e');
    }

    return null;
  }

  Future<Map<String, String>> _getOrFetchUserData(String userId) async {
    if (_userIdCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    final userData = await _getUsernameAndProfileImage(userId);

    _userCache[userId] = userData;

    return userData;
  }

  Future<String?> getUserChatId(String userId, String otherUserId) async {
    try {
      final userMarketId = await _getMarketIdForUser(userId);

      final otherUserMarketId = await _getMarketIdForUser(otherUserId);

      final userCheckId = userMarketId ?? userId;

      final otherUserCheckId = otherUserMarketId ?? otherUserId;

      final userChatsSnapshot = await FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where('users',
              arrayContainsAny: [userCheckId, otherUserCheckId]).get();

      if (userChatsSnapshot.docs.isNotEmpty) {
        final chatId = userChatsSnapshot.docs.first.id;
        return chatId;
      } else {

        final newChatRef =
            FirebaseFirestore.instance.collection(COLLECTION_CHATS).doc();
        await newChatRef.set({
          'users': [userCheckId, otherUserCheckId].toList(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        return newChatRef.id;
      }
    } catch (e) {
      print('Error getting chat ID: $e');
      return null;
    }
  }

  Future<String?> getChatId(String loggedInUserId, String otherUserId) async {
    try {
      final userMarketId = await _getMarketIdForUser(loggedInUserId);

      List<String> userIdsToCheck = [loggedInUserId, otherUserId];
      if (userMarketId != null) {
        userIdsToCheck.add(userMarketId);
      }

      final chatQuerySnapshot = await FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where('users', arrayContainsAny: userIdsToCheck)
          .get();

      final filteredChats = chatQuerySnapshot.docs.where((doc) {
        final users = List<String>.from(doc['users']);
        return (users.contains(loggedInUserId) ||
                (userMarketId != null && users.contains(userMarketId))) &&
            users.contains(otherUserId);
      }).toList();

      if (filteredChats.isEmpty) {
        print('No chat room found between users.');
        return null;
      }

      return filteredChats.first.id;
    } catch (e) {
      print('Error getting chatId: $e');
      return null;
    }
  }

  Future<int> getUnreadMessageCountForChat(String chatId, String userId) async {
    try {
      final messagesRef = FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .doc(chatId)
          .collection(COLLECTION_MESSAGES);

      final allMessagesSnapshot = await messagesRef.get();

      final unreadMessages = allMessagesSnapshot.docs.where((doc) {
        final data = doc.data();
        final List<dynamic> readBy = data[KEY_READBY] ?? [];
        return !readBy.contains(userId);
      }).toList();

      return unreadMessages.length;
    } catch (e) {
      print('Error getting unread messages: $e');
      return 0;
    }
  }

  Future<void> markMessageAsRead(
      String chatId, String messageId, String currentUserId, String userMarketId) async {
    try {
      final messageRef = FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .doc(chatId)
          .collection(COLLECTION_MESSAGES)
          .doc(messageId);

      // 현재 유저의 UID와 마켓 아이디를 모두 읽음 처리에 추가
      await messageRef.update({
        KEY_READBY: FieldValue.arrayUnion([currentUserId, userMarketId])
      });

    } catch (e) {
      print('Error marking message as read: $e');
    }
  }


  void _processChatUpdates(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userMessages,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> marketMessages,
      String userId,
      String marketId) async {
    try {
      List<ChatModel> allChats = [
        ...userMessages.map((doc) => ChatModel.fromSnapshot(doc)),
        ...marketMessages.map((doc) => ChatModel.fromSnapshot(doc)),
      ];

      Map<String, ChatModel> recentChatsMap = {};
      for (var chat in allChats) {
        if (chat.sendId == marketId && chat.receiveId == marketId) {
          continue;
        }

        final otherUserId = chat.sendId == userId || chat.sendId == marketId
            ? chat.receiveId
            : chat.sendId;

        if (!_userIdCache.containsKey(chat.chatId)) {
          _userIdCache[chat.chatId] = otherUserId;
        }

        if (!recentChatsMap.containsKey(otherUserId) ||
            chat.date.isAfter(recentChatsMap[otherUserId]!.date)) {
          recentChatsMap[otherUserId] = chat;
        }
      }

      List<ChatModel> recentChats = recentChatsMap.values.toList();
      recentChats.sort((a, b) => b.date.compareTo(a.date));

      _chatController.add(recentChats);
    } catch (e) {
      print('Error processing chats: $e');
    }
  }

  Future<Map<String, String>> _getUsernameAndProfileImage(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (userDoc.exists) {
      final username = userDoc.data()?['username'] ?? 'Unknown';
      final profileImage = userDoc.data()?['profile_img'] ?? '';
      return {
        'username': username,
        'profile_img': profileImage,
      };
    }

    final marketDoc = await FirebaseFirestore.instance
        .collection('Markets')
        .doc(userId)
        .get();

    if (marketDoc.exists) {
      final marketName = marketDoc.data()?['name'] ?? 'Unknown';
      return {
        'username': marketName,
        'profile_img': '',
      };
    }

    return {
      'username': 'Unknown',
      'profile_img': '',
    };
  }

  Future<String?> getChatIdFromMessage(String messageId) async {
    try {
      final messageSnapshot = await FirebaseFirestore.instance
          .collectionGroup(COLLECTION_MESSAGES)
          .where('messageId', isEqualTo: messageId)
          .get();

      if (messageSnapshot.docs.isNotEmpty) {
        final chatId = messageSnapshot.docs.first.reference.parent.parent!.id;
        return chatId;
      } else {
        print("해당 메시지를 포함하는 채팅방이 없습니다.");
        return null;
      }
    } catch (e) {
      print("채팅방 조회 중 에러 발생: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _sendSubscription.cancel();
    _receiveSubscription.cancel();
    _chatController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅', style: TextStyle(fontFamily: 'NanumSquare',),),
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: _chatController.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('채팅방이 없습니다.'));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading chats'));
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = _userIdCache[chat.chatId]!;

              return FutureBuilder<Map<String, String>>(
                future: _getOrFetchUserData(otherUserId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                      subtitle: Text(chat.text),
                    );
                  }

                  if (userSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error'),
                      subtitle: Text(chat.text),
                    );
                  }

                  final username = userSnapshot.data?['username'] ?? 'Unknown';
                  final profileImageUrl =
                      userSnapshot.data?['profile_img'] ?? '';
                  final user = FirebaseAuth.instance.currentUser;

                  return FutureBuilder<int>(
                    future: () async {
                      final currentUserId =
                          FirebaseAuth.instance.currentUser!.uid;
                      final userMarketId =
                          await _getMarketIdForUser(currentUserId);

                      final chatId = await getChatIdFromMessage(chat.chatId);
                      if (chatId != null) {
                        final chatDoc = await FirebaseFirestore.instance
                            .collection(COLLECTION_CHATS)
                            .doc(chatId)
                            .get();

                        final List<dynamic> users =
                            chatDoc.data()?['users'] ?? [];

                        String userId;
                        if (users.contains(userMarketId)) {
                          userId = userMarketId!;
                        } else {
                          userId = currentUserId;
                        }

                        return getUnreadMessageCountForChat(chatId, userId);
                      }
                      return 0;
                    }(),
                    builder: (context, unreadSnapshot) {
                      if (unreadSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Loading...'),
                          subtitle: Text(chat.text),
                        );
                      }

                      final unreadCount = unreadSnapshot.data ?? 0;

                      return ListTile(
                        title: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: CircleAvatar(
                                backgroundImage: profileImageUrl.isNotEmpty
                                    ? NetworkImage(profileImageUrl)
                                    : AssetImage(
                                            'assets/images/defualt_profile.jpg')
                                        as ImageProvider,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(username,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w900)),
                                Text(chat.text, style: TextStyle(fontSize: 13),),
                              ],
                            ),
                          ],
                        ),
                        trailing: Padding(
                          padding: const EdgeInsets.only(top: 7.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDate(chat.date),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              if (unreadCount > 0)
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                          onTap: () async {
                            final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                            final userMarketId = await _getMarketIdForUser(currentUserId);

                            final chatId = await getChatIdFromMessage(chat.chatId);

                            if (chatId == null) {
                              print("채팅방을 찾을 수 없습니다.");
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectChatRoom(
                                  chatId: chatId,
                                  otherUserId: otherUserId,
                                ),
                              ),
                            );

                            final messageSnapshots = await FirebaseFirestore.instance
                                .collection(COLLECTION_CHATS)
                                .doc(chatId)
                                .collection(COLLECTION_MESSAGES)
                                .get();

                            for (var messageDoc in messageSnapshots.docs) {
                              final messageId = messageDoc.id;
                              await markMessageAsRead(chatId, messageId, currentUserId, userMarketId ?? currentUserId);
                            }
                          }
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.year}-${date.month}-${date.day}';
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inHours > 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
