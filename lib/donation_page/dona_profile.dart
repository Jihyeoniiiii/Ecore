import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dona_detail.dart';
import 'dona_items_page.dart';
import 'dona_review_page.dart';  // DonaReviewPage import 추가
import 'package:cached_network_image/cached_network_image.dart'; // 이미지 캐싱을 위해 추가
import '../models/firestore/dona_post_model.dart'; // DonaPostModel import

class DonaProfilePage extends StatelessWidget {
  final String userId;  // 필수로 받아올 userId

  const DonaProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필'),
        centerTitle: true,  // 앱바 제목 중앙 배치
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Firestore에서 userId를 이용해 username 및 profile_img 가져오기 (실시간)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('Users').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // 로딩 중일 때
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}')); // 에러 발생 시
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('사용자 정보를 찾을 수 없습니다.')); // 데이터가 없을 때
                }

                // Firestore에서 실시간으로 가져온 데이터
                var userData = snapshot.data!.data() as Map<String, dynamic>?;
                String userName = userData?['username'] ?? 'Unknown User'; // username 가져오기
                String profileImgUrl = userData?['profile_img'] ?? 'https://via.placeholder.com/150'; // profile_img 가져오기

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(profileImgUrl), // Firestore에서 가져온 profile_img 사용
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,  // Firestore에서 실시간으로 가져온 사용자 이름
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              // 별표와 평점 표시 (평균값 계산 후 표시)
                              _buildRatingStars(userId), // 별점 표시 부분
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 10),
            Divider(thickness: 1, color: Colors.grey), // 구분선

            // 기부 물품 섹션
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('DonaPosts')
                  .where('userId', isEqualTo: userId) // 해당 사용자의 기부 물품만 가져오기
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return ListTile(
                    title: Text('기부 물품 0개'),
                    subtitle: Text('등록된 기부 물품이 없습니다.'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonationItemsPage(userId: userId),
                        ),
                      );
                    },
                  );
                }

                var donationItems = snapshot.data!.docs;
                int donationCount = donationItems.length;

                // 기부 물품 최대 3개 표시
                List<Widget> donationWidgets = donationItems.take(3).map((item) {
                  var itemData = item;
                  DonaPostModel donaPost = DonaPostModel.fromSnapshot(itemData);

                  return Column(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          // DonaDetail 페이지로 이동하며 donaPost 객체 전달
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DonaDetail(donaPost: donaPost),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[300]!, width: 1), // Light gray border color
                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0), // 패딩 약간 늘림
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0), // 패딩 약간 늘림
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0), // 이미지 모서리 둥글게
                                child: CachedNetworkImage(
                                  imageUrl: donaPost.img.isNotEmpty
                                      ? donaPost.img[0]
                                      : 'https://via.placeholder.com/100',
                                  width: 105, // 이미지 너비 증가
                                  height: 105, // 이미지 높이 증가
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.0), // 텍스트와 이미지 간의 간격 증가
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    donaPost.title,
                                    style: TextStyle(
                                      fontSize: 18, // 텍스트 크기 증가
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '상태: ${donaPost.condition}', // 상태 표시
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        _timeAgo(donaPost.createdAt), // 업로드 시간 표시
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4), // 상태와 시간 사이의 간격
                                  Text(
                                    donaPost.body, // 상세 내용 표시
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis, // 두 줄 넘어가면 생략
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  );
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('기부 물품 $donationCount개'),  // 기부 물품 개수 표시
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DonationItemsPage(userId: userId), // DonationItemsPage로 이동
                          ),
                        );
                      },
                    ),
                    Column(children: donationWidgets),  // 최대 3개의 기부 물품 리스트
                  ],
                );
              },
            ),

            // 받은 거래 후기 섹션
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Reviews')
                  .where('userId', isEqualTo: userId) // 해당 userId의 리뷰들 가져오기
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text('받은 거래 후기'),
                    subtitle: Text('받은 거래 후기가 아직 없어요.'),
                    trailing: Icon(Icons.chevron_right),
                  );
                } else if (snapshot.hasError) {
                  return ListTile(
                    title: Text('에러 발생'),
                    trailing: Icon(Icons.chevron_right),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return ListTile(
                    title: Text('받은 거래 후기'),
                    subtitle: Text('받은 거래 후기가 아직 없어요.'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonaReviewPage(userId: userId), // DonaReviewPage로 이동
                        ),
                      );
                    },
                  );
                }

                var reviews = snapshot.data!.docs;
                int reviewCount = reviews.length;

                // 받은 거래 후기 최대 3개 표시
                List<Widget> reviewWidgets = reviews.take(3).map((review) {
                  var reviewData = review.data() as Map<String, dynamic>;
                  String reviewText = reviewData['review'] ?? '리뷰 없음';
                  double rating = (reviewData['rating'] as num?)?.toDouble() ?? 0;
                  String marketId = reviewData['marketId'] ?? '알 수 없음';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('Markets').doc(marketId).get(),
                    builder: (context, marketSnapshot) {
                      if (marketSnapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                          ),
                          title: Text('Loading...'),
                          subtitle: Text('$reviewText\n별점: $rating'),
                        );
                      } else if (marketSnapshot.hasError || !marketSnapshot.hasData || !marketSnapshot.data!.exists) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                          ),
                          title: Text('Unknown Market'),
                          subtitle: Text('$reviewText\n별점: $rating'),
                        );
                      }

                      var marketData = marketSnapshot.data!.data() as Map<String, dynamic>?;
                      String marketName = marketData?['name'] ?? 'Unknown Market';
                      String marketImgUrl = marketData?['img'] ?? 'https://via.placeholder.com/150';

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
                          backgroundImage: NetworkImage(marketImgUrl),
                        ),
                        title: Text(marketName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: stars),
                            SizedBox(height: 8),
                            Text(reviewText),
                          ],
                        ),
                      );
                    },
                  );
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('받은 거래 후기 $reviewCount개'),  // 후기 개수 표시
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DonaReviewPage(userId: userId), // DonaReviewPage로 이동
                          ),
                        );
                      },
                    ),
                    Column(children: reviewWidgets),  // 최대 3개의 리뷰 리스트
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  // 별점 표시를 위한 위젯 (평균 계산)
  Widget _buildRatingStars(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Reviews')
          .where('userId', isEqualTo: userId) // 해당 userId의 리뷰들 가져오기
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 로딩 중일 때
        } else if (snapshot.hasError) {
          return Text('에러 발생'); // 에러 발생 시
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('평가 없음'); // 리뷰가 없을 때
        }

        // 리뷰의 별점(rating) 필드들의 평균 계산
        var reviews = snapshot.data!.docs;
        double totalRating = 0;
        for (var review in reviews) {
          totalRating += (review['rating'] as num).toDouble(); // 별점 합산
        }
        double averageRating = totalRating / reviews.length; // 평균 계산

        // 별점 표시
        return Row(
          children: [
            Row(
              children: List.generate(5, (index) {
                // 평균에 따른 별점 표시
                if (index < averageRating.floor()) {
                  return Icon(Icons.star, color: Colors.amber, size: 24);
                } else if (index < averageRating) {
                  return Icon(Icons.star_half, color: Colors.amber, size: 24);
                } else {
                  return Icon(Icons.star_border, color: Colors.amber, size: 24);
                }
              }),
            ),
            SizedBox(width: 8),
            Text(averageRating.toStringAsFixed(1), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 평균 별점 텍스트
          ],
        );
      },
    );
  }
}
