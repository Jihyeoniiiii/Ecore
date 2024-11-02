import 'package:flutter/material.dart';
import '../donation_page/donation_page_banner.dart';
import '../models/firestore/sell_post_model.dart';
import '../widgets/price_display.dart';
import 'feed_detail.dart';
import '../widgets/sold_out.dart'; // SoldOutOverlay 위젯 임포트
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 임포트

class HorizontalListSection extends StatelessWidget {
  final Stream<List<SellPostModel>> stream;
  final Widget title; // Widget으로 정의
  final VoidCallback onMorePressed;

  const HorizontalListSection({
    required this.stream,
    required this.title,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              title, // title을 직접 사용
              // "더보기" 버튼을 오른쪽에 붙이기
              TextButton(
                onPressed: onMorePressed,
                child: Text(
                  '더보기',
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 220, // Set height for the ListView
            child: StreamBuilder<List<SellPostModel>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: TextButton(
                      onPressed: () {
                        // 상품 보러가기 버튼 클릭 시 SellList로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DonationBanner(),
                          ),
                        );
                      },
                      child: Text(
                        '상품 보러가기 🤣',
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  );
                }

                final items = snapshot.data!.take(6).toList(); // Limit to 6 items

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final post = items[index];
                    final String firstImageUrl = post.img.isNotEmpty
                        ? post.img[0]
                        : 'https://via.placeholder.com/150';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FeedDetail(sellPost: post),
                          ),
                        );
                      },
                      child: Container(
                        width: 150, // Fixed width for each item
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 130,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      firstImageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // SoldOutOverlay를 이미지 위에 겹치게 설정
                                if (post.stock == 0)
                                  SoldOutOverlay(
                                    isSoldOut: true,
                                    radius: 30,
                                    borderRadius: 10.0,
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                post.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            // Firestore에서 마켓 이름 가져오기
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Markets')
                                  .doc(post.marketId)
                                  .snapshots(),
                              builder: (context, marketSnapshot) {
                                if (marketSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text('로딩 중...');
                                }
                                if (marketSnapshot.hasError) {
                                  return Text('에러 발생');
                                }
                                if (!marketSnapshot.hasData ||
                                    !marketSnapshot.data!.exists) {
                                  return Text('마켓 없음');
                                }

                                final marketName = marketSnapshot
                                    .data!['name'];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 1.0, horizontal: 4.0),
                                  child: Text(
                                    marketName,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 4.0),
                              child: PriceDisplay(price: post.price, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
