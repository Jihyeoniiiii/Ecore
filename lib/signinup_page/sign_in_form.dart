import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/firebase_auth_state.dart';
import '../cosntants/common_size.dart';
import 'find_password.dart';
import 'sign_up_form.dart';

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
      backgroundColor: Color(0xFFFFFFFF),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FindPasswordScreen()),
                  );
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
              SizedBox(height: common_s_gap / 2),  // 간격을 절반으로 줄임
              _googleSignInButton(context),  // Google Sign-In 버튼 추가
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

  Widget _googleSignInButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey),  // 테두리 추가
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: () async {
        print("Google Sign-In 버튼 클릭됨");

        await _signInWithGoogle(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/google_logo.png', height: 24),  // 구글 로고 이미지
            SizedBox(width: 12),
            Text(
              'Google 계정으로 가입',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        // FirebaseAuth로 구글 계정으로 로그인
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          // 로그인 상태 업데이트 및 Firestore에 사용자 정보 저장
          Provider.of<FirebaseAuthState>(context, listen: false).loginWithGoogle(context, user);
        }
      }
    } catch (error) {
      print("Google 로그인 중 오류 발생: $error");
    }
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
