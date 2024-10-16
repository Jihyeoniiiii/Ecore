import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/sell_post_model.dart';
import '../home_page/feed_detail.dart';
import '../widgets/sold_out.dart'; // SoldOutOverlay 임포트

class MarketProductpage extends StatelessWidget {
  final String marketId;

  const MarketProductpage({Key? key, required this.marketId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SellPostModel>>(
      stream: FirebaseFirestore.instance
          .collection('SellPosts')
          .where('marketId', isEqualTo: marketId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => SellPostModel.fromSnapshot(doc)).toList()),
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

        var details = snapshot.data!;

        return GridView.builder(
          padding: EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,  // 3개의 열
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            childAspectRatio: 0.6,  // 비율을 줄여 세로 공간을 더 확보
          ),
          itemCount: details.length,
          itemBuilder: (context, index) {
            var sellPost = details[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedDetail(sellPost: sellPost),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),  // 모서리를 둥글게 설정
                        child: AspectRatio(
                          aspectRatio: 1.0,  // 1:1 비율 고정
                          child: Container(
                            color: Colors.blueGrey,
                            child: sellPost.img.isNotEmpty
                                ? Image.network(
                              sellPost.img[0],
                              fit: BoxFit.cover,  // 이미지를 컨테이너에 맞게 1:1로 채움
                            )
                                : Center(
                              child: Text(
                                '이미지 없음',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 솔드 아웃 오버레이
                      SoldOutOverlay(
                        isSoldOut: sellPost.stock == 0, // 솔드 아웃 상태 확인
                        radius: 30.0, // 모서리에 맞게 둥글게 설정
                        borderRadius: 6.0,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),  // 이미지와 텍스트 간의 간격
                  Text(
                    '${sellPost.price}원',  // 가격 정보
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    sellPost.title,  // 제목 정보
                    maxLines: 2,  // 두 줄까지 표시
                    overflow: TextOverflow.ellipsis,  // 두 줄 이상일 경우 생략
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
