import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import '../models/firestore/market_model.dart'; // MarketModel import
import '../my_page/favorite_list_page.dart';
import '../my_page/recently_viewed_page.dart';
import '../search/search_screen.dart';
import '../widgets/business_information.dart';
import 'business_market_post.dart';
import 'carousel_slider.dart';
import 'horizontal_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TitleBanner extends StatefulWidget {
  const TitleBanner({super.key});

  @override
  State<TitleBanner> createState() => _TitleBannerState();
}

class _TitleBannerState extends State<TitleBanner> {
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
    final userModel = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(isDonationSearch: null),
                  ),
                );
              },
              icon: Icon(
                CupertinoIcons.search,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Center(child: CareouselSlider()),
              ),
              HorizontalListSection(
                stream: businessSellPostsStream(), // Stream 설정
                title: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 0.0), // 왼쪽 여백 추가
                      child: Text(
                        '믿고 거래하는 에코리 상품',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // 스타일 설정
                      ),
                    ),
                    // 로고 이미지
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0), // 이미지와 텍스트 사이의 간격
                      child: Image.asset(
                        'assets/images/ecore_2_logo.png', // 로고 이미지 파일 경로
                        width: 30, // 이미지의 너비
                        height: 30, // 이미지의 높이
                      ),
                    ),
                  ],
                ),
                onMorePressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusinessMarketPost(), // 실제 페이지로 변경
                    ),
                  );
                },
              ),


              HorizontalListSection(
                stream: userModel.recentlyViewedStream,
                title: Padding( // Padding 추가
                  padding: const EdgeInsets.only(left: 8.0), // 왼쪽 여백 추가
                  child: Text(
                    '최근 본 상품',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                onMorePressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecentViewedPage(),
                    ),
                  );
                },
              ),
              HorizontalListSection(
                stream: userModel.favoriteListStream,
                title: Padding( // Padding 추가
                  padding: const EdgeInsets.only(left: 8.0), // 왼쪽 여백 추가
                  child: Text(
                    '찜한 상품',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                onMorePressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoriteListPage(), // 실제 페이지로 변경
                    ),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BusinessInformation(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
