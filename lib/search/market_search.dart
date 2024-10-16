import 'package:cloud_firestore/cloud_firestore.dart';

class MarketSearch {
  Future<List<Map<String, dynamic>>> searchMarkets(String query) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Markets')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // 문서 ID를 'id' 필드로 추가
      return data;
    }).toList();
  }
}
