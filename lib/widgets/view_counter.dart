import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> incrementViewCount(DocumentReference documentReference) async {
  try {
    // Firestore 트랜잭션을 사용해 안전하게 조회수를 증가시킴
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // 문서의 현재 데이터를 가져옴
      DocumentSnapshot snapshot = await transaction.get(documentReference);

      if (snapshot.exists) {
        // 현재 데이터를 Map으로 캐스팅
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // 현재 조회수 가져오기
        int currentViewCount = data['viewCount'] ?? 0;

        // 조회수를 +1 증가시킴
        transaction.update(documentReference, {
          'viewCount': currentViewCount + 1,
        });
      }
    });
  } catch (e) {
    print('Failed to increment view count: $e');
  }
}
