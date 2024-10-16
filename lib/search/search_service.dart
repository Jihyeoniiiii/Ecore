import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveSearchTerm(String term) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return; // 로그인하지 않은 경우
    }

    // 최근 검색어 저장
    final searchRef = _firestore.collection('Users').doc(userId).collection('RecentSearches');
    await searchRef.add({
      'term': term,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 인기 검색어 저장 (빈도 업데이트)
    final popularSearchRef = _firestore.collection('PopularSearches').doc(term);
    final popularSearchDoc = await popularSearchRef.get();

    if (popularSearchDoc.exists) {
      // 이미 있는 검색어이면 사용 빈도 업데이트
      await popularSearchRef.update({
        'count': FieldValue.increment(1),
      });
    } else {
      // 처음 추가하는 검색어일 경우
      await popularSearchRef.set({
        'term': term,
        'count': 1,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<List<String>> getRecentSearches() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return []; // 로그인하지 않은 경우
    }

    final searchRef = _firestore.collection('Users').doc(userId).collection('RecentSearches');
    final querySnapshot = await searchRef.orderBy('timestamp', descending: true).limit(10).get();
    return querySnapshot.docs.map((doc) => doc['term'] as String).toList();
  }

  // 인기 검색어 가져오기 (검색 빈도 높은 순)
  Future<List<Map<String, dynamic>>> getPopularSearches() async {
    final querySnapshot = await _firestore.collection('PopularSearches').orderBy('count', descending: true).limit(10).get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
