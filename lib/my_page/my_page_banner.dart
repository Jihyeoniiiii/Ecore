import 'package:ecore/my_page/point_history_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cosntants/common_color.dart';
import 'my_page_button.dart';
import 'my_page_list.dart';

class MyPageBanner extends StatelessWidget {
  const MyPageBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text('마이페이지', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'NanumSquare',)),
        ),
      ),
      body: BodyContents(),
    );
  }
}

class BodyContents extends StatefulWidget {
  const BodyContents({super.key});

  @override
  _BodyContentsState createState() => _BodyContentsState();
}

class _BodyContentsState extends State<BodyContents> {
  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> _refreshData() async {
    setState(() {
      // 상태를 업데이트하여 FutureBuilder를 다시 빌드하게 만듭니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasError) {
          return Center(child: Text('Error fetching user info'));
        } else if (!userSnapshot.hasData) {
          return Center(child: Text('No user logged in'));
        }

        User user = userSnapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Users').doc(user.uid).get(),
          builder: (context, userDocSnapshot) {
            if (userDocSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (userDocSnapshot.hasError) {
              return Center(child: Text('Error fetching user details'));
            } else if (!userDocSnapshot.hasData || !userDocSnapshot.data!.exists) {
              return Center(child: Text('User details not found'));
            }

            var userData = userDocSnapshot.data!.data() as Map<String, dynamic>?;
            String userName = userData?['username'] ?? 'Unknown User';
            String userPoints = userData?['points']?.toString() ?? '0';
            String? profileImageUrl = userData?['profile_img']; // 프로필 이미지 URL 가져오기

            return RefreshIndicator(
              onRefresh: _refreshData, // 스와이프 시 새로고침 동작 추가
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(), // 스크롤 가능하도록 설정
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 프로필 사진 띄우기
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : AssetImage('assets/images/defualt_profile.jpg') as ImageProvider,
                          ),
                          SizedBox(width: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$userName 님 반갑습니다.', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('포인트 보유 현황 : $userPoints', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PointHistoryPage(), // 포인트 내역 페이지로 이동
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  backgroundColor: baseColor,
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                ),
                                child: Text(
                                  '포인트 내역 확인',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      MyPageBtn(),
                      MyPageList(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
