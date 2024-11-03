import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonaReviewPage extends StatelessWidget {
  final String userId;  // 필수로 받아올 userId

  const DonaReviewPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('거래 후기 상세'),  // 앱바 제목 변경
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Firestore에서 Reviews 컬렉션에서 해당 유저의 리뷰 가져오기
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Reviews')
                  .where('userId', isEqualTo: userId)  // 유저 ID로 필터링
                  .where('byseller_review', isEqualTo: 'false')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('받은 거래 후기가 없습니다.'));
                }

                var reviews = snapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '후기 ${reviews.length}개',  // 불러온 후기 갯수를 표시
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화 (부모의 스크롤에 따라감)
                      itemCount: reviews.length,
                      separatorBuilder: (context, index) => Divider(
                        thickness: 1,
                        color: Colors.grey[300],  // 사진 속 선과 유사한 색상
                        indent: 16,  // 선의 왼쪽 여백
                        endIndent: 16,  // 선의 오른쪽 여백
                      ), // 후기 구분선
                      itemBuilder: (context, index) {
                        var review = reviews[index].data() as Map<String, dynamic>;
                        String reviewText = review['review'] ?? '리뷰 없음';
                        double rating = (review['rating'] as num?)?.toDouble() ?? 0;
                        String marketId = review['marketId'] ?? '알 수 없음';

                        // marketId를 사용해 Markets 컬렉션에서 name 및 img 필드 가져오기
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('Markets')
                              .doc(marketId)
                              .get(),
                          builder: (context, marketSnapshot) {
                            if (marketSnapshot.connectionState == ConnectionState.waiting) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // 임시 이미지
                                ),
                                title: Text('Loading...'), // 로딩 중 표시
                                subtitle: Text('$reviewText\n별점: $rating'),
                              );
                            } else if (marketSnapshot.hasError || !marketSnapshot.hasData || !marketSnapshot.data!.exists) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // 임시 이미지
                                ),
                                title: Text('Unknown Market'),  // 에러 발생 시
                                subtitle: Text('$reviewText\n별점: $rating'),
                              );
                            }

                            // Markets 컬렉션에서 name 및 img 필드 가져오기
                            var marketData = marketSnapshot.data!.data() as Map<String, dynamic>?;
                            String marketName = marketData?['name'] ?? 'Unknown Market';
                            String marketImgUrl = marketData?['img'] ?? 'https://via.placeholder.com/150'; // img 필드 추가

                            // 별점 생성
                            List<Widget> stars = List.generate(5, (index) {
                              if (index < rating.floor()) {
                                return Icon(Icons.star, color: Colors.amber, size: 20);
                              } else if (index < rating) {
                                return Icon(Icons.star_half, color: Colors.amber, size: 20);
                              } else {
                                return Icon(Icons.star_border, color: Colors.amber, size: 20);
                              }
                            });

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(marketImgUrl), // Markets 컬렉션에서 가져온 img 필드
                              ),
                              title: Text(marketName),  // Markets 컬렉션에서 가져온 name 필드
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: stars, // 별점 표시
                                  ),
                                  SizedBox(height: 8), // 별점과 리뷰 텍스트 간 간격
                                  Text(reviewText),  // 리뷰 텍스트
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
