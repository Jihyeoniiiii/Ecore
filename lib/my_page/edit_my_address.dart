import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_address_search.dart'; // 주소 검색 페이지 추가

class AddressEditForm extends StatefulWidget {
  final String addressId; // 수정할 주소의 ID를 받아오기 위한 필드

  AddressEditForm({required this.addressId});

  @override
  _AddressEditFormState createState() => _AddressEditFormState();
}

class _AddressEditFormState extends State<AddressEditForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isDefaultAddress = false; // 기본 배송지 여부
  bool _isEditingDefault = false; // 기본 배송지를 수정할 때 체크박스 비활성화 여부

  @override
  void dispose() {
    _addressController.dispose();
    _detailAddressController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadExistingData(); // Firestore에서 기존 데이터를 불러옴
  }

  // Firestore에서 기존 데이터 불러오기
  Future<void> _loadExistingData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Firestore에서 해당 주소의 데이터를 가져옴
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('Addresses')
          .doc(widget.addressId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _addressController.text = data['address'] ?? ''; // 주소 필드
          _detailAddressController.text = data['detailAddress'] ?? ''; // 상세주소 필드
          _recipientController.text = data['recipient'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _isDefaultAddress = data['isDefault'] ?? false; // 기본 배송지 여부 설정
          _isEditingDefault = _isDefaultAddress; // 수정할 때 기본 배송지인 경우 체크박스 비활성화
        });
      }
    }
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

  // 폼 데이터 Firestore에 수정하여 저장
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Firestore에서 데이터 수정
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('Addresses')
            .doc(widget.addressId) // 해당 문서 ID로 데이터 업데이트
            .update({
          'address': _addressController.text, // 주소 필드
          'detailAddress': _detailAddressController.text, // 상세주소 필드
          'recipient': _recipientController.text,
          'phone': _phoneController.text,
          'isDefault': _isDefaultAddress, // 기본 배송지 여부 저장
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 기본 배송지로 설정되었을 경우, 다른 주소의 기본 배송지 여부를 false로 업데이트
        if (_isDefaultAddress) {
          await _updateOtherAddresses();
        }

        // 수정 완료 팝업
        _showSuccessDialog();
      }
    }
  }

  // 기본 배송지로 설정된 다른 주소의 'isDefault' 필드를 false로 업데이트
  Future<void> _updateOtherAddresses() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('Addresses')
          .where('isDefault', isEqualTo: true)
          .get();

      for (var doc in querySnapshot.docs) {
        if (doc.id != widget.addressId) {
          await doc.reference.update({'isDefault': false});
        }
      }
    }
  }

  // 폼 수정 성공 팝업
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('배송지가 수정되었습니다.'),
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
      hintStyle: TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      suffixIcon: hintText == '주소 검색'
          ? Icon(Icons.search, color: Colors.grey)
          : null,
    );
  }

  Widget _buildLabel(String labelText) {
    return RichText(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        children: [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('배송지 수정'),
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
                  _buildLabel('주소'),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    readOnly: true,
                    onTap: _openAddressSearch,
                    decoration: _inputDecoration('주소 검색'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '주소를 검색해주세요';
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
                  _buildLabel('상세주소'),
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
                  _buildLabel('수령인'),
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
                  _buildLabel('휴대폰'),
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

              // 기본 배송지 체크 박스
              Row(
                children: [
                  Checkbox(
                    value: _isDefaultAddress,
                    onChanged: _isEditingDefault
                        ? null // 기본 배송지일 때 체크박스를 비활성화
                        : (bool? value) {
                      setState(() {
                        _isDefaultAddress = value ?? false; // 체크 상태 업데이트
                      });
                    },
                  ),
                  Text('기본 배송지로 설정'),
                ],
              ),

              // 수정하기 버튼
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('수정하기', style: TextStyle(fontSize: 16, color: Colors.grey[900])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
