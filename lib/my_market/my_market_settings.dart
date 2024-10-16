import 'package:ecore/my_market/settlement_page.dart';
import 'package:flutter/material.dart';
import 'delivery_management_page.dart';
import 'edit_market_info.dart';
import 'edit_seller_info.dart';
import 'ordered_dona_page.dart';

class MyMarketSettings extends StatelessWidget {
  final String marketId;

  const MyMarketSettings({Key? key, required this.marketId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마켓 설정', style: TextStyle(fontFamily: 'NanumSquare',)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // 뒤로가기 버튼 색상
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 전체적인 패딩
        child: Column(
          children: [
            _buildSettingsButton(
              context,
              icon: Icons.edit,
              text: '마켓 정보 편집',
              onTap: () {
                // 프로필 편집 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMarketInfoPage(marketId: marketId), // 예시: 프로필 편집 페이지
                  ),
                );
              },
            ),
            _buildSettingsButton(
              context,
              icon: Icons.local_shipping,
              text: '배송 관리',
              onTap: () {
                // 배송 관리 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryManagementPage(marketId: marketId), // 예시: 배송 관리 페이지
                  ),
                );
              },
            ),
            _buildSettingsButton(
              context,
              icon: Icons.account_balance_wallet,
              text: '정산 관리',
              onTap: () {
                // 정산 관리 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettlementPage(marketId: marketId), // 예시: 정산 관리 페이지
                  ),
                );
              },
            ),
            _buildSettingsButton(
              context,
              icon: Icons.info,
              text: '판매자 정보 편집',
              onTap: () {
                // 마켓 정보 편집 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditSellerInfoForm(marketId: marketId), // 마켓 정보 편집 페이지
                  ),
                );
              },
            ),
            _buildSettingsButton(
              context,
              icon: Icons.favorite,
              text: '구매한 기부글',
              onTap: () {
                // 구매한 기부글 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderedDonaPage(marketId: marketId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 설정 버튼 빌더 함수
  Widget _buildSettingsButton(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // 버튼 사이 간격
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // 버튼 내부 여백
          decoration: BoxDecoration(
            color: Colors.white, // 버튼 배경색 하얀색
            borderRadius: BorderRadius.circular(8), // 둥근 모서리
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // 약한 그림자
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // 그림자 위치
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Colors.green.shade800), // 아이콘 색상 진한 초록
              SizedBox(width: 16),
              Text(
                text,
                style: TextStyle(fontSize: 18, color: Colors.black), // 텍스트 스타일
              ),
              Spacer(), // 아이콘과 텍스트 사이 여백
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54), // 오른쪽 화살표 아이콘
            ],
          ),
        ),
      ),
    );
  }
}
