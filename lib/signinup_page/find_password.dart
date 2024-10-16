import 'package:ecore/signinup_page/sign_up_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FindPasswordScreen extends StatefulWidget {
  FindPasswordScreen({super.key});

  @override
  _FindPasswordScreenState createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  final textStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontFamily: 'GowunBatang',
    fontWeight: FontWeight.w700,
    letterSpacing: -0.40,
  );

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    double widthRatio = deviceWidth / 375;
    double heightRatio = deviceHeight / 812;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black, // 뒤로가기 아이콘 색상을 검정으로 설정
          ),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼 클릭 시 이전 화면으로 이동
          },
        ),
        title: Text(
          "비밀번호 재설정",
          style: textStyle.copyWith(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white, // AppBar 배경색을 흰색으로 설정
        elevation: 0, // AppBar 그림자를 제거하여 플랫하게 만듦
      ),
      backgroundColor: Color(0xFFFFFFFF), // 여기서 배경색을 흰색으로 설정
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: widthRatio * 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: heightRatio * 50),
            Text(
              "비밀번호를 재설정할 이메일 주소를 입력하세요.",
              style: textStyle.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            SizedBox(height: heightRatio * 20),
            TextFormField(
              textInputAction: TextInputAction.next,
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                labelStyle: textStyle.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: heightRatio * 20),
            Container(
              width: double.infinity,
              height: heightRatio * 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50], // 배경색 설정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // 원하는 값으로 조절
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                  setState(() {
                    _isLoading = true;
                  });

                  String email = _emailController.text.trim(); // 공백 제거
                  if (email.isEmpty || !email.contains('@')) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text("유효하지 않은 이메일", style: textStyle),
                        content: Text("올바른 이메일 주소를 입력해주세요.", style: textStyle),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("확인", style: textStyle),
                          ),
                        ],
                      ),
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text("전송 완료", style: textStyle),
                        content: Text("해당 이메일로 비밀번호 재설정 링크를 전송하였습니다.", style: textStyle),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("확인", style: textStyle),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    if (e is FirebaseAuthException && e.code == 'user-not-found') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text("가입되지 않은 이메일", style: textStyle),
                          content: Text("가입되지 않은 이메일입니다. 가입하시겠습니까?", style: textStyle),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context), // 아니오를 누르면 팝업 닫기
                              child: Text("아니오", style: textStyle),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // 팝업 닫기
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUpForm()));
                              },
                              child: Text("예", style: textStyle),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text("오류 발생", style: textStyle),
                          content: Text("비밀번호 재설정 이메일 전송 중 오류가 발생했습니다. 이메일 주소를 다시 확인해주세요.", style: textStyle),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("확인", style: textStyle),
                            ),
                          ],
                        ),
                      );
                    }
                  }

                  setState(() {
                    _isLoading = false;
                  });
                },
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text(
                  '비밀번호 재설정 링크 보내기',
                  style: textStyle.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
