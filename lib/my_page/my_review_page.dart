import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/firestore/user_model.dart';
import 'edit_review_page.dart';

class MyReviewPage extends StatefulWidget {
  final UserModel userModel;

  MyReviewPage({required this.userModel});

  @override
  _MyReviewPageState createState() => _MyReviewPageState();
}

class _MyReviewPageState extends State<MyReviewPage> {
  late Future<List<Map<String, dynamic>>> _reviewsFuture;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _getUserReviews(widget.userModel.userKey);
  }

  Future<List<Map<String, dynamic>>> _getUserReviews(String userId) async {
    final snapshot = await _firestore
        .collection('Reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();
  }

  Future<String?> _getItemImageUrl(
      String userId, String orderId, int itemIndex) async {
    final itemSnapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Orders')
        .doc(orderId)
        .collection('items')
        .get();

    if (itemSnapshot.docs.isNotEmpty && itemIndex < itemSnapshot.docs.length) {
      final itemDoc = itemSnapshot.docs[itemIndex];
      final imgList = itemDoc['img'] as List<dynamic>?;
      if (imgList != null && imgList.isNotEmpty) {
        return imgList[0] as String; // 첫 번째 이미지 URL 반환
      }
    }
    return null;
  }

  Future<void> _deleteReview(String reviewId) async {
    if (reviewId.isNotEmpty) {
      // reviewId가 비어 있지 않은지 확인
      try {
        await _firestore.collection('Reviews').doc(reviewId).delete();
        // 리뷰 삭제 후 데이터를 새로 고침
        setState(() {
          _reviewsFuture = _getUserReviews(widget.userModel.userKey);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰가 삭제되었습니다.')),
        );
      } catch (e) {
        print('Error deleting review: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰 삭제 실패')),
        );
      }
    } else {
      print('Review ID is null or empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰 ID가 유효하지 않습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userName = widget.userModel.username;
    final String? profileImageUrl = widget.userModel.profileImg;

    return Scaffold(
      appBar: AppBar(
        title: Text('내 리뷰'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('리뷰를 가져오는 중 오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('작성한 리뷰가 없습니다.'));
          }

          final reviews = snapshot.data!;
          Map<DateTime, List<Map<String, dynamic>>> groupedReviews = {};

          // 리뷰를 날짜별로 그룹화
          for (var review in reviews) {
            final timestamp = (review['timestamp'] as Timestamp).toDate();
            final date =
                DateTime(timestamp.year, timestamp.month, timestamp.day);

            if (!groupedReviews.containsKey(date)) {
              groupedReviews[date] = [];
            }
            groupedReviews[date]!.add(review);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          profileImageUrl != null && profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : AssetImage('assets/images/default_profile.jpg')
                                  as ImageProvider,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$userName 님',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          '작성한 리뷰 수: ${reviews.length}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // 내 기부글 후기 페이지로 이동
                  },
                  child: Text('내 기부글 후기'),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: groupedReviews.entries.map((entry) {
                      final date = entry.key;
                      final reviewList = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(color: Colors.grey, thickness: 1),
                          // 날짜 구분 선
                          SizedBox(height: 8.0),
                          Text(
                            DateFormat('yyyy-MM-dd').format(date),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                          SizedBox(height: 8.0),
                          ...reviewList.map((review) {
                            final reviewId = review['id'] ??
                                ''; // Default to empty string if null
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<String?>(
                                    future: _getItemImageUrl(
                                      widget.userModel.userKey,
                                      review['orderId'],
                                      review['itemIndex'],
                                    ),
                                    builder: (context, imageSnapshot) {
                                      if (imageSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      } else if (imageSnapshot.hasError ||
                                          !imageSnapshot.hasData) {
                                        return Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: Icon(Icons.error,
                                              size: 40, color: Colors.red),
                                        );
                                      }

                                      final imageUrl = imageSnapshot.data ??
                                          'https://via.placeholder.com/80';
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review['itemTitle'] ?? 'No Title',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          review['review'] ?? 'No Content',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 4.0),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < (review['rating'] ?? 0.0)
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.yellow[600],
                                              size: 20.0,
                                            );
                                          }),
                                        ),
                                        SizedBox(height: 8.0),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.grey),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditReviewPage(
                                            reviewId: review['id']!,
                                            initialReview:
                                                review['review'] ?? '',
                                            initialRating:
                                                review['rating'] ?? 0.0,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.grey),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('삭제 확인'),
                                          content: Text('정말로 이 리뷰를 삭제하시겠습니까?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: Text('삭제'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text('취소'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true &&
                                          reviewId.isNotEmpty) {
                                        await _deleteReview(reviewId);
                                      } else if (confirm != true) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text('리뷰 삭제가 취소되었습니다.')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
