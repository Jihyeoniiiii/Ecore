import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cosntants/common_color.dart';
import '../cosntants/firestore_key.dart';
import '../models/firestore/chat_model.dart';

class ChatRoom extends StatefulWidget {
  final String marketId;
  final String sellId;
  const ChatRoom({Key? key, required this.marketId, required this.sellId}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String?> getChatId(String userId) async {
    final chatQuery = await FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where('users', arrayContainsAny: [userId, widget.marketId])
        .get();

    for (var doc in chatQuery.docs) {
      final data = doc.data();
      List<dynamic> users = data['users'] ?? [];

      if (users.contains(widget.marketId)) {
        return doc.id;
      }
    }

    return null;
  }


  Stream<List<ChatModel>> _fetchAllMessages() async* {
    if (loggedInUser == null) {
      yield [];
      return;
    }

    String? chatId = await getChatId(loggedInUser!.uid);
    if (chatId == null) {
      yield [];
      return;
    }

    final messagesStream = FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
        .orderBy(KEY_DATE, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>)).toList());

    yield* messagesStream;
  }


  void _sendMessage(String text) async {
    if (loggedInUser == null || text.trim().isEmpty) return;

    final receiveId = widget.marketId;
    if (receiveId == null) return;

    final List<String> userIds = [loggedInUser!.uid, receiveId];

    final chatQuery = await FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where('users', arrayContainsAny: [loggedInUser!.uid, receiveId])
        .get();

    String chatId;

    if (chatQuery.docs.isNotEmpty) {
      chatId = chatQuery.docs.first.id;
    } else {
      final chatRef = FirebaseFirestore.instance.collection(COLLECTION_CHATS).doc();
      chatId = chatRef.id;

      await chatRef.set({
        KEY_CHATID: chatId,
        KEY_CHAT_SELLID: widget.sellId,
        'users': userIds,
        KEY_DATE: FieldValue.serverTimestamp()
      });
    }

    final messageRef = FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
        .doc();

    await messageRef.set({
      KEY_MESSAGE: messageRef.id,
      KEY_TEXT: text,
      KEY_SEND_USERID: loggedInUser!.uid,
      KEY_RECEIVE_USERID: receiveId,
      KEY_READBY: [loggedInUser!.uid],
      KEY_DATE: FieldValue.serverTimestamp()
    });

    setState(() {});

    _controller.clear();
    _scrollToBottom();
  }

  Future<Map<String, String>> _getUserProfileImage(String marketId) async {
    final marketDoc = await FirebaseFirestore.instance.collection('Markets')
        .doc(marketId)
        .get();

    if (marketDoc.exists) {
      final image = marketDoc.data()?['img'] ?? '';
      return {
        'img': image,
      };
    }

    return {
      'img': '',
    };
  }

  Future<Map<String, dynamic>> _fetchProductInfo() async {
    final productDoc = await FirebaseFirestore.instance
        .collection('SellPosts') // 상품 데이터가 저장된 Firestore 컬렉션 이름
        .doc(widget.sellId)
        .get();

    if (productDoc.exists) {
      return productDoc.data() ?? {};
    } else {
      throw Exception('Product not found');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
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
      body: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _fetchProductInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // 로딩 중일 때 표시할 위젯
              }

              if (snapshot.hasError) {
                return Text('Error loading product');
              }

              final productData = snapshot.data ?? {};
              final imageUrl = productData['img'][0] ?? ''; // 이미지 URL
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
                        // 최소 너비 설정된 컨테이너
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: 100,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis, // 넘치는 텍스트 처리
                                  maxLines: 1, // 한 줄로 제한
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '${price}원',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: iconColor,
                                  ),
                                  overflow: TextOverflow.ellipsis, // 넘치는 텍스트 처리
                                  maxLines: 1, // 한 줄로 제한
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: StreamBuilder<List<ChatModel>>(
                    stream: _fetchAllMessages(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('채팅을 시작하세요!'));
                      }

                      final allMessages = snapshot.data ?? [];

                      allMessages.sort((a, b) => a.date.compareTo(b.date));

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: allMessages.length,
                        itemBuilder: (ctx, index) {
                          final chat = allMessages[index];
                          bool isMe = chat.sendId == loggedInUser!.uid;

                          return FutureBuilder<Map<String, String>>(
                              future: _getUserProfileImage(widget.marketId),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }

                                if (userSnapshot.hasError || !userSnapshot.hasData) {
                                  return Text('Error loading user data');
                                }

                                final profileImageUrl =
                                    userSnapshot.data?['profile_img'] ?? '';

                                return Row(
                                  mainAxisAlignment: isMe
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10.0, bottom: 13.0),
                                      child: !isMe
                                          ? CircleAvatar(
                                        backgroundImage: profileImageUrl.isNotEmpty
                                            ? NetworkImage(profileImageUrl)
                                            : AssetImage('assets/images/defualt_profile.jpg') as ImageProvider,
                                      )
                                          : SizedBox.shrink(),
                                    ),
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                                  ],
                                );}
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
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
            ],
          ),
    );
  }
}
