//
// import 'package:ecore/HomePage/home_page_menu.dart';
// import 'package:ecore/signInUpPage/sign_up_form.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:provider/provider.dart';
//
// import '../models/firebase_auth_state.dart';
//
// class SignInForm extends StatefulWidget {
//   @override
//   _SignInFormState createState() => _SignInFormState();
// }
//
// class _SignInFormState extends State<SignInForm> {
//   GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _pwController = TextEditingController();
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _pwController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: <Widget>[
//               SizedBox(height: 16),
//               Image.asset('assets/images/ecore_logo.png'),
//               SizedBox(height: 30),
//               TextFormField(
//                 controller: _emailController,
//                 cursorColor: Colors.black54,
//                 decoration: textInputDecor('이메일'),
//                 validator: (text) {
//                   if (text != null && text.isNotEmpty && text.contains("@")) {
//                     return null;
//                   } else {
//                     return '정확한 이메일 주소를 입력해주세요.';
//                   }
//                 },
//               ),
//               SizedBox(height: 10),
//               TextFormField(
//                 controller: _pwController,
//                 cursorColor: Colors.black54,
//                 obscureText: true,
//                 decoration: textInputDecor('비밀번호'),
//                 validator: (text) {
//                   if (text != null && text.isNotEmpty && text.length > 5) {
//                     return null;
//                   } else {
//                     return '정확한 비밀번호를 입력해주세요.';
//                   }
//                 },
//               ),
//               TextButton(
//                 onPressed: (){},
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: Text(
//                     '아이디 비밀번호 찾기',
//                     style: TextStyle(color: Colors.blue),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12),
//               _submitButton(context),
//               SizedBox(height: 12),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('계정이 없으신가요? '),
//             GestureDetector(
//               onTap: () {
//                 // Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
//               },
//               child: Text(
//                 '가입하기',
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   TextButton _submitButton(BuildContext context) {
//     return TextButton(
//       style: TextButton.styleFrom(
//         backgroundColor: Color.fromRGBO(0, 0, 128, 1.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(6),
//         ),
//       ),
//       onPressed: () {
//         if (_formKey.currentState?.validate() ?? false) {
//           print('Validation success!!');
//           Provider.of<FirebaseAuthState>(context, listen: false)
//               .login(context, email: _emailController.text, password: _pwController.text);
//         }
//       },
//       child: Text(
//         'Sign In',
//         style: TextStyle(color: Colors.white),
//       ),
//     );
//   }
// }
