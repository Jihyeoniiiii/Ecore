import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/market_model.dart';
import '../models/firestore/sell_post_model.dart';
import 'my_market_feedpage.dart';
import 'my_market_productpage.dart';
import 'my_market_reviewpage.dart';
import 'my_market_search.dart';
import 'my_market_settings.dart';  // 새로운 MyMarketProductpage 위젯을 import

class MyMarketBanner extends StatefulWidget {
  final MarketModel market; // MarketModel을 필수 인자로 받음

  const MyMarketBanner({Key? key, required this.market}) : super(key: key);

  @override
  _MyMarketBannerState createState() => _MyMarketBannerState();
}

class _MyMarketBannerState extends State<MyMarketBanner> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.market.marketId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류 발생: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('마켓 정보를 불러오지 못했습니다.'));
        }

        var marketData = snapshot.data!.data() as Map<String, dynamic>;
        var market = MarketModel.fromSnapshot(snapshot.data!);

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(marketId: market.marketId,),
                      ),
                    );
                  },
                ),
              ],
            ),
            backgroundColor: Colors.white, // 배경색 흰색으로 설정
            body: Column(
              children: [
                // 배너 이미지 영역 (글쓰기 버튼 제거됨)
                Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: market.bannerImg.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(market.bannerImg), // 배너 이미지 URL 사용
                          fit: BoxFit.cover,
                        )
                            : null,
                        color: Colors.grey,
                      ),
                      child: market.bannerImg.isEmpty
                          ? Center(
                        child: Text(
                          '배너',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      )
                          : null,
                    ),
                  ],
                ),
                // 프로필과 검색창 영역
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: market.img.isNotEmpty
                            ? NetworkImage(market.img) // 프로필 이미지 URL 사용
                            : AssetImage('assets/profile_image.jpg') as ImageProvider,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            market.name, // 현재 market 이름을 텍스트로 표시
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyMarketSettings(marketId: market.marketId),
                            ),
                          );
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
                      // 상품 페이지를 MyMarketProductpage 위젯으로 교체
                      MyMarketProductpage(marketId: market.marketId),
                      // 피드 페이지
                      MyMarketFeedPage(marketId: market.marketId,),
                      // 리뷰 페이지
                      MyMarketReviewPage(marketId: market.marketId), // marketId 전달
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
