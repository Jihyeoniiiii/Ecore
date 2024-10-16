import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditSellerInfoForm extends StatefulWidget {
  final String marketId; // 마켓의 고유 ID

  EditSellerInfoForm({required this.marketId});

  @override
  _EditSellerInfoFormState createState() => _EditSellerInfoFormState();
}

class _EditSellerInfoFormState extends State<EditSellerInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _sellernameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String? _gender;
  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    _loadSellerData(); // 마켓 정보 로드
  }

  // Firestore에서 marketId로 마켓 데이터를 가져옴
  Future<void> _loadSellerData() async {
    try {
      DocumentSnapshot marketDoc = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId) // marketId를 사용하여 해당 마켓 정보를 로드
          .get();

      if (marketDoc.exists) {
        Map<String, dynamic>? marketData =
        marketDoc.data() as Map<String, dynamic>?;

        _sellernameController.text = marketData?['seller_name'] ?? '';
        _dobController.text = marketData?['dob'] ?? '';
        _phoneController.text = marketData?['phone'] ?? '';
        _emailController.text = marketData?['email'] ?? '';
        _addressController.text = marketData?['address'] ?? '';
        _gender = marketData?['gender'];
        _dob = DateTime.tryParse(marketData?['dob'] ?? '');
      }
    } catch (e) {
      print('마켓 정보 로드 실패: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(_dob!);
      });
    }
  }

  Future<void> _updateSellerInfo() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // marketId를 이용해 마켓 정보를 업데이트
        await FirebaseFirestore.instance
            .collection('Markets')
            .doc(widget.marketId)
            .update({
          'seller_name': _sellernameController.text,
          'dob': _dobController.text,
          'gender': _gender,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'address': _addressController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('마켓 정보가 수정되었습니다.')),
        );

        Navigator.pop(context); // 이전 페이지로 돌아가기
      } catch (e) {
        print('마켓 정보 수정 실패: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('마켓 정보 수정 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('판매자 정보 수정', style: TextStyle(fontFamily: 'NanumSquare',)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '마켓 정보 수정',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _sellernameController,
                  label: '판매자명',
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '판매자명을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _dobController,
                  label: '생년월일',
                  isRequired: true,
                  readOnly: true,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '생년월일을 선택해 주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  '성별',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('남성'),
                        value: 'male',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('여성'),
                        value: 'female',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                _buildTextField(
                  controller: _phoneController,
                  label: '연락처',
                  isRequired: true,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '연락처를 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _emailController,
                  label: '메일',
                  isRequired: true,
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
                _buildTextField(
                  controller: _addressController,
                  label: '주소',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // 주소 찾기 기능 추가
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '주소를 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateSellerInfo,
                    child: Text('수정 완료'),
                  ),
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
