import 'package:ecore/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'cart_page/cart_list.dart';
import 'models/firebase_auth_state.dart';
import 'models/firestore/user_model.dart';
import 'package:ecore/home_page/home_page_menu.dart';
import 'package:ecore/signinup_page/sign_in_form.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseAuthState>(
          create: (_) => FirebaseAuthState(),
        ),
        ChangeNotifierProxyProvider<FirebaseAuthState, UserModel>(
          create: (context) => UserModel(),
          update: (context, authState, userModel) {
            if (authState.user != null) {
              userModel?.fetchUserData(authState.user!.uid);
            }
            return userModel!;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'NanumSquare',
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
        ),
        home: MyAppContent(),
      ),
    );
  }
}

class MyAppContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseAuthState>(
      builder: (context, authState, _) {
        // 사용자의 인증 상태 확인
        if (authState.user != null) {
          // 인증 이메일이 전송된 경우에는 처리하지 않음
          if (authState.user!.emailVerified) {
            return HomePage(); // 로그인 상태이면 홈 화면
          } else {
            // 이메일 인증을 위한 메시지 표시 (홈 화면으로 보내지 않음)
            return SignInForm(); // 비로그인 상태이면 로그인 화면
          }
        }

        return SignInForm(); // 비로그인 상태이면 로그인 화면
      },
    );
  }
}

