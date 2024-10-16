import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page/category_button.dart';
import '../models/firestore/dona_post_model.dart';
import '../widgets/view_counter.dart';
import 'dona_detail.dart';

class DonationList extends StatefulWidget {
  final String selectedSort; // 정렬 옵션 추가

  const DonationList({Key? key, required this.selectedSort}) : super(key: key);

  @override
  State<DonationList> createState() => _DonationListState();
}

class _DonationListState extends State<DonationList> {
  String _selectedCategory = ''; // 기본값

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CategoryBtn(
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category; // 카테고리 선택 시 업데이트
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

              return ListView.builder(
                shrinkWrap: true,
                itemCount: data.size,
                itemBuilder: (context, index) {
                  final donaPost = DonaPostModel.fromSnapshot(data.docs[index]);
                  return _postHeader(donaPost);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getQueryStream() {
    CollectionReference collection = FirebaseFirestore.instance.collection('DonaPosts');

    Query query = collection;

    // 카테고리 필터 적용
    if (_selectedCategory.isNotEmpty) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    // 정렬 기준에 따라 쿼리 수정
    if (widget.selectedSort == '3') {
      query = query.orderBy('viewCount', descending: true); // 조회순
    } else if (widget.selectedSort == '1') {
      query = query.orderBy('createdAt', descending: true); // 최신순
    } else if (widget.selectedSort == '2') {
      query = query.orderBy('createdAt', descending: false); // 오래된순
    } else {
      query = query.orderBy('createdAt', descending: true); // 기본값: 최신순
    }

    return query.snapshots();
  }

  Widget _postHeader(DonaPostModel donaPost) {
    // 이미지 크기 조정 (1.5배 확대)
    final String firstImageUrl = donaPost.img.isNotEmpty ? donaPost.img[0] : 'https://via.placeholder.com/100';

    return OutlinedButton(
      onPressed: () {
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
          // 이미지 크기 조정 (1.5배 확대)
          Padding(
            padding: const EdgeInsets.all(6.0), // 패딩 약간 늘림
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0), // Adjust radius as needed
              child: CachedNetworkImage(
                imageUrl: firstImageUrl,
                width: 105, // 이미지 너비 증가
                height: 105, // 이미지 높이 증가
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          SizedBox(width: 12.0), // 텍스트와 이미지 간의 간격 약간 증가
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donaPost.title,
                  style: TextStyle(
                    fontSize: 18, // 텍스트 크기 약간 증가
                    fontWeight: FontWeight.normal, // Make the font bold
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'report') {
                _showReportDialog();  // Show report dialog
              } else if (value == 'hide') {
                // Hide logic
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
        // Handle the selection of the reason here
        Navigator.of(context).pop();
        // You could add additional logic to process the report
      },
    );
  }
}
