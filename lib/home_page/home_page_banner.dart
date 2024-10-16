import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import '../models/firestore/market_model.dart'; // MarketModel import
import '../my_page/favorite_list_page.dart';
import '../my_page/recently_viewed_page.dart';
import '../search/search_screen.dart';
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
              'assets/images/ecore_logo.png', // 로고 이미지 경로
              height: 40, // 로고의 높이를 설정 (필요에 따라 크기 조정)
            ),
            Spacer(), // 텍스트와 검색 아이콘 사이의 공간 확보
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Center(child: CareouselSlider()),
            ),
            HorizontalListSection(
              stream: businessSellPostsStream(), // Stream 설정
              title: '사업자 등록된 마켓의 상품',
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
              title: '최근 본 상품',
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
              title: '찜한 상품',
              onMorePressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoriteListPage(), // 실제 페이지로 변경
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
