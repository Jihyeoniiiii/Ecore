// import 'package:ecore/signInUpPage/sign_in_form.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../models/firebase_auth_state.dart';
//
// class SignUpForm extends StatefulWidget {
//   const SignUpForm({super.key});
//
//   @override
//   State<SignUpForm> createState() => _SignUpFormState();
// }
//
// class _SignUpFormState extends State<SignUpForm> {
//
//   GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _pwController = TextEditingController();
//   TextEditingController _cpwController = TextEditingController();
//
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _pwController.dispose();
//     _cpwController.dispose();
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
//               SizedBox(
//                 height: 16,
//               ),
//               Image.asset('assets/images/ecore_logo.png'),
//               TextFormField(
//                 controller: _emailController,
//                 cursorColor: Colors.black54,
//                 decoration: textInputDecor('Email'),
//                 validator: (text) {
//                   if (text != null && text.isNotEmpty && text.contains("@")) {
//                     return null;
//                   }
//                   else {
//                     return '정확한 이메일 주소를 입력해주세요.';
//                   }
//                 },
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               TextFormField(
//                 controller: _pwController,
//                 cursorColor: Colors.black54,
//                 obscureText: true,
//                 decoration: textInputDecor('Password'),
//                 validator: (text) {
//                   if (text != null && text.isNotEmpty && text.length > 5) {
//                     return null;
//                   }
//                   else {
//                     return '비밀번호를 확인해주세요.';
//                   }
//                 },
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               TextFormField(
//                 controller: _cpwController,
//                 cursorColor: Colors.black54,
//                 obscureText: true,
//                 decoration: textInputDecor('Confirm Password'),
//                 validator: (text) {
//                   if (text != null && text.isNotEmpty &&
//                       _pwController.text == text) {
//                     return null;
//                   }
//                   else {
//                     return '입력한 값이 비밀번호와 일치하지 않네요 잘 입력해주세요';
//                   }
//                 },
//               ),
//               SizedBox(height: 12,
//               ),
//               _submitButton(context),
//               SizedBox(height: 12,
//               ),
//               // OrDivider(),
//
//             ],
//           ),
//
//         ),
//       ),
//     );
//   }
//
//   TextButton _submitButton(BuildContext context) {
//     return TextButton(
//       style: TextButton.styleFrom(
//           backgroundColor: Colors.blue,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(6))
//       ),
//       onPressed: () {
//         if (_formKey.currentState?.validate() ?? false) {
//           print('Validation success!!');
//           Provider.of<FirebaseAuthState>(context, listen: false).registerUser(
//               context,
//               email: _emailController.text, password: _pwController.text);
//           Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignInForm()));
//         }
//       },
//       child: Text(
//         'Join',
//         style: TextStyle(
//             color: Colors.white
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
// InputDecoration textInputDecor(String hint) {
//   return InputDecoration(
//       hintText: hint,
//       enabledBorder: activeInputBorder(),
//       focusedBorder: activeInputBorder(),
//       errorBorder:  errorInputBorder(),
//       focusedErrorBorder: errorInputBorder(),
//       filled: true,
//       fillColor: Colors.grey[100]!);
// }
//
// OutlineInputBorder errorInputBorder() {
//   return OutlineInputBorder(
//       borderSide: BorderSide(
//         color: Colors.redAccent,
//       ),
//       borderRadius: BorderRadius.circular(12));
// }
//
// OutlineInputBorder activeInputBorder() {
//   return OutlineInputBorder(
//     borderSide: BorderSide(
//       color: Colors.grey[300]!,
//     ),
//     borderRadius: BorderRadius.circular(12),
//   );
// }
//
//
//
// const MaterialColor white = MaterialColor(
//   0xFFFFFFFF,
//   <int, Color>{
//     50: Color(0x0FFFFFFF),
//     100: Color(0x1FFFFFFF),
//     200: Color(0x2FFFFFFF),
//     300: Color(0x3FFFFFFF),
//     400: Color(0x4FFFFFFF),
//     500: Color(0x5FFFFFFF),
//     600: Color(0x6FFFFFFF),
//     700: Color(0x7FFFFFFF),
//     800: Color(0x8FFFFFFF),
//     900: Color(0x9FFFFFFF),
//   },
// );
