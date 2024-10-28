import 'package:ecore/models/firebase_auth_state.dart';
import 'package:ecore/my_page/favorite_list_page.dart';
import 'package:ecore/my_page/recently_viewed_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../cosntants/common_color.dart';
import '../signinup_page/sign_in_form.dart';
import 'my_address_list.dart';

class MyPageList extends StatefulWidget {
  const MyPageList({super.key});

  @override
  State<MyPageList> createState() => _MyPageListState();
}

class _MyPageListState extends State<MyPageList> {
  void _signOut() async {
    await Provider.of<FirebaseAuthState>(context, listen: false).signOut();
  }

  void _accountDeletionModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원탈퇴', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('정말로 탈퇴하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await _deleteAccount();
                Navigator.of(context).pop();
              },
              child: Text('탈퇴', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .delete();

        await user.delete();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignInForm(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 후 다시 시도해주세요.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('탈퇴 실패: ${e.message}')),
        );
      }
    } catch (e) {
      // Firestore 삭제 중 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터 삭제 중 오류가 발생했습니다: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(thickness: 5),
        Text('스토어'),
        TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecentViewedPage(),
                ),
              );
            },
            child: Text('최근 본 상품', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
        TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteListPage(),
                ),
              );
            },
            child: Text('찜 한 상품', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
        TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddressListPage(),
                ),
              );
            },
            child: Text('배송지 관리', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
        Divider(thickness: 2),
        Text('고객센터'),
        TextButton(
            onPressed: () {},
            child: Text('기부자 문의 내역', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
        TextButton(
            onPressed: () {},
            child: Text('판매자 문의 내역', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
        TextButton(
            onPressed: () {},
            child: Text('FAQ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
        TextButton(
            onPressed: () {},
            child: Text('공지사항', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
        TextButton(
            onPressed: () {},
            child: Text('문의하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
        Divider(thickness: 2),
        Text('서비스 설정'),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('로그아웃', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          onTap: _signOut,
        ),
        ListTile(
          leading: Icon(Icons.person_remove),
          title: Text('회원탈퇴', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          onTap: _accountDeletionModal,
        ),
        SizedBox(height: 20,),
        Container(
          color: baseColor,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('(주)케어링크 사업자 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), ),
                SizedBox(height: 20),
                Text('대표이사 윤지원', style: TextStyle(fontSize: 10)),
                Text('주소 경기도 수원시 영통구 이의동 광교산로 154-42', style: TextStyle(fontSize: 10)),
                Text('문의전화 010-8691-5007', style: TextStyle(fontSize: 10)),
                Text('이메일 kkuriyoon5007@gmail.com', style: TextStyle(fontSize: 10)),
                Text('사업자등록번호 455-66-00754', style: TextStyle(fontSize: 10)),
                Text('통신판매업 신고번호 2020-수원광교-2024호', style: TextStyle(fontSize: 10)),
                Text('Hosting by (주)Carelink', style: TextStyle(fontSize: 10)),
                Divider(thickness: 2),
                Text('사업자 정보 조회 • 이용약관 • 개인정보처리방침', style: TextStyle(fontSize: 10)),
                Text('(주)케어링크는 통신판매중개자로서 통신판매의 당사자가 아닙니다.', style: TextStyle(fontSize: 6)),
                Text('따라서, 등록된 상품, 거래정보 및 거래에 대하여 (주)케어링크는 어떠한 책임도 지지 않습니다.', style: TextStyle(fontSize: 6)),
                SizedBox(height: 5),
                Text('*호스팅 사업자 2012년부터 시행된 전자상거래법 제 10조 1항에 따라 모든 쇼핑몰 하단에 사업자 정보와 함께 호스팅 제공자도 표시되어야 합니다', style: TextStyle(fontSize: 6)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
