import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/firestore/market_model.dart';
import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import 'package:provider/provider.dart';
import '../search/market_detail.dart';
import '../chat_page/chat_banner.dart';
import '../widgets/sold_out.dart';
import '../widgets/view_counter.dart';

class FeedDetail extends StatefulWidget {
  final SellPostModel sellPost;

  const FeedDetail({Key? key, required this.sellPost}) : super(key: key);

  @override
  State<FeedDetail> createState() => _FeedDetailState();
}

class _FeedDetailState extends State<FeedDetail> {
  int _currentIndex = 0; // 현재 사진의 인덱스를 저장할 변수
  bool _isFavorite = false;
  String? marketUserId;
  String? marketName; // 추가: 마켓 이름을 저장할 변수
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _incrementViewCount();
    _checkIfFavorite(); // 추가: 즐겨찾기 상태를 확인하는 함수 호출
    _fetchMarketUserId();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _fetchMarketUserId() async {
    try {
      final marketDoc = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.sellPost.marketId)
          .get();

      final marketData = marketDoc.data();
      setState(() {
        marketUserId = marketData?['userId'];
        marketName = marketData?['name']; // 추가: 마켓 이름 가져오기
      });
    } catch (e) {
      print('Error fetching market userId: $e');
    }
  }

  Future<void> _incrementViewCount() async {
    try {
      // Firestore에서 현재 문서의 reference를 사용하여 조회수 증가
      await incrementViewCount(widget.sellPost.reference);
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in
      print('User not logged in');
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      // User document does not exist
      print('User document does not exist');
      return;
    }

    final cart = userDoc.data()?['cart'] ?? [];
    final newCartItem = {
      'sellId': widget.sellPost.sellId,
      'title': widget.sellPost.title,
      'img': widget.sellPost.img,
      'price': widget.sellPost.price,
      'category': widget.sellPost.category,
      'body': widget.sellPost.body,
      'marketId': widget.sellPost.marketId,
      'marketName': marketName, // 추가: 마켓 이름 추가
      'shippingFee': widget.sellPost.shippingFee,
      'reference': widget.sellPost.reference.path,
    };

    // Add the new item to the cart
    cart.add(newCartItem);

    // Update the user's cart in Firestore
    await userRef.update({'cart': cart});
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoriteRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('FavoriteList')
          .doc(widget.sellPost.sellId);

      final doc = await favoriteRef.get();
      setState(() {
        _isFavorite = doc.exists;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    if (_isFavorite) {
      // Remove from wishlist
      final favoriteRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('FavoriteList')
          .doc(widget.sellPost.sellId);

      await favoriteRef.delete();
    } else {
      // Add to wishlist
      await userModel.addItemToWishlist(widget.sellPost);
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(widget.sellPost.img), // 이미지 리스트 처리
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _marketInfoBuild(context),
                  SizedBox(height: 16),
                  // 재고 정보 출력 추가 (재고 0일 때 '재고 없음'으로 출력)
                  Text(
                    widget.sellPost.stock > 0
                        ? '재고 : ${widget.sellPost.stock}개' // 재고가 있으면 수량 출력
                        : '재고 없음', // 재고가 0일 경우
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.sellPost.stock > 0 ? Colors.black : Colors.red,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(widget.sellPost.body, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNaviBar(),
    );
  }

  BottomAppBar _bottomNaviBar() {
    return BottomAppBar(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.black54,
                  ),
                  onPressed: _toggleFavorite,
                ),
                SizedBox(width: 8),
                Text(
                  '${widget.sellPost.price}원',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _addToCart,
              icon: Icon(Icons.shopping_cart, color: Colors.black54),
              label: Text('장바구니 담기', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marketInfoBuild(BuildContext context) {
    if (widget.sellPost.marketId.isEmpty) {
      return Text('마켓 정보가 없어요~!');
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.sellPost.marketId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error fetching market data: ${snapshot.error}');
          return Text('Failed to load market info');
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('Market not found');
        }

        var marketData = snapshot.data!.data() as Map<String, dynamic>?;

        if (marketData == null) {
          return Text('Market data is not available');
        }

        String marketName = marketData['name'] ?? 'Unknown Market';
        String marketImage = marketData['img'] ?? 'https://via.placeholder.com/150';
        String businessNumber = marketData['business_number'] ?? '';

        return InkWell(
          onTap: () {
            final market = MarketModel.fromSnapshot(snapshot.data!);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarketDetail(market: market),
              ),
            );
          },
          child: _marketView(marketImage, marketName, businessNumber),
        );
      },
    );
  }

  Row _marketView(String marketImage, String marketName, String businessNumber) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(marketImage),
          radius: 30,
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sellPost.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  marketName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (businessNumber.isNotEmpty) // 비즈니스 넘버가 존재할 때 체크 아이콘 추가
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0), // 아이콘과 텍스트 간격 조절
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.blue, // 체크 아이콘 색상 설정
                      size: 18, // 아이콘 크기 설정
                    ),
                  ),
              ],
            ),
          ],
        ),
        Spacer(),
        IconButton(
          onPressed: () {
            if (currentUserId == marketUserId) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text("자신의 마켓과는 채팅이 불가합니다."),
                    ),
                    actions: [
                      TextButton(
                        child: Text("확인"),
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatBanner(marketId: widget.sellPost.marketId, sellId: widget.sellPost.sellId),
                ),
              );
            }
          },
          icon: Icon(Icons.mail, size: 30),
        )
      ],
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Text('이미지가 없습니다.');
    }

    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width, // 화면의 가로 크기와 동일한 너비 설정
          height: MediaQuery.of(context).size.width, // 화면의 가로 크기와 동일한 높이 설정
          child: PageView.builder(
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
                fit: BoxFit.cover,  // 이미지를 가로폭에 맞춰 전체 화면에 걸쳐 표시
                errorWidget: (context, url, error) => Icon(Icons.error),
                placeholder: (context, url) => CircularProgressIndicator(),
              );
            },
          ),
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
        // 판매 완료 이미지 표시
        SoldOutOverlay(isSoldOut: widget.sellPost.stock == 0),
      ],
    );
  }
}
