import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication 임포트
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 임포트
import '../home_page/feed_detail.dart';
import '../models/firestore/user_model.dart';
import '../models/firestore/sell_post_model.dart';
import '../widgets/sold_out.dart'; // SoldOutOverlay 위젯 임포트

class FavoriteListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 설정
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경색 설정
        title: Text('찜한 상품', style: TextStyle(fontFamily: 'NanumSquare',)), // 제목 설정
      ),
      body: Consumer<UserModel>(
        builder: (context, userModel, child) {
          return StreamBuilder<List<SellPostModel>>(
            stream: userModel.favoriteListStream, // FavoriteList 스트림 가져오기
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final favoritePosts = snapshot.data ?? []; // 찜 목록 데이터

              if (favoritePosts.isEmpty) {
                return Center(child: Text('찜 한 상품이 없습니다.')); // 찜 목록이 비었을 때 메시지
              }

              return GridView.builder(
                padding: EdgeInsets.all(8.0), // 그리드의 패딩 설정
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 한 줄에 3개
                  childAspectRatio: 0.65, // 카드 비율 조정
                  crossAxisSpacing: 8.0, // 열 간격
                  mainAxisSpacing: 8.0, // 행 간격
                ),
                itemCount: favoritePosts.length,
                itemBuilder: (context, index) {
                  final post = favoritePosts[index];
                  final String firstImageUrl = post.img.isNotEmpty ? post.img[0] : 'https://via.placeholder.com/100';

                  return Stack(
                    children: [
                      GestureDetector(
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
                                  borderRadius: BorderRadius.circular(10.0), // 이미지의 둥글기
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
                                SoldOutOverlay(
                                  isSoldOut: post.stock == 0,
                                  radius: 30, // 원하는 크기로 radius 조정 가능
                                  borderRadius: 10.0,
                                ),
                              ],
                            ),
                            // 이미지와 제목 간의 간격을 늘리기 위해 vertical 패딩을 조정
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // 간격 조정
                              child: Text(
                                post.title, // 제목
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold, // 제목 강조
                                  color: Colors.grey[900],
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
                                  return Text('로딩 중...');
                                }
                                if (marketSnapshot.hasError) {
                                  return Text('에러 발생');
                                }
                                if (!marketSnapshot.hasData || !marketSnapshot.data!.exists) {
                                  return Text('마켓 없음');
                                }

                                final marketName = marketSnapshot.data!['name']; // name 필드 가져오기

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // 간격 조정
                                  child: Text(
                                    marketName, // Firestore에서 가져온 마켓 이름 표시
                                    style: TextStyle(fontSize: 14, color: Colors.black54), // 스타일 조정 가능
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '${post.price}원', // 가격
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: -5,
                        top: -5, // 더 위쪽으로 조정
                        child: IconButton(
                          icon: Icon(
                            // 하트 아이콘 상태
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              final favoriteRef = FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user.uid)
                                  .collection('FavoriteList')
                                  .doc(post.sellId);

                              // 찜 목록에서 제거
                              await favoriteRef.delete();
                            }
                          },
                        ),
                      ),
                    ],
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
