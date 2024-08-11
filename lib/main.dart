// import 'package:ecore/HomePage/home_page_menu.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
//
// import 'models/firebase_auth_state.dart';
// import 'models/firestore/user_model.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider<FirebaseAuthState>(
//           create: (_) => FirebaseAuthState(),
//         ),
//         ChangeNotifierProxyProvider<FirebaseAuthState, UserModel>(
//           create: (context) => UserModel(),
//           update: (context, authState, userModel) {
//             if (authState.user != null) {
//               userModel?.fetchUserData(authState.user!.uid);
//             }
//             return userModel!;
//           },
//         ),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: HomePage(),
//       ),
//     );
//   }
// }




// import 'package:ecore/repo/user_network_repository.dart';
// import 'package:ecore/signInUpPage/sign_in_form.dart';
// import 'package:ecore/signInUpPage/sign_up_form.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
// import 'models/firebase_auth_state.dart';
// import 'models/user_model_state.dart';
// import 'my_progress_indicator.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   FirebaseAuthState _firebaseAuthState = FirebaseAuthState();
//
//   @override
//   Widget build(BuildContext context) {
//     // Ensure that Firebase authentication changes are being observed
//     _firebaseAuthState.watchAuthChange();
//
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider<FirebaseAuthState>.value(
//           value: _firebaseAuthState,
//         ),
//         ChangeNotifierProvider<UserModelState>(
//           create: (_) => UserModelState(),
//         ),
//       ],
//       child: MaterialApp(
//         home: Consumer<FirebaseAuthState>(
//           builder: (BuildContext context, FirebaseAuthState firebaseAuthstate, Widget? child) {
//             // Initialize _currentWidget based on FirebaseAuthState
//             Widget currentWidget;
//             switch (firebaseAuthstate.firbaseAuthStatus) {
//               case FirebaseAuthStatus.signout:
//                 _clearUserModel(context);
//                 currentWidget = SignInForm();
//                 // currentWidget = S();
//
//                 break;
//               case FirebaseAuthStatus.signin:
//                 _initUserModel(firebaseAuthstate, context);
//                 // currentWidget = HomePage();
//                 currentWidget = SignInForm();
//                 break;
//
//               default:
//                 currentWidget = MyProgressIndicator(containerSize: 100);
//             }
//
//             return AnimatedSwitcher(
//               duration: Duration(milliseconds: 300),
//               child: currentWidget,
//             );
//           },
//         ),
//         theme: ThemeData(primaryColor: white), // Define the primary color theme
//       ),
//     );
//   }
//
//   void _initUserModel(FirebaseAuthState firebaseAuthstate, BuildContext context) {
//     if (firebaseAuthstate.user != null) {
//       UserModelState userModelState = Provider.of<UserModelState>(context, listen: false);
//
//
//       userModelState.currentStreamSub = userNetworkRepository
//           .getUserModelStream(firebaseAuthstate.user!.uid)
//           .listen((userModel) {
//         userModelState.userModel = userModel;
//       });
//     } else {
//       // Optionally handle the case where the user is null
//     }
//   }
//
//   void _clearUserModel(BuildContext context) {
//     UserModelState userModelState =
//     Provider.of<UserModelState>(context, listen: false);
//     userModelState.clear();
//   }
// }