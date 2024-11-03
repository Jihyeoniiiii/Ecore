import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PointHistoryPage extends StatefulWidget {
  @override
  _PointHistoryPageState createState() => _PointHistoryPageState();
}

class _PointHistoryPageState extends State<PointHistoryPage> {
  final user = FirebaseAuth.instance.currentUser;
  String _filter = 'all'; // 초기 필터: 전체
  int userPoints = 0; // 보유 포인트

  // 튜토리얼 이미지 목록
  final List<String> _tutorialImages = [
    'assets/images/points/001.png',
    'assets/images/points/002.png',
    'assets/images/points/003.png',
    'assets/images/points/004.png',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserPoints(); // 보유 포인트 가져오기
  }

  Future<void> _fetchUserPoints() async {
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(user!.uid).get();
      setState(() {
        userPoints = userDoc['points'] ?? 0; // 보유 포인트 불러오기
      });
    }
  }

  Stream<QuerySnapshot> _getPointHistoryStream() {
    final pointHistoryRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('PointHistory')
        .orderBy('timestamp', descending: true);

    switch (_filter) {
      case 'earn':
        return pointHistoryRef.where('type', isEqualTo: 'earn').snapshots(); // 적립 내역
      case 'expire':
        return pointHistoryRef.where('type', isEqualTo: 'expire').snapshots(); // 소멸 내역
      case 'use':
        return pointHistoryRef.where('type', isEqualTo: 'use').snapshots(); // 사용 내역
      default:
        return pointHistoryRef.snapshots(); // 전체 내역
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('포인트 내역'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '보유 포인트: $userPoints P',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24, // 글씨 크기를 약간 키움
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // 포인트 이용 약관 페이지로 이동 또는 알림
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('포인트 이용 약관 페이지로 이동합니다.')),
                    );
                  },
                  child: Text(
                    '포인트 이용 약관',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _showTutorial,
                  child: Text('포인트 안내 보기 >'),
                ),
              ],
            ),
          ),
          // 필터 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('전체', 'all'),
                _buildFilterButton('적립', 'earn'),
                _buildFilterButton('사용', 'use'),
                _buildFilterButton('소멸', 'expire'),
              ],
            ),
          ),
          SizedBox(height: 16), // 필터 버튼과 내역 사이 여백 추가
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPointHistoryStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final pointHistory = snapshot.data!.docs;

                if (pointHistory.isEmpty) {
                  return Center(child: Text('포인트 내역이 없습니다.'));
                }

                return ListView.builder(
                  itemCount: pointHistory.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 패딩 추가
                  itemBuilder: (context, index) {
                    final pointData = pointHistory[index];
                    final data = pointData.data() as Map<String, dynamic>?; // 데이터를 Map<String, dynamic>으로 캐스팅
                    if (data == null) {
                      return ListTile(
                        title: Text('데이터를 불러올 수 없습니다.'),
                      );
                    }

                    final timestamp = (data['timestamp'] as Timestamp).toDate();
                    final dateString = DateFormat('yyyy-MM-dd').format(timestamp);
                    final point = data['point'] as int;
                    final type = data.containsKey('type') ? data['type'] : 'earn'; // containsKey 사용 가능
                    final name = data.containsKey('name') ? data['name'] : '기타'; // 'name' 필드 가져오기

                    // 적립/사용/소멸 표시 방식 및 name 필드에 따른 적립 유형 표시
                    final pointDisplay = type == 'use' ? '-${point}P' : '+${point}P';
                    final typeDisplay = type == 'use' ? '사용' : type == 'expire' ? '소멸' : '$name 적립';

                    return Card(
                      color: Colors.white,
                      elevation: 4, // 그림자 효과
                      margin: const EdgeInsets.only(bottom: 12.0), // 카드 사이의 간격
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // 모서리를 둥글게
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // 내부 여백 추가
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateString,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600], // 날짜 색상 변경
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '$typeDisplay: $pointDisplay',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

              },
            ),
          ),
        ],
      ),
    );
  }

  // 포인트 튜토리얼을 보여주는 함수
  void _showTutorial() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // 배경을 반투명하게 설정
      builder: (context) {
        return Center(
          child: Container(
            width: 300,
            height: 400,
            child: TutorialPage(tutorialImages: _tutorialImages),
          ),
        );
      },
    );
  }


  // 필터 버튼 생성
  ElevatedButton _buildFilterButton(String label, String value) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _filter = value; // 필터 변경
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _filter == value ? Color.fromRGBO(230, 245, 220, 1.0) : Colors.grey[300], // 선택된 필터 색상 변경
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 필터 버튼을 둥글게
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // 버튼 크기 조절
      ),
      child: Text(label),
    );
  }
}

class TutorialPage extends StatefulWidget {
  final List<String> tutorialImages;

  TutorialPage({required this.tutorialImages});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  widget.tutorialImages[_currentIndex],
                  width: 300, // 원하는 이미지 너비
                  height: 400, // 원하는 이미지 높이
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        // 닫기 버튼 (상단 오른쪽, 흰색 X)
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop(); // 팝업 닫기
            },
          ),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: GestureDetector(
            onTap: _currentIndex < widget.tutorialImages.length - 1
                ? () {
              setState(() {
                _currentIndex++;
              });
            }
                : null, // 마지막 이미지일 때 비활성화
            child: Text(
              '다음',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 24,
          child: GestureDetector(
            onTap: _currentIndex > 0
                ? () {
              setState(() {
                _currentIndex--;
              });
            }
                : null, // 첫 번째 이미지일 때 비활성화
            child: Text(
              '이전',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
