import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../donation_page/dona_detail.dart';
import '../models/firestore/dona_post_model.dart';
import '../models/firestore/user_model.dart';
import '../sell_donation_page/edit_dona_product_form.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth import 추가

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

                  return ListTile(
                    leading: Image.network(
                      firstImageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      post.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.more_vert), // 세로 점 아이콘
                      onPressed: () {
                        _showOptions(context, post);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonaDetail(donaPost: post),
                        ),
                      );
                    },
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
}
