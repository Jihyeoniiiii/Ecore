// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../cosntants/firestore_key.dart';
//
// class ChatRepo {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<String?> getChatReceiverId(String chatId) async {
//     try {
//       final chatDoc = await _firestore
//           .collection(COLLECTION_CHATS)
//           .doc(chatId)
//           .get();
//
//       final chatData = chatDoc.data();
//       return chatData?[KEY_RECEIVE_USERID];
//     } catch (e) {
//       print('Error fetching receiverId: $e');
//       return null;
//     }
//   }
// }
