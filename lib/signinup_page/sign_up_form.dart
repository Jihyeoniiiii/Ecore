import 'package:ecore/signinup_page/terms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../signinup_page/sign_in_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}
//
// const String privacyPolicyContent = '개인정보 처리방침 내용...'; // 여기에 개인정보 처리방침 내용을 입력하세요.
// const String thirdPartyInfoContent = '제3자 제공 동의 내용...'; // 여기에 제3자 제공 동의 내용을 입력하세요.
// const String pointTermsContent = '포인트 약관 내용...'; // 여기에 포인트 약관 내용을 입력하세요.


class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _cpwController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();


  bool _isEmailSent = false;
  bool _isEmailVerified = false;

  // 동의 체크 상태 추가
  bool _isAllChecked = false;
  bool _isPrivacyPolicyChecked = false;
  bool _isThirdPartyInfoChecked = false;
  bool _isPointTermsChecked = false;

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
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _pwController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification();
        if (mounted) {
          setState(() {
            _isEmailSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이메일 인증을 전송했습니다. 이메일을 확인해 주세요.')),
          );
        }
      }
    } catch (e) {
      print('Error sending verification email: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이메일 인증을 보낼 수 없습니다.')),
        );
      }
    }
  }

  Future<void> _completeSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _pwController.text,
        );

        User? user = userCredential.user;

        if (user != null) {
          await user.reload();
          user = FirebaseAuth.instance.currentUser;

          if (user!.emailVerified) {
            await _saveUserToFirestore(user);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('회원가입이 완료되었습니다.')),
              );
            }

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInForm()),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('이메일 인증이 필요합니다.')),
              );
            }
          }
        }
      } catch (e) {
        print('Error completing sign up: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입 완료에 실패했습니다.')),
          );
        }
      }
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    try {
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
              Image.asset('assets/images/logo.png'),
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

              // 동의 항목 추가
              Row(
                children: [
                  Transform.scale(
                    scale: 1.0, // 전체 동의 체크박스 크기를 키움
                    child: Checkbox(
                      value: _isAllChecked,
                      onChanged: (value) {
                        setState(() {
                          _isAllChecked = value!;
                          _isPrivacyPolicyChecked = value;
                          _isThirdPartyInfoChecked = value;
                          _isPointTermsChecked = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8), // 체크박스와 텍스트 사이에 간격 추가
                  Expanded(
                    child: Text(
                      '전체 동의',
                      style: TextStyle(
                        fontSize: 18, // 글씨 크기 조정
                        fontWeight: FontWeight.bold, // 글씨를 굵게
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 8),
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8, // 체크박스 크기 조정
                    child: Checkbox(
                      value: _isPrivacyPolicyChecked,
                      onChanged: (value) {
                        setState(() {
                          _isPrivacyPolicyChecked = value!;
                          _updateAllCheckedStatus();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8), // 체크박스와 텍스트 사이에 간격 추가
                  Expanded(
                    child: Text('(필수) 개인정보 처리방침 동의'),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 16), // 화살표 아이콘 추가
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsDetailPage(
                            title: '개인정보 처리방침',
                            // content: privacyPolicyContent, // 개인정보 처리방침 내용
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8, // 체크박스 크기 조정
                    child: Checkbox(
                      value: _isThirdPartyInfoChecked,
                      onChanged: (value) {
                        setState(() {
                          _isThirdPartyInfoChecked = value!;
                          _updateAllCheckedStatus();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8), // 체크박스와 텍스트 사이에 간격 추가
                  Expanded(
                    child: Text('(필수) 개인정보 제3자 제공 동의'),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 16), // 화살표 아이콘 추가
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsDetailPage(
                            title: '개인정보 제3자 정보 제공 동의',
                            // content: thirdPartyInfoContent, // 제3자 제공 동의 내용
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8, // 체크박스 크기 조정
                    child: Checkbox(
                      value: _isPointTermsChecked,
                      onChanged: (value) {
                        setState(() {
                          _isPointTermsChecked = value!;
                          _updateAllCheckedStatus();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8), // 체크박스와 텍스트 사이에 간격 추가
                  Expanded(
                    child: Text('(필수) 포인트 약관 동의'),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 16), // 화살표 아이콘 추가
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsDetailPage(
                            title: '포인트 약관',
                            // content: pointTermsContent, // 포인트 약관 내용
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),



              SizedBox(height: 16),
              if (!_isEmailSent) ...[
                ElevatedButton(
                  onPressed: (_formKey.currentState?.validate() ?? false) && _isAllChecked
                      ? () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _sendVerificationEmail();
                    }
                  }
                      : null,
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
              onTap: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  try {
                    await user.delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('회원 가입을 취소하였습니다.')),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SignInForm()),
                    );
                  } catch (e) {
                    print('Error deleting user: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('회원가입 취소에 실패했습니다.')),
                    );
                  }
                }
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

  // 전체 동의 상태 업데이트
  void _updateAllCheckedStatus() {
    setState(() {
      _isAllChecked = _isPrivacyPolicyChecked && _isThirdPartyInfoChecked && _isPointTermsChecked;
    });
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
