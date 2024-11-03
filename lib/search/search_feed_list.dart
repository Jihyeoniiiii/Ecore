import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../donation_page/dona_detail.dart';
import '../home_page/feed_detail.dart';
import '../models/firestore/dona_post_model.dart';
import '../models/firestore/sell_post_model.dart';
import '../widgets/price_display.dart';

Widget SearchFeedList(Map<String, dynamic> result, bool _isDonationSearch, BuildContext context) {
  // Use the first image in the list or a placeholder
  final imageUrl = (result['img'] != null && result['img'].isNotEmpty)
      ? result['img'][0].toString()
      : 'https://via.placeholder.com/100';

  return InkWell(
    onTap: () {
      final docId = result['id'];
      if (docId == null || docId.isEmpty) {
        print('Document ID is null or empty');
        return;
      }

      if (_isDonationSearch) {
        final donaPostReference = FirebaseFirestore.instance.collection('DonaPosts').doc(docId);
        final donaPost = DonaPostModel.fromMap(result, '', reference: donaPostReference);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonaDetail(donaPost: donaPost),
          ),
        );
      } else {
        final sellPostReference = FirebaseFirestore.instance.collection('SellPosts').doc(docId);
        final sellPost = SellPostModel.fromMap(result, '', reference: sellPostReference);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedDetail(sellPost: sellPost),
          ),
        );
      }
    },
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: ClipRRect( // 모서리 둥글게 만들기
            borderRadius: BorderRadius.circular(10), // 원하는 둥글기 설정
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result['title'] ?? 'No Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              if (!_isDonationSearch)
                  PriceDisplay(price: result['price'].toInt(),fontSize: 18),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'report') {
              // 신고 처리 로직
            } else if (value == 'hide') {
              // 숨기기 처리 로직
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: 'report',
                child: Text('신고'),
              ),
              PopupMenuItem(
                value: 'hide',
                child: Text('숨기기'),
              ),
            ];
          },
        ),
      ],
    ),
  );
}
