import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import '../widgets/sold_out.dart';
import 'category_button.dart';
import 'feed_detail.dart';

class SellList extends StatefulWidget {
  final String selectedSort;
  const SellList({Key? key, required this.selectedSort}) : super(key: key);

  @override
  State<SellList> createState() => _SellListState();
}

class _SellListState extends State<SellList> {
  final UserModel userModel = UserModel(); // UserModel 인스턴스 생성
  String _selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: CategoryBtn(
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getQueryStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No posts found'));
              }

              final data = snapshot.data!;

              return GridView.builder(
                padding: EdgeInsets.all(8.0), // 그리드의 패딩 조정
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 한 줄에 3개의 아이템을 배치
                  crossAxisSpacing: 8.0, // 아이템 사이의 가로 간격
                  mainAxisSpacing: 0.0, // 아이템 사이의 세로 간격
                  childAspectRatio: 0.55, // 아이템의 비율 조정
                ),
                itemCount: data.size,
                itemBuilder: (context, index) {
                  final sellPost = SellPostModel.fromSnapshot(data.docs[index]);
                  return _postHeader(sellPost);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getQueryStream() {
    CollectionReference collection = FirebaseFirestore.instance.collection('SellPosts');

    Query query = collection;

    if (widget.selectedSort == '3') {
      query = query.orderBy('viewCount', descending: true);
    } else if (widget.selectedSort == '1') {
      query = query.orderBy('createdAt', descending: true);
    } else if (widget.selectedSort == '2') {
      query = query.orderBy('createdAt', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    // 카테고리 필터 적용
    if (_selectedCategory.isNotEmpty) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return query.snapshots();
  }

  Widget _postHeader(SellPostModel sellPost) {
    final String firstImageUrl = sellPost.img.isNotEmpty ? sellPost.img[0] : 'https://via.placeholder.com/100';

    return GestureDetector(
      onTap: () {
        userModel.addRecentlyViewed(sellPost);  // Function call directly
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
                borderRadius: BorderRadius.circular(10.0), // 이미지의 둥글기
                child: CachedNetworkImage(
                  imageUrl: firstImageUrl,
                  width: double.infinity,
                  height: 120, // 이미지의 높이를 줄임
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              // SoldOutOverlay를 추가하여 재고가 0일 때 판매 완료를 표시
              SoldOutOverlay(isSoldOut: sellPost.stock == 0, radius: 30, borderRadius: 10.0,), // 판매 완료 오버레이 추가
              // 실시간으로 즐겨찾기 상태를 확인하는 StreamBuilder 추가
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('FavoriteList')
                    .doc(sellPost.sellId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Positioned(
                      top: -1,
                      right: -4,
                      child: IconButton(
                        icon: Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {}, // 로딩 중에는 아무 동작하지 않음
                      ),
                    );
                  }
                  bool isFavorite = snapshot.data != null && snapshot.data!.exists;

                  return Positioned(
                    top: -1,
                    right: -4,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () => _toggleFavorite(sellPost, isFavorite), // 하트 클릭 시 동작 추가
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10), // 이미지와 텍스트 간의 간격 조정
          Row(
            children: [
              Expanded(
                child: Text(
                  sellPost.title, // 제목
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 1, // 제목이 한 줄을 넘어가면 생략
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'report') {
                    _showReportDialog();  // 신고 다이얼로그 호출
                  } else if (value == 'hide') {
                    // 숨기기 로직 구현 (추후 추가 가능)
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      value: 'report',
                      child: Text('신고'),
                    ),
                    PopupMenuItem(
                      value: 'hide',
                      child: Text('숨기기'),
                    ),
                  ];
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '...',
                    style: TextStyle(
                      fontSize: 20, // 가격과 비슷한 크기
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Firestore에서 마켓 이름 가져오기
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Markets')
                .doc(sellPost.marketId) // post에서 marketId 가져오기
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

              return Text(
                marketName, // Firestore에서 가져온 마켓 이름 표시
                style: TextStyle(fontSize: 12, color: Colors.black54), // 스타일 조정 가능
              );
            },
          ),
          Text(
            '${sellPost.price}원', // 가격
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('신고 이유를 선택해주세요'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildReportOption('부적절한 내용'),
                _buildReportOption('스팸'),
                _buildReportOption('기타'),
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

  Widget _buildReportOption(String reason) {
    return ListTile(
      title: Text(reason),
      onTap: () {
        Navigator.of(context).pop();
        // 신고 처리 로직 추가
      },
    );
  }

  // 하트를 클릭했을 때 찜 목록에 추가하거나 제거하는 로직
  Future<void> _toggleFavorite(SellPostModel sellPost, bool isFavorite) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    final favoriteRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('FavoriteList')
        .doc(sellPost.sellId);

    if (isFavorite) {
      // 찜 목록에서 제거
      await favoriteRef.delete();
    } else {
      // 찜 목록에 추가
      final favoriteData = sellPost.toMap();
      favoriteData['selectedAt'] = Timestamp.now(); // 선택한 시간을 추가
      await favoriteRef.set(favoriteData); // 데이터를 정확하게 추가
    }
  }
}
