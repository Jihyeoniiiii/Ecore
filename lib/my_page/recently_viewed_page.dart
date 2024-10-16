import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 임포트
import '../home_page/feed_detail.dart';
import '../models/firestore/user_model.dart';
import '../models/firestore/sell_post_model.dart';
import '../widgets/sold_out.dart'; // SoldOutOverlay 위젯 임포트

class RecentViewedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('최근 본 상품', style: TextStyle(fontFamily: 'NanumSquare',)),
      ),
      body: Consumer<UserModel>(
        builder: (context, userModel, child) {
          return StreamBuilder<List<SellPostModel>>(
            stream: userModel.recentlyViewedStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final recentlyViewedPosts = snapshot.data ?? [];

              if (recentlyViewedPosts.isEmpty) {
                return Center(child: Text('최근 본 상품이 없습니다.'));
              }

              return GridView.builder(
                padding: EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 한 줄에 3개
                  childAspectRatio: 0.65, // 카드 비율 조정
                  crossAxisSpacing: 8.0, // 열 간격
                  mainAxisSpacing: 8.0, // 행 간격
                ),
                itemCount: recentlyViewedPosts.length,
                itemBuilder: (context, index) {
                  final post = recentlyViewedPosts[index];
                  final String firstImageUrl = post.img.isNotEmpty ? post.img[0] : 'https://via.placeholder.com/100';

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
                        Stack(
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
                            // SoldOutOverlay를 이미지 위에 겹치게 설정
                            if (post.stock == 0) // 재고가 없을 때만 표시
                              SoldOutOverlay(
                                isSoldOut: true,
                                radius: 30,
                                borderRadius: 5.0,
                              ),
                          ],
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
                        // Firestore에서 마켓 이름 가져오기
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Markets')
                              .doc(post.marketId) // post에서 marketId 가져오기
                              .snapshots(),
                          builder: (context, marketSnapshot) {
                            if (marketSnapshot.connectionState == ConnectionState.waiting) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                                child: Text('로딩 중...'),
                              );
                            }
                            if (marketSnapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                                child: Text('에러 발생'),
                              );
                            }
                            if (!marketSnapshot.hasData || !marketSnapshot.data!.exists) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                                child: Text('마켓 없음'),
                              );
                            }

                            final marketName = marketSnapshot.data!['name']; // name 필드 가져오기

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0), // 간격 조정
                              child: Text(
                                marketName, // Firestore에서 가져온 마켓 이름 표시
                                style: TextStyle(fontSize: 14, color: Colors.black54), // 스타일 조정 가능
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // 가격과의 간격 조정
                          child: Text(
                            '${post.price}원', // 가격을 상단에 배치
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // 가격 글씨 크기 조정
                          ),
                        ),
                      ],
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
