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
        title: Text('사업자 등록된 마켓의 상품', style: TextStyle(fontFamily: 'NanumSquare')),
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

          return GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 한 줄에 3개
              childAspectRatio: 0.65, // 카드 비율 조정
              crossAxisSpacing: 8.0, // 열 간격
              mainAxisSpacing: 8.0, // 행 간격
            ),
            itemCount: sellPosts.length,
            itemBuilder: (context, index) {
              final post = sellPosts[index];
              final String firstImageUrl =
              post.img.isNotEmpty ? post.img[0] : 'https://via.placeholder.com/100';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedDetail(sellPost: post),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0), // 이미지의 둥글기
                      child: Container(
                        height: 100, // 이미지 높이 설정
                        width: double.infinity, // 이미지가 카드 너비를 차지하도록 설정
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(firstImageUrl),
                            fit: BoxFit.cover, // 이미지 비율 유지
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // 간격 조정
                      child: Text(
                        post.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[900], // 특정 회색으로 변경
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // 가격과의 간격 조정
                      child: Text(
                        '${post.price}원', // 가격 표시
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // 가격 글씨 크기 조정
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
