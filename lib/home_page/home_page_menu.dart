import 'package:ecore/cosntants/common_color.dart';
import 'package:ecore/home_page/home_page_banner.dart';
import 'package:ecore/my_page/my_page_banner.dart';
import 'package:flutter/material.dart';
import '../cart_page/cart_page_banner.dart';
import '../chat_page/chat_list.dart';
import '../donation_page/donation_page_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BottomNavigationBarItem> btmNavItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.message), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: ''),
  ];

  static List<Widget> _screens = <Widget>[
    TitleBanner(),
    DonationBanner(),
    ChatList(),
    CartBanner(),
    MyPageBanner(),
  ];

  int _selctedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // 이렇게 해줘야 누를 때마다 생성이 아닌 해당 페이지에 해당 인덱스 번호를 붙여준 것
        index: _selctedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: btmNavItems,
        unselectedItemColor: iconColor,
        selectedItemColor: Colors.green[300],
        currentIndex: _selctedIndex, // 현재 인덱스는 선택된 인덱스
        onTap: _onBtmItemClick, // 눌렀을 때 인덱스 값을 전달함 -> 함수 실행
      ),
    );
  }

  void _onBtmItemClick(int idx) {
    setState(() {
      _selctedIndex = idx;
      _refreshFeed(idx);
    });
  }

  void _refreshFeed(int idx) { //리셋
    setState(() {
      switch(idx){
        case 0: _screens[0] = TitleBanner(key: UniqueKey());
        case 1: _screens[1] = DonationBanner(key: UniqueKey());
      }
    });
  }
}
