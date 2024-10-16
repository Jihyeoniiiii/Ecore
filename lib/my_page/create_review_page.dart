import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_page/home_page_menu.dart';

class CreateReview extends StatefulWidget {
  final String orderId;
  final int itemIndex;
  final String itemTitle;
  final String itemImg;
  final int itemPrice;
  final String marketId;

  const CreateReview({
    Key? key,
    required this.orderId,
    required this.itemIndex,
    required this.itemTitle,
    required this.itemImg,
    required this.itemPrice,
    required this.marketId,
  }) : super(key: key);

  @override
  _CreateReviewState createState() => _CreateReviewState();
}

class _CreateReviewState extends State<CreateReview> {
  final TextEditingController _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? satisfaction; // "예" 또는 "아니요" 선택값
  double rating = 0.0; // 별점 값

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('리뷰 작성'),
      ),
      body: SingleChildScrollView( // 수정: 스크롤 가능하게 만들기
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemInfo(), // 상품 정보 표시
                SizedBox(height: 16),
                Text('구매하신 상품은 만족하시나요?', style: TextStyle(fontSize: 16)),
                _buildSatisfactionRadio(), // 만족도 선택
                SizedBox(height: 16),
                Text('별점', style: TextStyle(fontSize: 16)),
                _buildStarRating(), // 별점 선택
                SizedBox(height: 16),
                TextFormField(
                  controller: _reviewController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: '자세한 리뷰를 작성해주세요',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '리뷰를 입력해 주세요';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _submitReview();
                    }
                  },
                  child: Text('제출'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            widget.itemImg ?? 'https://via.placeholder.com/150',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/placeholder.png'); // 대체 이미지
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.itemTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '가격: ${widget.itemPrice}원',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSatisfactionRadio() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: Text('예'),
            value: '예',
            groupValue: satisfaction,
            onChanged: (value) {
              setState(() {
                satisfaction = value;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: Text('아니요'),
            value: '아니요',
            groupValue: satisfaction,
            onChanged: (value) {
              setState(() {
                satisfaction = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            Icons.star,
            color: index < rating ? Colors.orange : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              rating = index + 1.0;
            });
          },
        );
      }),
    );
  }

  Future<void> _submitReview() async {
    if (satisfaction == null || rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('만족도와 별점을 선택해 주세요')),
      );
      return;
    }

    final reviewText = _reviewController.text;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인되지 않았습니다.')),
      );
      return;
    }

    final reviewData = {
      'review': reviewText,
      'satisfaction': satisfaction,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': user.uid,
      'orderId': widget.orderId,
      'itemIndex': widget.itemIndex,
      'itemTitle': widget.itemTitle,
      'marketId': widget.marketId,
    };

    try {
      // Add review data to Firestore
      await FirebaseFirestore.instance.collection('Reviews').add(reviewData);

      // Fetch the item document ID using a query
      final itemsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Orders')
          .doc(widget.orderId)
          .collection('items')
          .where('title', isEqualTo: widget.itemTitle)
          .where('price', isEqualTo: widget.itemPrice)
          .get();

      if (itemsSnapshot.docs.isNotEmpty) {
        // Assuming there's only one document matching the query
        final itemDoc = itemsSnapshot.docs.first;
        await itemDoc.reference.update({'reviewed': true});
      } else {
        print('Item not found');
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,  // 모든 기존 페이지를 제거하고 새로운 페이지로 이동
      );
    } catch (error) {
      print('Error updating reviewed status: $error');
    }
  }
}
