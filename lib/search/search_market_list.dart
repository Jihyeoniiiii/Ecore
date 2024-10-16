import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/market_model.dart';
import 'market_detail.dart';

Widget SearchMarketList(Map<String, dynamic> result, BuildContext context) {
  final docId = result['id'];
  if (docId == null || docId.isEmpty) {
    print('Document ID is null or empty');
    return Container(); // ID가 없는 경우 빈 컨테이너를 반환
  }

  return InkWell(
    onTap: () async {
      final DocumentSnapshot marketSnapshot = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(docId)
          .get();

      if (marketSnapshot.exists) {
        final market = MarketModel.fromSnapshot(marketSnapshot);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarketDetail(market: market),
          ),
        );
      } else {
        print('Market does not exist');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('해당 마켓을 찾을 수 없습니다.')),
        );
      }
    },
    child: ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(result['img'] ?? 'https://via.placeholder.com/100'),
      ),
      title: Text(result['name'] ?? 'No Name'),
      subtitle: Text(result['description'] ?? 'No Description'),
    ),
  );
}
