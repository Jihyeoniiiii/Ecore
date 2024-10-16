import 'package:ecore/my_page/my_address_form.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../my_page/edit_my_address.dart';

class AddressSelectPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddressSelected; // 선택된 주소를 전달하기 위한 함수

  AddressSelectPage({required this.onAddressSelected});

  @override
  _AddressSelectPageState createState() => _AddressSelectPageState();
}

class _AddressSelectPageState extends State<AddressSelectPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String? _selectedAddressId; // 선택된 주소의 ID를 저장할 변수

  Future<void> _setDefaultAddress(String newAddressId) async {
    // 현재 기본 배송지의 ID를 가져옵니다.
    final currentDefault = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.uid)
        .collection('Addresses')
        .where('isDefault', isEqualTo: true)
        .get();

    // 현재 기본 배송지가 있다면, 해당 주소의 isDefault를 false로 설정합니다.
    if (currentDefault.docs.isNotEmpty) {
      final defaultAddressId = currentDefault.docs.first.id;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUser!.uid)
          .collection('Addresses')
          .doc(defaultAddressId)
          .update({'isDefault': false});
    }

    // 새로 선택한 주소의 isDefault를 true로 설정합니다.
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.uid)
        .collection('Addresses')
        .doc(newAddressId)
        .update({'isDefault': true});
  }

  Future<void> _deleteAddress(String addressId) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.uid)
        .collection('Addresses')
        .doc(addressId)
        .delete();
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 11) {
      return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 7)}-${phoneNumber.substring(7)}';
    }
    return phoneNumber; // 길이가 11이 아닐 경우 원래 전화번호 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('배송지 정보', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
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

          return Column(
            children: [
              // 배송지 추가하기 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, // 버튼 너비를 화면 너비에 맞춤
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
                      padding: EdgeInsets.symmetric(vertical: 12), // 높이 조정
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.lightBlue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // 둥근 모서리
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.lightBlue),
                        SizedBox(width: 8),
                        Text(
                          '배송지 추가하기',
                          style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: addressDocs.length,
                  itemBuilder: (context, index) {
                    final doc = addressDocs[index];
                    final addressData = doc.data() as Map<String, dynamic>;
                    final addressId = doc.id; // 문서 ID 가져오기

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 3,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
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
                                                color: Colors.black,
                                              ),
                                            ),
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
                                        // 포맷된 전화번호 출력
                                        Text(_formatPhoneNumber(addressData['phone'] ?? '전화번호 없음')),
                                        SizedBox(height: 4),
                                        Text(
                                          '${addressData['address']} ${addressData['detailAddress'] ?? ''}',
                                          style: TextStyle(color: Colors.grey[900]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Radio<String>(
                                    value: addressId,
                                    groupValue: _selectedAddressId,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedAddressId = value; // 선택된 주소 ID 저장
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // 수정 및 삭제 버튼
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddressEditForm(addressId: addressId),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '수정',
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // 삭제 버튼을 기본 배송지가 아닐 경우에만 표시
                                  if (addressData['isDefault'] != true)
                                    TextButton(
                                      onPressed: () async {
                                        await _deleteAddress(addressId); // 삭제 기능 추가
                                      },
                                      child: Text(
                                        '삭제',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 변경하기 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, // 버튼 너비를 화면 너비에 맞춤
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_selectedAddressId != null) {
                        // 선택된 주소를 기본 주소로 업데이트
                        await _setDefaultAddress(_selectedAddressId!);

                        // 기본 주소 섹션을 업데이트하는 콜백 함수 호출
                        final selectedAddressDoc = await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(_currentUser!.uid)
                            .collection('Addresses')
                            .doc(_selectedAddressId)
                            .get();

                        widget.onAddressSelected(selectedAddressDoc.data() as Map<String, dynamic>); // 주소를 선택했을 때 호출

                        Navigator.pop(context); // 이전 페이지로 돌아가기
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('주소를 선택해 주세요.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12), // 높이 조정
                      backgroundColor: Colors.lightBlue, // 버튼 배경색을 테두리 색으로 설정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // 둥근 모서리
                      ),
                    ),
                    child: Text(
                      '변경하기',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
