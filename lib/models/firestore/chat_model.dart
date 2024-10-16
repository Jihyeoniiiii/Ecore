import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../cosntants/firestore_key.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatModel extends ChangeNotifier{
  final String chatId;
  final String sendId;
  final String receiveId;
  final DateTime date;
  final String text;

  ChatModel({
    required this.chatId,
    required this.sendId,
    required this.receiveId,
    required this.date,
    required this.text,
  });

  // Map<String, dynamic>으로 변환
  Map<String, dynamic> toMap() {
    final map = {
      KEY_CHATID: chatId,
      KEY_SEND_USERID: sendId,
      KEY_RECEIVE_USERID: receiveId,
      KEY_DATE: Timestamp.fromDate(date),
    };
    if (text.isNotEmpty) { // `text`가 비어 있지 않을 때만 포함
      map[KEY_TEXT] = text;
    }
    return map;
  }

  // Firestore의 Map 데이터를 객체로 변환
  factory ChatModel.fromMap(Map<String, dynamic> data) {
    return ChatModel(
      chatId: data['chatId'] ?? '',
      sendId: data['sendId'] ?? '',
      receiveId: data['receiveId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      text: data['text'] ?? '',
    );
  }

  // DocumentSnapshot에서 객체 생성
  factory ChatModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return ChatModel(
      chatId: snapshot.id, // Document ID를 chatId로 사용
      sendId: data['sendId'] ?? '',
      receiveId: data['receiveId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      text: data['text'] ?? '',
    );
  }
}

Future<List<ChatModel>> getChatsByCurrentUser() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return [];
    }
    final userId = user.uid;

    final chatSnapshots = await FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where(KEY_SEND_USERID, isEqualTo: userId)
        .get();

    final receivedChatsSnapshots = await FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where(KEY_RECEIVE_USERID, isEqualTo: userId)
        .get();

    final allChatSnapshots = chatSnapshots.docs + receivedChatsSnapshots.docs;

    return allChatSnapshots.map((doc) => ChatModel.fromSnapshot(doc)).toList();
  } catch (e) {
    print('Error getting chats: $e');
    return [];
  }
}
