import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../signinup_page/sign_in_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _cpwController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isEmailSent = false;
  bool _isEmailVerified = false;

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    _cpwController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      // Create a new user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _pwController.text,
      );

      // Get the newly created user
      User? user = userCredential.user;

      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();
        setState(() {
          _isEmailSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이메일 인증을 전송했습니다. 이메일을 확인해 주세요.')),
        );
      }
    } catch (e) {
      print('Error sending verification email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일 인증을 보낼 수 없습니다.')),
      );
    }
  }

  Future<void> _completeSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Sign in the user
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _pwController.text,
        );

        User? user = userCredential.user;
        if (user != null && user.emailVerified) {
          // 이메일 인증 확인 후 Firestore에 사용자 정보 저장
          await _saveUserToFirestore(user);

          // Finalize sign up process
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입이 완료되었습니다.')),
          );

          // Navigate to the sign-in page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInForm()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이메일 인증이 필요합니다.')),
          );
        }
      } catch (e) {
        print('Error completing sign up: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 완료에 실패했습니다.')),
        );
      }
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    try {
      // 이메일에서 username 추출
      String username = user.email!.split('@').first;

      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
        'email': user.email,
        'phone': _phoneController.text,
        'username': username,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              SizedBox(height: 16),
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
              SizedBox(height: 16),
              TextFormField(
                controller: _cpwController,
                cursorColor: Colors.black54,
                obscureText: true,
                decoration: textInputDecor('비밀번호 확인'),
                validator: (text) {
                  if (text != null && text.isNotEmpty && _pwController.text == text) {
                    return null;
                  } else {
                    return '입력한 비밀번호와 일치하지 않습니다.';
                  }
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                cursorColor: Colors.black54,
                decoration: textInputDecor('전화번호'),
                validator: (text) {
                  if (text != null && text.isNotEmpty) {
                    return null;
                  } else {
                    return '전화번호를 입력해 주세요.';
                  }
                },
              ),
              SizedBox(height: 16),
              if (!_isEmailSent) ...[
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _sendVerificationEmail();
                    }
                  },
                  child: Text('인증 이메일 전송'),
                ),
              ] else if (_isEmailSent && !_isEmailVerified) ...[
                ElevatedButton(
                  onPressed: _completeSignUp,
                  child: Text('이메일 인증 확인'),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('이미 계정이 있으신가요? '),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SignInForm()),
                );
              },
              child: Text(
                '로그인하기',
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
      borderRadius: BorderRadius.circular(8.0),
    );
  }

  OutlineInputBorder activeInputBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey[300]!,
      ),
      borderRadius: BorderRadius.circular(8.0),
    );
  }
}
