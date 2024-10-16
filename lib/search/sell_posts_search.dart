import 'package:cloud_firestore/cloud_firestore.dart';

class SellPostSearch {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> searchSellPosts(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final result = await _firestore.collection('SellPosts')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final List<Map<String, dynamic>> results = result.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,  // Include document ID in the result
          ...data,
        };
      })
          .where((data) => _matchesQuery(data['title'], query))
          .toList();
      return results;
    } catch (e) {
      print('Error searching sellposts: $e');
      return [];
    }
  }

  bool _matchesQuery(String title, String query) {
    if (title.contains(query)) {
      return true;
    }
    return false;
  }
}
