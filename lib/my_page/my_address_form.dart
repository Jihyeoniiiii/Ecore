import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_address_search.dart'; // 주소 검색 페이지 추가

class AddressForm extends StatefulWidget {
  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isDefaultAddress = false; // 기본 배송지 여부

  @override
  void dispose() {
    _addressController.dispose();
    _detailAddressController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // 주소 필드 클릭 시 주소 검색 페이지 열기
  Future<void> _openAddressSearch() async {
    final selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressAndPlaceSearchPage(), // 주소 검색 페이지로 이동
      ),
    );

    if (selectedAddress != null) {
      setState(() {
        _addressController.text = selectedAddress; // 선택한 주소를 주소 필드에 입력
      });
    }
  }

  // 폼 데이터 Firestore에 저장
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // 현재 로그인된 사용자의 uid 가져오기
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // 주소 컬렉션에 저장된 주소가 하나도 없는지 확인
        QuerySnapshot addressSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('Addresses')
            .get();

        bool isFirstAddress = addressSnapshot.docs.isEmpty; // 주소가 없는지 여부

        // Firestore에 기본 배송지인지 체크하여 기존 기본 배송지를 업데이트
        if (_isDefaultAddress || isFirstAddress) {
          // 만약 기본 배송지로 설정되었거나, 첫 번째 주소라면
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.uid)
              .collection('Addresses')
              .where('isDefault', isEqualTo: true)
              .get()
              .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.update({'isDefault': false}); // 기존 기본 배송지의 isDefault를 false로 업데이트
            }
          });
        }

        // Firestore에 데이터 저장 (주소와 상세주소 분리해서 저장)
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('Addresses') // 서브컬렉션에 주소를 추가
            .add({
          'address': _addressController.text,  // 주소 저장
          'detailAddress': _detailAddressController.text, // 상세주소 저장
          'recipient': _recipientController.text, // 수령인 저장
          'phone': _phoneController.text,
          'isDefault': _isDefaultAddress || isFirstAddress, // 기본 배송지 여부 저장 (첫 주소는 자동으로 기본 배송지로 설정)
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 폼 제출 완료 팝업
        _showSuccessDialog();
      }
    }
  }


  // 폼 제출 성공 팝업
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 팝업 외부를 누르면 닫히지 않도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('배송지 추가가 완료되었습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
                Navigator.of(context).pop(); // 이전 페이지로 이동
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey), // 힌트 텍스트 색상
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5), // 기본 테두리
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2), // 포커스 시 테두리
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2), // 에러 테두리
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2), // 에러 발생 시 포커스 테두리
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16), // 패딩
      suffixIcon: hintText == '주소 검색'
          ? Icon(Icons.search, color: Colors.grey) // 주소 필드에만 검색 아이콘 추가
          : null,
    );
  }

  // 필드 라벨과 * 표시를 위한 위젯
  Widget _buildLabel(String labelText) {
    return RichText(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          color: Colors.black, // 기본 라벨 색상
          fontSize: 14,
        ),
        children: [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red, // 별표 색상
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경 흰색
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경 흰색
        title: Text('배송지 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 주소 입력 필드
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('주소'), // 라벨 + 별표
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    readOnly: true, // 주소 입력 필드는 사용자가 직접 입력하지 않도록 설정
                    onTap: _openAddressSearch, // 주소 검색 페이지 열기
                    decoration: _inputDecoration('주소 검색'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '주소를 검색해주세요'; // 에러 메시지
                      }
                      return null;
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 상세 주소 입력 필드
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('상세주소'), // 라벨 + 별표
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _detailAddressController,
                    decoration: _inputDecoration('나머지 주소를 입력해주세요 (선택사항)'),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 수령인 입력 필드
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('수령인'), // 라벨 + 별표
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _recipientController,
                    decoration: _inputDecoration('수령인을 입력해주세요'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '수령인을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 휴대폰 번호 입력 필드
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('휴대폰'), // 라벨 + 별표
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('숫자만 입력해주세요'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '휴대폰 번호를 입력해주세요.';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return '유효한 휴대폰 번호를 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 기본 배송지 설정 체크박스 추가
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _isDefaultAddress,
                    onChanged: (bool? value) {
                      setState(() {
                        _isDefaultAddress = value ?? false;
                      });
                    },
                  ),
                  Text('기본 배송지로 설정'),
                ],
              ),

              // 추가하기 버튼
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('추가하기', style: TextStyle(fontSize: 16, color: Colors.grey[900])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
