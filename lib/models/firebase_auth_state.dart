import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../repo/user_network_repository.dart';
import '../signinup_page/sign_in_form.dart';

class FirebaseAuthState extends ChangeNotifier {
  FirebaseAuthStatus _firebaseAuthStatus = FirebaseAuthStatus.signout;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  FirebaseAuthState() {
    watchAuthChange();
  }

  void watchAuthChange() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user == null) {
        _user = null;
        _firebaseAuthStatus = FirebaseAuthStatus.signout;
      } else {
        _user = user;
        _firebaseAuthStatus = FirebaseAuthStatus.signin;
      }
      notifyListeners();
    });
  }

  Future<void> registerUser(BuildContext context,
      {required String email, required String password}) async {
    _firebaseAuthStatus = FirebaseAuthStatus.progress;
    notifyListeners();

    // 로딩 창 띄우기
    showDialog(
      context: context,
      barrierDismissible: false, // 로딩 중에는 창을 닫을 수 없게 설정
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      _user = userCredential.user;

      if (_user != null) {
        // Firestore에 사용자 데이터 전송
        await userNetworkRepository.attemptCreateUser(userkey: _user!.uid, email: email);

        // 자동 로그인을 방지하기 위해 로그아웃 처리
        await _firebaseAuth.signOut();
        _user = null;

        // 로딩 창 닫기
        Navigator.of(context).pop();

        // 회원가입 완료 후 성공 메시지 보여주기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입이 성공적으로 완료되었습니다. 로그인 후 이용해 주세요.'),
          ),
        );

        // 로그인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInForm()),
        );
      } else {
        throw Exception('User registration failed');
      }
    } on FirebaseAuthException catch (error) {
      String _message = "";
      switch (error.code) {
        case 'weak-password':
          _message = "패스워드가 너무 약합니다.";
          break;
        case 'invalid-email':
          _message = "유효하지 않은 이메일 주소입니다.";
          break;
        case 'email-already-in-use':
          _message = "이메일 주소가 이미 사용 중입니다.";
          break;
        default:
          _message = "알 수 없는 오류 발생";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_message)));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("알 수 없는 오류 발생")));
    } finally {
      // 로딩 창 닫기
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      _firebaseAuthStatus = FirebaseAuthStatus.signout;
      notifyListeners();
    }
  }

  Future<void> login(BuildContext context,
      {required String email, required String password}) async {
    _firebaseAuthStatus = FirebaseAuthStatus.progress;
    notifyListeners();

    // 로딩 창 띄우기
    showDialog(
      context: context,
      barrierDismissible: false, // 로딩 중에는 창을 닫을 수 없게 설정
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      _user = userCredential.user;

      if (_user != null) {
        // 로그인 성공 후 홈 화면으로 이동
        Navigator.of(context).pop(); // 로딩 창 닫기
      } else {
        throw Exception('User login failed');
      }
    } on FirebaseAuthException catch (error) {
      String _message = "";
      switch (error.code) {
        case 'invalid-email':
          _message = "이메일 주소가 유효하지 않습니다.";
          break;
        case 'wrong-password':
          _message = "비밀번호가 틀렸습니다.";
          break;
        case 'user-not-found':
          _message = "이메일 주소가 등록되어 있지 않습니다.";
          break;
        case 'user-disabled':
          _message = "해당 계정이 비활성화되었습니다.";
          break;
        case 'too-many-requests':
          _message = "너무 많은 시도. 나중에 다시 시도해주세요.";
          break;
        case 'operation-not-allowed':
          _message = "이 작업은 허용되지 않습니다.";
          break;
        default:
          _message = "알 수 없는 오류 발생";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_message)));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("알 수 없는 오류 발생")));
    } finally {
      // 로딩 창 닫기
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      _firebaseAuthStatus = _user != null ? FirebaseAuthStatus.signin : FirebaseAuthStatus.signout;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle(BuildContext context, User user) async {
    _firebaseAuthStatus = FirebaseAuthStatus.progress;
    notifyListeners();

    try {
      // 기존 사용자가 아니면 Firestore에 사용자 정보 생성
      await userNetworkRepository.attemptCreateUser(userkey: user.uid, email: user.email ?? "");

      // 로그인 상태 업데이트
      _user = user;
      _firebaseAuthStatus = FirebaseAuthStatus.signin;
      notifyListeners();

      // 홈 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyAppContent()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("알 수 없는 오류 발생")));
    }
  }

  Future<void> signOut() async {
    _firebaseAuthStatus = FirebaseAuthStatus.signout;
    notifyListeners();
    await _firebaseAuth.signOut();
  }

  FirebaseAuthStatus get firebaseAuthStatus => _firebaseAuthStatus;
  User? get user => _user;
}

enum FirebaseAuthStatus {
  signout, progress, signin
}
