import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cosntants/common_color.dart';
import '../models/firestore/dona_post_model.dart';
import '../widgets/view_counter.dart';
import 'dona_profile.dart';

class DonaDetail extends StatefulWidget {
  final DonaPostModel donaPost;

  const DonaDetail({Key? key, required this.donaPost}) : super(key: key);

  @override
  State<DonaDetail> createState() => _DonaDetailState();
}

class _DonaDetailState extends State<DonaDetail> {
  int _currentIndex = 0; // 현재 사진의 인덱스를 저장할 변수

  @override
  void initState() {
    super.initState();
    _incrementViewCount();
  }

  Future<void> _incrementViewCount() async {
    try {
      // Firestore에서 현재 문서의 reference를 사용하여 조회수 증가
      await incrementViewCount(widget.donaPost.reference);
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: AppBar(
          titleSpacing: 0, // title과 leading 사이의 기본 간격을 제거
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(widget.donaPost.img), // 이미지 리스트 처리
            SizedBox(height: 4), // 간격을 줄임
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DonaProfilePage(userId: widget.donaPost.userId),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _userInfoBuild(context),
                    SizedBox(height: 4), // 간격을 줄임
                    Divider(thickness: 1, color: Colors.grey),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.donaPost.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4), // 간격을 줄임
                  // 날짜 추가
                  Text(
                    '날짜: ${widget.donaPost.createdAt.toLocal().toString().split(' ')[0]}', // 날짜 포맷
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 4), // 간격을 줄임
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '상태: ',
                            style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        TextSpan(text: widget.donaPost.condition,
                            style: TextStyle(fontSize: 16, color: Colors.black)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '색상: ',
                            style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        TextSpan(text: widget.donaPost.color,
                            style: TextStyle(fontSize: 16, color: Colors.black)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '재질: ',
                            style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        TextSpan(text: widget.donaPost.material,
                            style: TextStyle(fontSize: 16, color: Colors.black)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4), // 간격을 줄임
                  Text(widget.donaPost.body, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: () {
                      // 좋아요 버튼 기능 추가
                    },
                  ),
                  SizedBox(width: 8),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _addToCart,
                icon: Icon(Icons.shopping_cart, color: Colors.black54),
                label: Text('장바구니 담기', style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('Users').doc(
        user.uid);
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      print('User document does not exist');
      return;
    }

    final marketId = userDoc.data()?['marketId'];
    if (marketId == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('기부제품은 마켓만 구매 가능합니다.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    final cart = userDoc.data()?['cart'] ?? [];
    final newCartItem = {
      'donaUser': widget.donaPost.userId,
      'donaId': widget.donaPost.donaId,
      'title': widget.donaPost.title,
      'img': widget.donaPost.img,
      'point': widget.donaPost.point,
      'price': 0,
      'category': widget.donaPost.category,
      'body': widget.donaPost.body,
      'reference': widget.donaPost.reference.path,
    };

    cart.add(newCartItem);

    await userRef.update({'cart': cart});
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Text('이미지가 없습니다.');
    }

    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width, // 화면의 가로 크기와 동일한 너비 설정
      height: MediaQuery
          .of(context)
          .size
          .width, // 화면의 가로 크기와 동일한 높이 설정
      child: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover, // 이미지를 가로폭에 맞춰 전체 화면에 걸쳐 표시
                errorWidget: (context, url, error) => Icon(Icons.error),
                placeholder: (context, url) => CircularProgressIndicator(),
              );
            },
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.black54,
              child: Text(
                '${_currentIndex + 1}/${images.length}',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userInfoBuild(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.donaPost.userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error fetching user data: ${snapshot.error}');
          return Text('사용자 정보를 불러오는 데 실패했습니다.');
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('사용자를 찾을 수 없습니다.');
        }

        // 사용자 데이터를 안전하게 처리
        var userData = snapshot.data!.data() as Map<String, dynamic>?;

        if (userData == null) {
          return Text('사용자 정보가 없습니다.');
        }

        String userName = userData['username'] ?? 'Unknown User';
        ImageProvider userImage = _getValidImageProvider(userData['profile_img'] as String?);

        return _userView(userImage, userName);
      },
    );
  }

  Widget _userView(ImageProvider imageProvider, String userName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: imageProvider, // 이미지 제공자 사용
          radius: 30, // 아바타 크기
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider _getValidImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return AssetImage('assets/images/default_profile.jpg'); // 로컬 기본 이미지 사용
    } else {
      return CachedNetworkImageProvider(imageUrl);
    }
  }
}