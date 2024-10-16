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
            child: Text(
              '보유 포인트: $userPoints P',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24, // 글씨 크기를 약간 키움
              ),
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

                    // 적립/사용/소멸 표시 방식
                    final pointDisplay = type == 'use' ? '-${point}P' : '+${point}P';
                    final typeDisplay = type == 'use' ? '사용' : type == 'expire' ? '소멸' : '적립';

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
