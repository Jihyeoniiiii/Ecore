// import 'package:ecore/signInUpPage/sign_in_form.dart';
// import 'package:ecore/signInUpPage/sign_up_form.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
//
// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});
//
//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }
//
// class _AuthScreenState extends State<AuthScreen> {
//
//   Widget signUpForm = SignUpForm();
//   Widget signInForm = SignInForm();
//
//   Widget currentWidget = SignUpForm();
//
//   // @override
//   // void initState() {
//   //   if(currentWidget == null)
//   //     currentWidget = signUpForm;
//   //   // TODO: implement initState
//   //   super.initState();
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: SafeArea(
//         child: Stack(
//           children: <Widget>[
//             AnimatedSwitcher(
//               child: currentWidget,
//               duration: Duration(milliseconds: 1000),
//             ),
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 height: 40,
//                 child: Container(
//                 color: Colors.white,
//                 child: TextButton(
//                   style: TextButton.styleFrom(
//                       shape: RoundedRectangleBorder(side:BorderSide(color: Colors.grey))
//                   ),
//                   onPressed: (){
//                     setState(() {
//                       if(currentWidget is SignUpForm) {
//                         currentWidget = SignInForm();
//                       }
//                       else {
//                         currentWidget = SignUpForm();
//                       }
//                     });
//                   },
//                   child: RichText(
//                     text: TextSpan(
//                         text: (currentWidget is SignUpForm)
//                             ? "Already have an account?"
//                             : "Don't have an account?",
//                         style: TextStyle(color: Colors.grey),
//                         children: [
//                           TextSpan(
//                             text: (currentWidget is SignUpForm)
//                                 ? "Sign In"
//                                 : "Sing Up",
//                           )
//                         ]
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
