import 'package:flutter/material.dart';
import 'package:ecore/models/firestore/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModelState extends ChangeNotifier {
  // Private field to hold the chat model
  ChatModel? _chatModel;

  // Public getter to access the chat model
  ChatModel get chatModel => _chatModel!;

  // Public setter to update the chat model and notify listeners
  set chatModel(ChatModel chatModel) {
    _chatModel = chatModel;
    notifyListeners();
  }

  // Method to update the chat model from a new snapshot
  void updateChatModelFromSnapshot(DocumentSnapshot snapshot) {
    _chatModel = ChatModel.fromSnapshot(snapshot);
    notifyListeners();
  }

}
