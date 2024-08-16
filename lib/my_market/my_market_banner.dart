import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/firestore/market_model.dart';

class MyMarketBanner extends StatefulWidget {
  final MarketModel market;

  MyMarketBanner({required this.market});

  @override
  _MyMarketBannerState createState() => _MyMarketBannerState();
}

class _MyMarketBannerState extends State<MyMarketBanner> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context); // 이전 화면으로 돌아가기
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // 검색 버튼 동작
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // 배너 이미지 영역
            Container(
              height: 200,
              color: Colors.grey,
              child: Center(
                child: Text(
                  '배너',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            // 프로필과 검색창 영역
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.market.img.isNotEmpty
                        ? NetworkImage(widget.market.img)
                        : AssetImage('assets/profile_image.jpg') as ImageProvider,
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.market.name, // 현재 market 이름을 텍스트로 표시
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.black),
                    onPressed: () {
                      // 설정 버튼 동작
                    },
                  ),
                ],
              ),
            ),
            // 탭 바
            TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: '상품'),
                Tab(text: '피드'),
                Tab(text: '리뷰'),
              ],
            ),
            // 탭 바 내용
            Expanded(
              child: TabBarView(
                children: [
                  // 상품 페이지
                  StreamBuilder<List<dynamic>>(
                    stream: widget.market.sellPostsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('오류 발생: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('상품이 없습니다.'));
                      }

                      var sellIds = snapshot.data!;

                      return FutureBuilder<List<String>>(
                        future: _fetchSellPostImages(sellIds),
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (imageSnapshot.hasError) {
                            return Center(child: Text('오류 발생: ${imageSnapshot.error}'));
                          }

                          if (!imageSnapshot.hasData || imageSnapshot.data!.isEmpty) {
                            return Center(child: Text('이미지가 없습니다.'));
                          }

                          var images = imageSnapshot.data!;

                          return GridView.builder(
                            padding: EdgeInsets.all(8.0),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              String imgUrl = images[index];

                              return Container(
                                color: Colors.blueGrey,
                                child: imgUrl.isNotEmpty
                                    ? Image.network(
                                  imgUrl,
                                  fit: BoxFit.cover,
                                )
                                    : Center(
                                  child: Text(
                                    '이미지 없음',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  // 피드 페이지
                  Center(child: Text('피드 페이지')),
                  // 리뷰 페이지
                  Center(child: Text('리뷰 페이지')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _fetchSellPostImages(List<dynamic> sellIds) async {
    List<String> images = [];

    for (var sellId in sellIds) {
      var document = await FirebaseFirestore.instance
          .collection('SellPosts')
          .doc(sellId)
          .get();

      if (document.exists) {
        var data = document.data();
        if (data != null && data.containsKey('img')) {
          images.add(data['img']);
        }
      }
    }

    return images;
  }
}