import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cosntants/firestore_key.dart';


class DonaPostModel {
  final String donaId;
  final String userId;
  final String title;
  final String img;
  final String category;
  final String body;
  final DateTime createdAt;
  final int viewCount;
  final String color;
  final String material;
  final String condition;
  final DocumentReference reference;

  // Named constructor for creating an instance from a map
  DonaPostModel.fromMap(Map<String, dynamic> map, this.donaId,
      {required this.reference})
      : title = map[KEY_DONATITLE] ?? '',
        userId = map[KEY_DONA_USERKEY] ?? '',
        img = map[KEY_DONAIMG] ?? '',
        category = map[KEY_DONACATEGORY] ?? '',
        body = map[KEY_DONABODY] ?? '',
        color = map[KEY_DONACOLOR] ?? '',
        material = map[KEY_DONAMATERIAL] ?? '',
        condition = map[KEY_DONACONDITION] ?? '',
        createdAt = (map[KEY_DONA_CREATED_AT] as Timestamp?)?.toDate() ??
            DateTime.now(), // 서버 타임스탬프를 DateTime으로 변환
        viewCount = map[KEY_DONA_VIEW_COUNT] ?? 0; // 기본 조회수는 0

  // Named constructor for creating an instance from a Firestore snapshot
  DonaPostModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id,
      reference: snapshot.reference);
}
