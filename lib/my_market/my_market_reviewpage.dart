import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 위해 추가
import '../home_page/feed_detail.dart'; // FeedDetail 페이지 임포트
import '../models/firestore/sell_post_model.dart'; // SellPostModel 임포트

class MyMarketReviewPage extends StatelessWidget {
  final String marketId; // 마켓 ID를 받음

  const MyMarketReviewPage({Key? key, required this.marketId}) : super(key: key);

  // 특정 sellPostId를 통해 Firestore에서 해당 상품 데이터를 가져오는 함수
  Future<SellPostModel?> getSellPostByTitle(String marketId, String itemTitle) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('SellPosts')
          .where('marketId', isEqualTo: marketId)
          .where('title', isEqualTo: itemTitle)
          .limit(1) // 해당 타이틀과 매칭되는 하나의 상품만 가져오기
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return SellPostModel.fromSnapshot(querySnapshot.docs.first); // 첫번째 문서 가져오기
      }
    } catch (e) {
      print('Error fetching SellPost: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Reviews')
            .where('marketId', isEqualTo: marketId) // 해당 marketId의 리뷰만 필터링
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('리뷰가 없습니다.'));
          }

          final reviews = snapshot.data!.docs;
          double totalRating = 0;
          int totalReviews = reviews.length;

          // 총 평점 계산
          reviews.forEach((doc) {
            totalRating += doc['rating'];
          });

          double averageRating = totalRating / totalReviews;
          int satisfactionCount = reviews
              .where((doc) => doc['satisfaction'] == '예') // 만족도를 필터링
              .length;
          double satisfactionPercentage =
              (satisfactionCount / totalReviews) * 100;

          return Column(
            children: [
              // 상단에 평균 평점과 만족도 비율을 표시
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '이 상점의 거래후기 $totalReviews',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < averageRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                );
                              }),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${satisfactionPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text('만족후기'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
              // 리뷰 리스트 표시
              Expanded(
                child: ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    var review = reviews[index];

                    return GestureDetector(
                      onTap: () async {
                        // Firestore에서 SellPost를 검색
                        SellPostModel? sellPost = await getSellPostByTitle(marketId, review['itemTitle']);

                        // 상품이 존재하면 FeedDetail로 이동
                        if (sellPost != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FeedDetail(sellPost: sellPost),
                            ),
                          );
                        } else {
                          // 오류 처리: 해당 상품을 찾지 못한 경우
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('해당 상품을 찾을 수 없습니다.')),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 별과 평점 부분
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  review['rating'].toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // 평점 굵게
                                ),
                                Spacer(),
                                // 세로로 ... 버튼
                                PopupMenuButton<String>(
                                  onSelected: (String value) {
                                    if (value == 'report') {
                                      // 신고 처리 로직 추가
                                      _showReportDialog(context);
                                    } else if (value == 'hide') {
                                      // 숨기기 로직 추가
                                    }
                                  },
                                  icon: Icon(Icons.more_vert, color: Colors.grey),
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      PopupMenuItem(
                                        value: 'report',
                                        child: Text('신고'),
                                      ),
                                    ];
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            // 리뷰 내용 부분
                            Text(
                              review['review'],
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            // 주문 ID와 작성일
                            Row(
                              children: [
                                Text(
                                  review['orderId'], // 주문 ID 표시
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  DateFormat('yyyy-MM-dd').format(
                                    (review['timestamp'] as Timestamp).toDate(),
                                  ),
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // 거래 상품 제목과 > 버튼
                            Container(
                              height: 40, // 원하는 세로 길이 설정
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200], // 회색 배경
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center, // 세로축 중앙 정렬
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 정렬
                                children: [
                                  Expanded(
                                    child: Text(
                                      '거래상품  ${review['itemTitle']}', // 거래 상품 제목
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 16), // > 버튼 크기 조정
                                ],
                              ),
                            ),
                            SizedBox(height: 8), // 다음 리뷰와의 간격을 유지하기 위한 여백
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('신고 이유를 선택해주세요'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildReportOption(context, '부적절한 내용'),
                _buildReportOption(context, '스팸'),
                _buildReportOption(context, '기타'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportOption(BuildContext context, String reason) {
    return ListTile(
      title: Text(reason),
      onTap: () {
        // 신고 로직 추가
        Navigator.of(context).pop();
      },
    );
  }
}
