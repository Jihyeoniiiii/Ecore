import 'package:ecore/cosntants/common_color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cosntants/firestore_key.dart';
import '../models/firestore/chat_model.dart';

class SelectChatRoom extends StatefulWidget {
  final String otherUserId;
  final String chatId;

  const SelectChatRoom({Key? key, required this.otherUserId, required this.chatId}) : super(key: key);

  @override
  _SelectChatRoomState createState() => _SelectChatRoomState();
}

class _SelectChatRoomState extends State<SelectChatRoom> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  User? loggedInUser;
  final Map<String, String> _usernameCache = {};
  String? userMarketId;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
        userMarketId = await _getMarketIdForUser(user.uid);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> _getUsernameOrMarketName(String userId) async {
    if (_usernameCache.containsKey(userId)) {
      return _usernameCache[userId]!;
    }

    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (userDoc.exists) {
      final username = userDoc.data()?[KEY_USERNAME] ?? 'Unknown';
      _usernameCache[userId] = username;
      return username;
    }

    final marketDoc = await FirebaseFirestore.instance.collection('Markets').doc(userId).get();
    if (marketDoc.exists) {
      final marketName = marketDoc.data()?[KEY_MARKET_NAME] ?? 'Unknown';
      _usernameCache[userId] = marketName;
      return marketName;
    }

    return 'Unknown';
  }

  Future<String?> _getMarketIdForUser(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Markets')
          .where(KEY_MARKET_USERKEY, isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final marketId = querySnapshot.docs.first.id;
        return marketId;
      } else {
        print('No market found for user: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching market ID: $e');
      return null;
    }
  }

  Future<bool> checkChatRoomUsers(String chatId, String userId) async {
    try {
      final chatDoc = await FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .doc(chatId)
          .get();

      if (!chatDoc.exists) {
        print('Chat room not found');
        return false;
      }

      List<dynamic> users = chatDoc['users'];

      final marketId = await _getMarketIdForUser(userId);

      if (users.contains(userId) || (marketId != null && users.contains(marketId))) {
        return true;
      } else {
        print('User or Market not part of this chat room');
        return false;
      }
    } catch (e) {
      print('Error checking chat room users: $e');
      return false;
    }
  }

  void _sendMessage(String text) async {
    if (loggedInUser == null || text.isEmpty) return;

    try {
      final userMarketId = await _getMarketIdForUser(loggedInUser!.uid);

      final chatQuerySnapshot = await FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where('users', arrayContainsAny: [loggedInUser!.uid, userMarketId, widget.otherUserId])
          .get();

      final filteredChats = chatQuerySnapshot.docs.where((doc) {
        final users = List<String>.from(doc['users']);
        return (users.contains(loggedInUser!.uid) || (userMarketId != null && users.contains(userMarketId)))
            && users.contains(widget.otherUserId);
      }).toList();

      if (filteredChats.isEmpty) {
        print('No chat room found between users.');
        return;
      }

      final chatId = filteredChats.first.id;

      String sendId = loggedInUser!.uid;
      if (userMarketId != null && (await checkChatRoomUsers(chatId, userMarketId))) {
        sendId = userMarketId;
      } else if (!(await checkChatRoomUsers(chatId, sendId))) {
        print('User not part of this chat room');
        return;
      }

      final messageRef = FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .doc(chatId)
          .collection(COLLECTION_MESSAGES)
          .doc();

      final newMessage = {
        KEY_MESSAGE: messageRef.id,
        KEY_TEXT: text,
        KEY_SEND_USERID: sendId,
        KEY_RECEIVE_USERID: widget.otherUserId,
        KEY_READBY: [sendId],
        KEY_DATE: FieldValue.serverTimestamp(),
      };

      await messageRef.set(newMessage);

      _controller.clear();
      _scrollToBottom();

    } catch (e) {
      print('Error while sending message: $e');
    }
  }

  Stream<List<ChatModel>> _fetchMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('Messages')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<Map<String, dynamic>> _fetchProductInfo(String chatId) async {
    DocumentSnapshot chatSnapshot = await FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .doc(chatId)
        .get();

    if (chatSnapshot.exists) {
      Map<String, dynamic>? data = chatSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('sellId')) {
        String sellId = data['sellId'];

        DocumentSnapshot sellPostSnapshot = await FirebaseFirestore.instance
            .collection(COLLECTION_SELL_PRODUCTS)
            .doc(sellId)
            .get();

        if (sellPostSnapshot.exists) {
          return sellPostSnapshot.data() as Map<String, dynamic>? ?? {};
        } else {
          throw Exception('Product not found');
        }
      } else {
        throw Exception('sellId not found in chat document');
      }
    } else {
      throw Exception('Chat document not found');
    }
  }

  Future<String?> _getOtherUserId(String chatId) async {
    final chatDoc = await FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .get();

    final data = chatDoc.data();
    if (data != null) {
      List<dynamic> users = data['users'];
      // 현재 사용자의 ID와 마켓 ID를 제외하고 상대방의 ID만 추출
      return users.firstWhere(
            (userId) => userId != loggedInUser!.uid && userId != userMarketId,
        orElse: () => null,
      );
    }

    return null;
  }

  Future<Map<String, String>> _getOtherUserProfileImage(String chatId) async {
    final otherUserId = await _getOtherUserId(chatId);
    if (otherUserId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(otherUserId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final profileImageUrl = data?['profile_img'] ?? '';
        return {
          'profile_img': profileImageUrl,
        };
      }
    }

    return {
      'profile_img': '', // 기본 이미지 URL 또는 빈 값
    };
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        _scrollController.animateTo(
          maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if (loggedInUser == null) {
      return Scaffold(
        body: Center(child: Text('유저가 존재하지 않습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _getUsernameOrMarketName(widget.otherUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Text('Error');
            } else {
              return Text(
                '${snapshot.data}',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'NanumSquare',
                ),
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _fetchProductInfo(widget.chatId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // 로딩 중일 때 표시할 위젯
              }

              if (snapshot.hasError) {
                return Text('Error loading product');
              }

              final productData = snapshot.data ?? {};
              final imageUrl = productData['img'][0] ?? 'https://via.placeholder.com/150'; // 이미지 URL
              final title = productData['title'] ?? '상품 제목 없음'; // 상품 제목
              final price = productData['price'] ?? 0; // 상품 가격

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Card(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                'https://via.placeholder.com/150',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 20),
                        // 상품 제목과 가격
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${price}원',
                              style: TextStyle(
                                fontSize: 14,
                                color: iconColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(  // 채팅 메시지 리스트를 제한된 공간 안에 넣기
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: StreamBuilder<List<ChatModel>>(
                stream: _fetchMessages(widget.chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No messages found'));
                  }

                  final allMessages = snapshot.data!;

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: allMessages.length,
                    itemBuilder: (ctx, index) {
                      final chat = allMessages[index];
                      bool isMe = chat.sendId != widget.otherUserId;

                      return FutureBuilder<Map<String, String>>(
                          future: _getOtherUserProfileImage(widget.chatId),
                          // chatId에 해당하는 상대방 이미지 가져오기
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (userSnapshot.hasError ||
                                !userSnapshot.hasData) {
                              return Text('Error loading user data');
                            }

                            final profileImageUrl = userSnapshot
                                .data?['profile_img'] ??
                                'https://via.placeholder.com/150';

                            return Row(
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10.0, bottom: 13.0),
                                  child: !isMe
                                      ? CircleAvatar(
                                    backgroundImage: profileImageUrl.isNotEmpty
                                        ? NetworkImage(
                                        profileImageUrl) as ImageProvider
                                        : AssetImage(
                                        'assets/images/default_profile.jpg'),
                                    radius: 20,
                                  )
                                      : SizedBox.shrink(),
                                ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                margin: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isMe ? iconColor : Colors.grey[200],
                                  borderRadius: isMe
                                      ? BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    bottomRight: Radius.circular(14),
                                    bottomLeft: Radius.circular(14),
                                  )
                                      : BorderRadius.only(
                                    topRight: Radius.circular(14),
                                    bottomLeft: Radius.circular(14),
                                    bottomRight: Radius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  chat.text,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ]);
                          }
                      );
                    }
                  );
                },
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '메시지를 입력해주세요.',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.0),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor,
              ),
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  final message = _controller.text.trim();
                  if (message.isNotEmpty) {
                    _sendMessage(message);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
