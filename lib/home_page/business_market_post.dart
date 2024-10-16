import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/sell_post_model.dart';
import '../home_page/feed_detail.dart';

class BusinessMarketPost extends StatelessWidget {
  // Stream을 반환하는 함수
  Stream<List<SellPostModel>> businessSellPostsStream() {
    return FirebaseFirestore.instance
        .collection('Markets')
        .where('business_number', isNotEqualTo: '')
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<SellPostModel> allSellPosts = [];
      List<Future<void>> fetchTasks = [];

      for (var marketDoc in querySnapshot.docs) {
        final marketData = marketDoc.data();
        final sellPostIds = marketData['sellPosts'] as List<dynamic>?;

        if (sellPostIds != null && sellPostIds.isNotEmpty) {
          for (var sellPostId in sellPostIds) {
            fetchTasks.add(FirebaseFirestore.instance
                .collection('SellPosts')
                .doc(sellPostId as String)
                .get()
                .then((sellPostDoc) {
              if (sellPostDoc.exists) {
                final sellPostData = sellPostDoc.data() as Map<String, dynamic>;
                final sellPost = SellPostModel.fromMap(
                    sellPostData,
                    sellPostId,
                    reference: sellPostDoc.reference
                );
                allSellPosts.add(sellPost);
              }
            }));
          }
        }
      }

      await Future.wait(fetchTasks);

      return allSellPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사업자 등록된 마켓의 상품', style: TextStyle(fontFamily: 'NanumSquare',)),
      ),
      body: StreamBuilder<List<SellPostModel>>(
        stream: businessSellPostsStream(), // 위에서 정의한 Stream 함수 호출
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final sellPosts = snapshot.data ?? [];

          if (sellPosts.isEmpty) {
            return Center(child: Text('상품이 없습니다.'));
          }

          return ListView.builder(
            itemCount: sellPosts.length,
            itemBuilder: (context, index) {
              final post = sellPosts[index];
              final String firstImageUrl =
              post.img.isNotEmpty ? post.img[0] : 'https://via.placeholder.com/100';

              return ListTile(
                leading: Image.network(
                  firstImageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text('${post.price}원'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedDetail(sellPost: post),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
