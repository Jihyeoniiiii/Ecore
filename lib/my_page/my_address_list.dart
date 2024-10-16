import 'package:ecore/my_page/my_address_form.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_my_address.dart';

class AddressListPage extends StatefulWidget {
  @override
  _AddressListPageState createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 11) {
      return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 7)}-${phoneNumber.substring(7)}';
    }
    return phoneNumber; // 길이가 11이 아닐 경우 원래 전화번호 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경색 흰색
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경색 흰색
        title: Text('배송지 관리'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(_currentUser?.uid)
            .collection('Addresses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final addressDocs = snapshot.data?.docs ?? [];

          // 기본 배송지와 일반 배송지 분리
          List<QueryDocumentSnapshot> defaultAddresses = [];
          List<QueryDocumentSnapshot> normalAddresses = [];

          for (var doc in addressDocs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['isDefault'] == true) {
              defaultAddresses.add(doc);
            } else {
              normalAddresses.add(doc);
            }
          }

          if (defaultAddresses.isEmpty && normalAddresses.isEmpty) {
            // 배송지가 없을 때 배송지 추가 버튼을 화면 중앙에 배치
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '등록된 배송지가 없습니다.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '배송지 추가 버튼을 눌러 주소를 입력해주세요.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 16), // 원하는 세로 간격 설정
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4, // 화면 너비의 80%만큼 버튼 길이 설정
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressForm(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue[50], // 버튼 배경색
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0), // 둥근 테두리
                        ),
                      ),
                      child: Text(
                        '배송지 추가',
                        style: TextStyle(color: Colors.grey[800], fontSize: 16), // 텍스트 흰색
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 주소 추가하기 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressForm(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white, // 버튼 배경색 흰색
                    side: BorderSide(color: Colors.lightBlue, width: 2), // 테두리 색상 및 두께 하늘색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0), // 둥근 테두리
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.lightBlue), // + 아이콘 하늘색
                      SizedBox(width: 8),
                      Text(
                        '배송지 추가하기',
                        style: TextStyle(color: Colors.lightBlue, fontSize: 16), // 텍스트 하늘색
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: defaultAddresses.length + normalAddresses.length,
                  itemBuilder: (context, index) {
                    // 기본 배송지와 일반 배송지를 순서대로 나열
                    final doc = index < defaultAddresses.length
                        ? defaultAddresses[index]
                        : normalAddresses[index - defaultAddresses.length];
                    final addressData = doc.data() as Map<String, dynamic>;
                    final addressId = doc.id; // 문서 ID 가져오기

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 3,
                        color: Colors.white, // Card의 배경색을 흰색으로 설정
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    addressData['recipient'] ?? '이름 없음',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black, // 이름 검정색
                                    ),
                                  ),
                                  // 기본 배송지 여부 표시
                                  if (addressData['isDefault'] == true)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '기본 배송지',
                                        style: TextStyle(color: Colors.blue[800], fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(_formatPhoneNumber(addressData['phone'] ?? '전화번호 없음')), // 포맷된 전화번호 출력
                              SizedBox(height: 4),
                              // 주소와 상세주소를 같은 줄에 같은 색상으로 표시
                              Text(
                                '${addressData['address']} ${addressData['detailAddress'] ?? ''}',
                                style: TextStyle(color: Colors.grey[900]), // 주소 및 상세주소 동일한 색상으로 표시
                              ),
                              Align(
                                alignment: Alignment.centerRight, // 수정, 삭제 버튼을 오른쪽에 정렬
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            // AddressEditForm에 addressId 전달
                                            builder: (context) => AddressEditForm(addressId: addressId),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        '수정',
                                        style: TextStyle(color: Colors.grey[800]), // 수정 버튼 색상
                                      ),
                                    ),
                                    // 기본 배송지에는 삭제 버튼을 표시하지 않음
                                    if (addressData['isDefault'] != true)
                                      TextButton(
                                        onPressed: () async {
                                          // 삭제 기능 추가
                                          await FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(_currentUser?.uid)
                                              .collection('Addresses')
                                              .doc(doc.id)
                                              .delete();
                                        },
                                        child: Text(
                                          '삭제',
                                          style: TextStyle(color: Colors.red), // 삭제 버튼 빨간색
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
