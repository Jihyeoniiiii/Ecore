import 'package:ecore/cosntants/common_color.dart';
import 'package:flutter/material.dart';

class TermsDetailPage extends StatelessWidget {
  final String title;

  const TermsDetailPage({Key? key, required this.title}) : super(key: key);

  Widget _getContent(String title) {
    switch (title) {
      case '개인정보 제3자 정보 제공 동의':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '제1조 개인정보 제3자 정보 제공 동의',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '회사는 정보주체의 개인정보를 수집 및 이용목적에 한해서만 처리하며, 원칙적으로 제3자에게 제공하지 않습니다. '
                  '다만, 정보주체가 사전 동의한 경우, 법률의 특별한 규정이 있는 경우, 수사 목적 등으로 법령에 정해진 절차와 '
                  '방법에 따라 수사기관의 요구가 있는 경우 및 당사가 제공하는 서비스를 통한 거래 당사자간의 원활한 거래 관련 '
                  '정보를 제공할 필요성이 있는 경우에는 예외로 합니다. 또한, 해외작가 작품 구매 등의 사유로 회사가 이용자의 '
                  '개인정보를 국외로 이전하는 경우 별도 페이지를 통해 정보주체의 동의를 받도록 하겠습니다.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            Text(
              '▶ 제3자에게 제공하는 개인정보 자세히보기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildScrollableTable(),
          ],
        );
      default:
        return Text('해당 제목에 대한 내용이 없습니다.');
    }
  }

  // Table을 가로로 스크롤 가능하게 하고, 셀 구분선을 추가한 위젯
  Widget _buildScrollableTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // 가로로 스크롤 가능하도록 설정
      child: Table(
        border: TableBorder.all(color: Colors.grey), // 셀 경계선 추가
        columnWidths: {
          0: FixedColumnWidth(150.0), // 열 너비 고정
          1: FixedColumnWidth(250.0),
          2: FixedColumnWidth(250.0),
          3: FixedColumnWidth(150.0),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.blueGrey[50]), // 헤더 행 배경색
            children: [
              _buildHeaderCell('제공받는자'),
              _buildHeaderCell('이용목적'),
              _buildHeaderCell('제공하는 항목'),
              _buildHeaderCell('보유·이용기간'),
            ],
          ),
          TableRow(
            children: [
              _buildDataCell('서비스 제공업체'),
              _buildDataCell(
                  '판매자와 구매자 사이의 원활한 거래 진행, 상품의 배송을 위한 배송지 확인, 고객상담 및 불만처리 등'),
              _buildDataCell(
                  '주문자정보(성명, 연락처), 수령인 정보(성명, 연락처, 주소)'),
              _buildDataCell('발송완료 후 15일'),
            ],
          ),
        ],
      ),
    );
  }

  // 헤더 셀 스타일
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  // 데이터 셀 스타일
  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Color.fromARGB(255, 168, 180, 203),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: _getContent(title),
        ),
      ),
    );
  }
}
