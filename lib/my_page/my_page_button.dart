import 'package:ecore/my_page/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cart_page/order_list.dart';
import '../cosntants/common_color.dart';
import '../models/firestore/user_model.dart';
import '../my_market/create_my_market.dart';
import '../my_market/my_market_banner.dart';
import '../models/firestore/market_model.dart';
import 'my_review_page.dart';

class MyPageBtn extends StatefulWidget {
  const MyPageBtn({super.key});

  @override
  State<MyPageBtn> createState() => _MyPageBtnState();
}

class _MyPageBtnState extends State<MyPageBtn> {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Get current userId
  MarketModel? market;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    _fetchMarketData();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (userId.isNotEmpty) {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .get();

        if (userSnapshot.exists) {
          if (mounted) { // mounted 속성 확인
            setState(() {
              userModel = UserModel.fromSnapshot(userSnapshot);
            });
          }
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _fetchMarketData() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      try {
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userSnapshot.docs.first;
          String? marketId = userDoc['marketId'] ?? ''; // 첫 번째 마켓 ID 사용

          if (marketId != null && marketId.isNotEmpty) {
            DocumentSnapshot marketDoc = await FirebaseFirestore.instance
                .collection('Markets')
                .doc(marketId)
                .get();

            if (marketDoc.exists) {
              if (mounted) {
                setState(() {
                  market = MarketModel.fromSnapshot(marketDoc); // MarketModel로 변환
                });
              }
            }
          }
        }
      } catch (e) {
        print('Error fetching market data: $e');
      }
    }
  }


  void _showMarketCreationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Market Not Found'),
          content: Text('생성하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
            ),
            TextButton(
              child: Text('생성'),
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SellerInfoForm(), // 마켓 생성 화면으로 이동
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // 비동기 작업이나 타이머가 있다면 여기서 정리할 수 있습니다.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (market != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyMarketBanner(market: market!), // MarketModel 객체 전달
                        ),
                      );
                    } else {
                      // market이 null인 경우 마켓 생성 여부를 묻는 다이얼로그 표시
                      _showMarketCreationDialog(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: baseColor, // 배경색 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
                    ),
                    padding: EdgeInsets.zero, // 기본 패딩 제거
                  ),
                  child: Container(
                    height: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/market.png',
                          height: 40,
                        ),
                        Text(
                          '나의 마켓',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textColor
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderList()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: baseColor, // 배경색 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
                    ),
                    padding: EdgeInsets.zero, // 기본 패딩 제거
                  ),
                  child: Container(
                    height: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/cart.png',
                          height: 40,
                        ),
                        Text(
                          '주문-배송',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                              color: textColor
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyReviewPage(userModel: userModel!,)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: baseColor, // 배경색 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
                    ),
                    padding: EdgeInsets.zero, // 기본 패딩 제거
                  ),
                  child: Container(
                    height: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/review.png',
                          height: 40,
                        ),
                        Text(
                          '리뷰',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                              color: textColor
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingPage(userId: userId),
                      ),
                    );

                    // result가 true라면 데이터를 다시 불러옵니다.
                    if (result == true) {
                      _fetchMarketData();  // 마켓 데이터를 다시 불러옵니다.
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: baseColor, // 배경색 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
                    ),
                    padding: EdgeInsets.zero, // 기본 패딩 제거
                  ),
                  child: Container(
                    height: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/setting.png',
                          height: 40,
                        ),
                        Text(
                          '설정',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                              color: textColor
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0), // 위아래 여백을 좀 더 추가
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // 둥근 모서리 없앰
              ),
            ),
            onPressed: () {
              // 버튼 클릭 시 동작
            },
            child: Image.asset(
              'assets/images/마이페이지배너1.jpeg', // 배너 이미지 경로
              fit: BoxFit.cover, // 이미지가 버튼 크기에 맞게 조절되도록 함
              width: double.infinity, // 가로로 화면 전체를 채우도록 설정
            ),
          ),


          SizedBox(height: 5),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0), // 위아래 여백을 좀 더 추가
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // 둥근 모서리 없앰
              ),
            ),
            onPressed: () {
              // 버튼 클릭 시 동작
            },
            child: Image.asset(
              'assets/images/마이페이지배너2.jpeg', // 배너 이미지 경로
              fit: BoxFit.cover, // 이미지가 버튼 크기에 맞게 조절되도록 함
              width: double.infinity, // 가로로 화면 전체를 채우도록 설정
            ),
          ),


        ],
      ),
    );
  }
}