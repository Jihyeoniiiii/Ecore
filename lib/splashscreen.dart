import 'package:flutter/material.dart';

import 'main.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      // 3초 후에 MyApp의 main 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyAppContent(),
        ),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: GestureDetector(
        onTap: () {
          // 화면을 터치하면 즉시 MyAppContent로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyAppContent(),
            ),
          );
        },
        child: Center(
          child: Image.asset('assets/images/ecore_logo.png'), // 로고 이미지 경로를 지정하세요.
        ),
      ),
    );
  }
}
