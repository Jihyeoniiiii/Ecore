import 'package:ecore/cosntants/common_color.dart';
import 'package:ecore/sell_donation_page/sell_product_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../home_page/feed_list.dart';
import '../search/search_screen.dart';
import '../sell_donation_page/dona_product_form.dart';
import 'donation_list.dart';

class DonationBanner extends StatefulWidget {
  const DonationBanner({Key? key}) : super(key: key);

  @override
  _DonationBannerState createState() => _DonationBannerState();
}

class _DonationBannerState extends State<DonationBanner> {
  String _selectedCategory = 'nodonation';
  String _selectedSort = '1'; // 기본 정렬 옵션

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _showCategoryDropdown(context),
          child: Row(
            children: [
              SizedBox(width: 10), // 왼쪽 여백 추가
              Text(
                _selectedCategory == 'donation' ? '기부' : '판매',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'NanumSquare',
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _buildSortDropdown(), // 정렬 옵션 드롭다운
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    isDonationSearch: _selectedCategory == 'donation',
                  ),
                ),
              );
            },
            icon: Icon(
              CupertinoIcons.search,
              color: Colors.blueGrey,
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _selectedCategory == 'donation'
              ? DonationList(selectedSort: _selectedSort) // 정렬 옵션 전달
              : SellList(selectedSort: _selectedSort), // 정렬 옵션 전달
          if (_selectedCategory == 'donation')
            Positioned(
              bottom: 15,
              right: 20, // 오른쪽으로 이동
              child: ElevatedButton(
                onPressed: () {
                  // 기부하기 버튼을 눌렀을 때
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DonaProductForm()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: baseColor, // 버튼 색상
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12), // 가로 세로 길이를 조금 줄임
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 둥근 정도 유지
                  ),
                ),
                child: Text('+ 기부하기', style: TextStyle(fontSize: 18, color: Colors.grey[800])),
              ),
            ),
        ],
      ),
    );
  }

  void _showCategoryDropdown(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        kToolbarHeight,
        MediaQuery.of(context).size.width - size.width - offset.dx,
        0,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'donation',
          child: Text('기부'),
        ),
        PopupMenuItem<String>(
          value: 'sell',
          child: Text('판매'),
        ),
      ],
      elevation: 8.0,
    ).then((String? newValue) {
      if (newValue != null) {
        setState(() {
          _selectedCategory = newValue;
        });
      }
    });
  }

  Widget _buildSortDropdown() {
    List<String> dropDownList = ['1', '2', '3'];
    List<String> sortStr = ['최신순', '오래된순', '조회순'];

    return DropdownButton<String>(
      value: _selectedSort,
      items: dropDownList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(sortStr[int.parse(value) - 1]),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedSort = newValue;
            // 해당 선택에 따라 리스트 갱신
          });
        }
      },
      underline: SizedBox(), // 밑줄 제거
      borderRadius: BorderRadius.circular(8.0), // 선택적: 모서리 둥글기 추가
    );
  }
}
