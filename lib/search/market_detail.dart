import 'package:ecore/cosntants/common_color.dart';
import 'package:ecore/search/market_feedpage_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/market_model.dart';
import '../my_market/my_market_feedpage.dart';
import '../my_market/my_market_productpage.dart';
import '../my_market/my_market_reviewpage.dart';
import 'market_product_page.dart';

class MarketDetail extends StatefulWidget {
  final MarketModel market;

  const MarketDetail({Key? key, required this.market}) : super(key: key);

  @override
  _MarketDetailState createState() => _MarketDetailState();
}

class _MarketDetailState extends State<MarketDetail> {
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
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // 배너 이미지 영역
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
                // 프로필 영역
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: market.img.isNotEmpty
                            ? NetworkImage(market.img) // 프로필 이미지 URL 사용
                            : AssetImage('assets/images/defualt_profile.jpg') as ImageProvider,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                market.name, // 현재 market 이름을 텍스트로 표시
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              if (market.business_number.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Icon(
                                    Icons.verified, // 표시할 아이콘
                                    color: Colors.blue, // 아이콘 색상
                                    size: 20, // 아이콘 크기
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Spacer(), // 오른쪽 정렬을 위해 Spacer 추가
                      IconButton(
                        icon: Icon(Icons.info, color: Colors.green[500]), // info 아이콘 추가
                        onPressed: () {
                          // info 버튼 동작 (팝업을 띄우거나 새로운 페이지로 이동)
                          _showMarketInfo(context, market);
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
                      MarketProductpage(marketId: market.marketId),
                      MarketFeedPageView(marketId: market.marketId),
                      MyMarketReviewPage(marketId: market.marketId,),
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

  // 마켓 정보 팝업
  void _showMarketInfo(BuildContext context, MarketModel market) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('마켓 정보'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('상호명', market.name),
              _infoRow('대표자명', market.seller_name ?? 'N/A'),
              _infoRow('사업자등록번호', market.business_number ?? 'N/A'),
              _infoRow('문의메일', market.email ?? 'N/A'),
              _infoRow('문의전화', market.cs_phone ?? 'N/A'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
