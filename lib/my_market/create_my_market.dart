import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:intl/intl.dart';

import 'create_market_info.dart'; // For date formatting

class SellerInfoForm extends StatefulWidget {
  @override
  _SellerInfoFormState createState() => _SellerInfoFormState();
}

class _SellerInfoFormState extends State<SellerInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String? _gender;
  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    _dobController.text = ''; // Initial empty text for date of birth
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // 뒤로가기 기능
          },
        ),
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
                  '1.1 판매자 정보 입력',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
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
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // 처리 로직 추가
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('정보가 제출되었습니다.')));
                      }
                    },
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MarketInfoPage()),
                        );
                      },
                      child: Text('다음'),
                    ),
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
          labelStyle: TextStyle(
            color: Colors.black,
          ),
        ),
        readOnly: readOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }
}