import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 임포트
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage를 위한 임포트

import '../home_page/home_page_menu.dart';
import '../models/firestore/market_model.dart';
import 'business_check.dart';
import 'my_market_banner.dart';

class MarketInfoPage extends StatefulWidget {
  final String seller_name;
  final String dob;
  final String? gender;
  final String phone;
  final String email;
  final String address;

  MarketInfoPage({
    required this.seller_name,
    required this.dob,
    required this.gender,
    required this.phone,
    required this.email,
    required this.address,
  });

  @override
  _MarketInfoPageState createState() => _MarketInfoPageState();
}

class _MarketInfoPageState extends State<MarketInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _marketNameController = TextEditingController();
  final _marketDescriptionController = TextEditingController();
  final _csPhoneController = TextEditingController();
  final _csemailController = TextEditingController();

  String? _businessNumber; // Holds the business number

  String? _profileImageUrl;
  XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _uploadImage(String marketId) async {
    if (_image != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('market_images')
            .child('$marketId.jpg');

        await ref.putFile(File(_image!.path));
        String imageUrl = await ref.getDownloadURL();

        setState(() {
          _profileImageUrl = imageUrl;
        });
      } catch (e) {
        print('이미지 업로드 오류: $e');
      }
    }
  }

  Future<void> _submitMarketInfo() async {
    // 로딩 중 다이얼로그 표시
    _showLoadingDialog();

    if (_formKey.currentState?.validate() ?? false) {
      String marketName = _marketNameController.text;
      List<String> marketDescription = _marketDescriptionController.text.split('\n');
      String csPhone = _csPhoneController.text;
      String csemail = _csemailController.text;

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      try {
        DocumentReference docRef = await FirebaseFirestore.instance.collection('Markets').add({
          'name': marketName,
          'feedPosts': marketDescription,
          'cs_phone': csPhone,
          'cs_email': csemail,
          'business_number': _businessNumber ?? '', // 사업자 번호 추가
          'userId': userId,
          'seller_name': widget.seller_name,
          'dob': widget.dob,
          'gender': widget.gender,
          'phone': widget.phone,
          'email': widget.email,
          'address': widget.address,
          'img': _profileImageUrl ?? '',
          'bannerImg': 'https://via.placeholder.com/150',
        });

        String marketId = docRef.id;

        if (_image != null) {
          await _uploadImage(marketId);

          await FirebaseFirestore.instance
              .collection('Markets')
              .doc(marketId)
              .update({
            'img': _profileImageUrl,
          });
        }

        if (userId != null) {
          await FirebaseFirestore.instance.collection('Users').doc(userId).update({
            'marketId': marketId,
          });
        }

        DocumentSnapshot marketDoc = await FirebaseFirestore.instance
            .collection('Markets')
            .doc(marketId)
            .get();
        MarketModel market = MarketModel.fromSnapshot(marketDoc);

        // 로딩 중 다이얼로그 닫기
        Navigator.of(context).pop();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('마켓 정보가 제출되었습니다.')),
        );
      } catch (e) {
        // 로딩 중 다이얼로그 닫기
        Navigator.of(context).pop();

        print(e);
      }
    } else {
      // 폼이 유효하지 않을 때 로딩 중 다이얼로그 닫기
      Navigator.of(context).pop();
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 바깥을 눌러도 닫히지 않도록 설정
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("마켓 정보 등록 중..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToBusinessCheckPage() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => BusinessCheckPage()),
    );

    if (result != null) {
      setState(() {
        _businessNumber = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사업자 등록번호가 입력되었습니다: $result')),
      );
    }
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '프로필 사진',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundImage:
            _image != null ? FileImage(File(_image!.path)) : null,
            child: _image == null
                ? Icon(
              Icons.add_a_photo,
              size: 50,
              color: Colors.grey,
            )
                : null,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마켓 정보 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(),
                _buildTextField(
                  controller: _marketNameController,
                  label: '마켓 이름',
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '마켓 이름을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _marketDescriptionController,
                  label: '소개글',
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '소개글을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _csPhoneController,
                  label: 'CS 전화번호',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CS 전화번호를 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _csemailController,
                  label: 'CS 이메일',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해 주세요.';
                    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return '유효한 이메일 주소를 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _navigateToBusinessCheckPage,
                  child: Text('사업자 번호 확인하기'),
                ),
                SizedBox(height: 10),
                Text(
                  _businessNumber != null
                      ? '사업자 번호: $_businessNumber'
                      : '사업자 등록 번호가 존재하면 인증마크가 부여됩니다',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitMarketInfo,
                  child: Text('제출'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool readOnly = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
        readOnly: readOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }
}
