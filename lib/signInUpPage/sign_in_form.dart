import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cosntants/common_size.dart';
import '../models/firebase_auth_state.dart';
import 'sign_up_form.dart';  // SignUpForm 클래스가 정의된 파일을 import

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(common_gap),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 16),
              Image.asset('assets/images/ecore_logo.png'),
              TextFormField(
                controller: _emailController,
                cursorColor: Colors.black54,
                decoration: textInputDecor('이메일'),
                validator: (text) {
                  if (text != null && text.isNotEmpty && text.contains("@")) {
                    return null;
                  } else {
                    return '정확한 이메일 주소를 입력해 주세요.';
                  }
                },
              ),
              SizedBox(height: common_xs_gap),
              TextFormField(
                controller: _pwController,
                cursorColor: Colors.black54,
                obscureText: true,
                decoration: textInputDecor('비밀번호'),
                validator: (text) {
                  if (text != null && text.isNotEmpty && text.length > 2) {
                    return null;
                  } else {
                    return '비밀번호를 입력해 주세요.';
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  // Add the forgot password functionality here
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '아이디/비밀번호 찾기',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: common_s_gap),
              _submitButton(context),
              SizedBox(height: common_s_gap),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('계정이 없으신가요? '),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUpForm()));
              },
              child: Text(
                '가입하기',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextButton _submitButton(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Color.fromRGBO(0, 0, 128, 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          print('Validation success!!');
          Provider.of<FirebaseAuthState>(context, listen: false).login(
            context,
            email: _emailController.text,
            password: _pwController.text,
          );
        }
      },
      child: Text(
        '로그인',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

InputDecoration textInputDecor(String hint) {
  return InputDecoration(
    hintText: hint,
    enabledBorder: activeInputBorder(),
    focusedBorder: activeInputBorder(),
    errorBorder: errorInputBorder(),
    focusedErrorBorder: errorInputBorder(),
    filled: true,
    fillColor: Colors.grey[100]!,
  );
}

OutlineInputBorder errorInputBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.redAccent,
    ),
    borderRadius: BorderRadius.circular(common_s_gap),
  );
}

OutlineInputBorder activeInputBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey[300]!,
    ),
    borderRadius: BorderRadius.circular(common_s_gap),
  );
}

const MaterialColor white = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0x0FFFFFFF),
    100: Color(0x1FFFFFFF),
    200: Color(0x2FFFFFFF),
    300: Color(0x3FFFFFFF),
    400: Color(0x4FFFFFFF),
    500: Color(0x5FFFFFFF),
    600: Color(0x6FFFFFFF),
    700: Color(0x7FFFFFFF),
    800: Color(0x8FFFFFFF),
    900: Color(0x9FFFFFFF),
  },
);
