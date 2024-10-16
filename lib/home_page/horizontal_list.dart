import 'package:flutter/material.dart';
import '../donation_page/donation_page_banner.dart';
import '../models/firestore/sell_post_model.dart';
import '../models/firestore/market_model.dart'; // Markets 컬렉션 모델 임포트
import 'feed_detail.dart';
import 'feed_list.dart';
import '../widgets/sold_out.dart'; // SoldOutOverlay 위젯 임포트
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 임포트

class HorizontalListSection extends StatelessWidget {
  final Stream<List<SellPostModel>> stream;
  final String title;
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
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                    final String firstImageUrl = post.img.isNotEmpty ? post.img[0] : 'https://via.placeholder.com/150';

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
                            Stack( // Stack 위젯으로 오버레이 적용
                              children: [
                                Container(
                                  height: 130, // Adjust height for the image
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0), // 모서리를 둥글게 설정
                                    child: Image.network(
                                      firstImageUrl, // 첫 번째 이미지를 사용
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // SoldOutOverlay를 이미지 위에 겹치게 설정
                                if (post.stock == 0) // 재고가 없을 때만 표시
                                  SoldOutOverlay(
                                    isSoldOut: true,
                                    radius: 30, // 원하는 크기로 radius 조정 가능
                                    borderRadius: 10.0, // 이미지와 동일하게 둥글기 설정
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
                                  padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
                                  child: Text(
                                    marketName, // Firestore에서 가져온 마켓 이름 표시
                                    style: TextStyle(fontSize: 14, color: Colors.black54), // 스타일 조정 가능
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                              child: Text(
                                '${post.price}원',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
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
