import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/user_model.dart';

mixin Transformers {
  final toUser = StreamTransformer<DocumentSnapshot<Map<String, dynamic>>, UserModel>.fromHandlers(
      handleData: (snapshot, sink) async {
        sink.add(UserModel.fromSnapshot(snapshot));
      }
  );
}
