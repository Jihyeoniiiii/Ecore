import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../donation_page/dona_detail.dart';
import '../models/firestore/dona_post_model.dart';
import '../models/firestore/user_model.dart';
import '../sell_donation_page/edit_dona_product_form.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth import 추가
import 'package:cached_network_image/cached_network_image.dart'; // CachedNetworkImage import 추가

class MyDonaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 기부글 목록'),
      ),
      body: Consumer<UserModel>(
        builder: (context, userModel, child) {
          final myPosts = userModel.myPosts; // my_posts 배열 가져오기

          if (myPosts.isEmpty) {
            return Center(child: Text('등록한 기부글이 없습니다.'));
          }

          // Firestore의 my_posts 배열에 해당하는 기부글 실시간 구독
          return StreamBuilder<List<DonaPostModel>>(
            stream: _getMyDonaPostsStream(myPosts), // 실시간 데이터 스트림 가져오기
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final donaPosts = snapshot.data ?? [];

              if (donaPosts.isEmpty) {
                return Center(child: Text('등록한 기부글이 없습니다.'));
              }

              return ListView.builder(
                itemCount: donaPosts.length,
                itemBuilder: (context, index) {
                  final post = donaPosts[index];
                  final String firstImageUrl = post.img.isNotEmpty
                      ? post.img[0]
                      : 'https://via.placeholder.com/100';

                  return Column(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DonaDetail(donaPost: post),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[300]!, width: 1), // Light gray border color
                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0), // 패딩
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0), // 이미지 모서리 둥글게
                                child: CachedNetworkImage(
                                  imageUrl: firstImageUrl,
                                  width: 105, // 이미지 너비
                                  height: 105, // 이미지 높이
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.0), // 텍스트와 이미지 간의 간격
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.title,
                                    style: TextStyle(
                                      fontSize: 18, // 텍스트 크기
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '상태: ${post.condition}', // 상태 표시
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        _timeAgo(post.createdAt), // 업로드 시간 표시
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4), // 상태와 시간 사이 간격
                                  Text(
                                    post.body, // 상세 내용 표시
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
                            IconButton(
                              icon: Icon(Icons.more_vert), // 수정, 삭제 메뉴 아이콘
                              onPressed: () {
                                _showOptions(context, post); // 옵션 메뉴 표시
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300], // 구분선 색상
                        thickness: 0.5, // 구분선 두께
                        height: 1, // 구분선 높이
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Firestore에서 my_posts 배열에 해당하는 기부 글들 실시간 구독
  Stream<List<DonaPostModel>> _getMyDonaPostsStream(List<String> myPosts) {
    return FirebaseFirestore.instance
        .collection('DonaPosts')
        .where(FieldPath.documentId, whereIn: myPosts)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => DonaPostModel.fromSnapshot(doc))
        .toList());
  }

  // 옵션 메뉴 표시
  void _showOptions(BuildContext context, DonaPostModel post) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('수정하기'),
                onTap: () {
                  Navigator.pop(context); // 옵션 메뉴 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonaProductEditForm(donaId: post.donaId), // 수정 폼으로 이동
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('삭제하기'),
                onTap: () {
                  Navigator.pop(context); // 옵션 메뉴 닫기
                  _confirmDelete(context, post.donaId); // 삭제 확인 다이얼로그 호출
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 삭제 확인 다이얼로그
  void _confirmDelete(BuildContext context, String donaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('정말로 이 기부글을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // '아니오' 선택 시 팝업 닫기
              },
              child: Text('아니오'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // '예' 선택 시 팝업 닫기
                await _deleteDonaPost(context, donaId); // 삭제 메서드 호출
              },
              child: Text('예'),
            ),
          ],
        );
      },
    );
  }

  // 기부글 삭제 메서드
  Future<void> _deleteDonaPost(BuildContext context, String donaId) async {
    try {
      // 현재 사용자의 UID 가져오기
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      // DonaPosts 컬렉션에서 문서 삭제
      await FirebaseFirestore.instance.collection('DonaPosts').doc(donaId).delete();

      // Users 컬렉션의 my_posts 배열에서 해당 문서 ID 삭제
      if (userId != null) {
        await FirebaseFirestore.instance.collection('Users').doc(userId).update({
          'my_posts': FieldValue.arrayRemove([donaId]), // 삭제할 문서 ID
        });
      }

      // ScaffoldMessenger 사용
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('기부글이 삭제되었습니다.')),
        );
      }
    } catch (e) {
      print('Error deleting dona post: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  // 업로드 시간을 현재 시각과 비교하여 상대적으로 표시하는 함수
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
