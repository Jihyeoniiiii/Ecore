import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../donation_page/dona_detail.dart'; // DonaDetail 페이지 import
import '../models/firestore/dona_post_model.dart'; // DonaPostModel import

class DonationItemsPage extends StatelessWidget {
  final String userId; // 사용자 ID는 필수로 받아옴

  const DonationItemsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('Users').doc(userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('기부물품'); // 로딩 중일 때 기본 제목
            }
            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return Text('기부물품'); // 오류 발생 시 기본 제목
            }

            // Firestore에서 가져온 데이터로 제목 설정
            var userData = snapshot.data!.data() as Map<String, dynamic>?;
            String userName = userData?['username'] ?? '사용자';
            return Text('$userName님의 기부물품');
          },
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('DonaPosts')
                  .where('userId', isEqualTo: userId) // 해당 사용자의 기부 물품만 가져오기
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // 로딩 중
                }

                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다.')); // 오류 처리
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('기부물품이 없습니다.')); // 기부물품이 없을 때
                }

                var donationItems = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: donationItems.length,
                  itemBuilder: (context, index) {
                    var itemData = donationItems[index];

                    // Firestore DocumentSnapshot을 이용해 DonaPostModel 객체 생성
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
                                    imageUrl: donaPost.img.isNotEmpty ? donaPost.img[0] : 'https://via.placeholder.com/100',
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
                        Divider(
                          color: Colors.grey[300], // 구분선 색상
                          thickness: 0.5, // 구분선 두께를 0.5로 줄임
                          height: 1, // 높이를 줄여 구분선이 간결하게 나타나도록 설정
                        ),
                      ],
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
}
