import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditReviewPage extends StatefulWidget {
  final String reviewId;
  final String initialReview;
  final double initialRating;

  EditReviewPage({
    required this.reviewId,
    required this.initialReview,
    required this.initialRating,
  });

  @override
  _EditReviewPageState createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _reviewController;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController(text: widget.initialReview);
    _rating = widget.initialRating;
  }

  Future<void> _updateReview() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('Reviews').doc(widget.reviewId).update({
          'review': _reviewController.text,
          'rating': _rating,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰가 수정되었습니다.')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        print('Error updating review: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰 수정에 실패했습니다.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('리뷰 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '별점',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.yellow[600],
                      size: 30.0,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _reviewController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '리뷰 내용',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '리뷰 내용을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _updateReview,
                  child: Text('수정 완료'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
