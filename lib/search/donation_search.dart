import 'package:cloud_firestore/cloud_firestore.dart';

class DonationSearch {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> searchDonations(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final result = await _firestore.collection('DonaPosts')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final List<Map<String, dynamic>> results = result.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((data) => _matchesQuery(data['title'], query))
          .toList();

      return results;
    } catch (e) {
      print('Error searching donations: $e');
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