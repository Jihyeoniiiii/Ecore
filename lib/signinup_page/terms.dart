import 'package:flutter/material.dart';

class TermsDetailPage extends StatelessWidget {
  final String title;

  const TermsDetailPage({Key? key, required this.title}) : super(key: key);

  Widget _getContent(String title) {
    switch (title) {
      case '개인정보 처리방침':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '개인정보 처리방침',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '㈜케어링크(이하 ‘회사’)는 「개인정보 보호법」 등 개인정보와 관련된 법령 상의 개인정보보호 규정을 준수하며, '
                  '이용자의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            Text(
              '제1조 개인정보 수집 및 이용',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildScrollableTable1(), // 첫 번째 표: 개인정보 수집 및 이용
            SizedBox(height: 16),
            Text(
              '제2조 개인정보 처리 위탁',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '회사는 원활한 개인정보 업무처리를 위하여 개인정보 처리업무를 외부 업체에 위탁하여 운영하고 있습니다. 회사는 위탁계약 체결 시 개인정보보호 관련 지시 엄수, 개인정보의 유출금지 및 사고 시의 책임에 관한 사항을 명확히 규정하고 있으며, '
                  '수탁자가 개인정보를 안전하게 처리하는지를 감독합니다.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            Text(
              '▶ 국내 위탁 현황 자세히 보기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildScrollableTable2(), // 두 번째 표: 국내 위탁 현황
            Text(
              '▶ 국외 위탁 현황 자세히 보기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildScrollableTable3(), // 세 번째 표: 국외 위탁 현황
            SizedBox(height: 16),
            Text(
              '제3조 정보주체 및 법정대리인의 권리 및 의무',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '정보주체는 언제든지 수집 정보에 대하여 수정, 동의 철회 등을 요청할 수 있습니다. 다만, 동의 철회, 삭제 시 서비스의 일부 또는 전부 이용이 제한될 수 있습니다. 정보주체는 개인정보를 보호하고 타인의 정보를 침해하지 않을 의무도 가지고 있습니다. '
                  '비밀번호를 포함한 개인정보가 유출되지 않도록 주의가 필요합니다. 에코리 내 판매자와의 채팅 메세지를 포함한 타인의 개인정보를 훼손하지 않도록 유의해야 합니다. '
                  '만약 이 같은 책임을 다하지 못하고 타인의 정보를 훼손할 시에는 『정보통신망 이용촉진 및 정보보호 등에 관한 법률, 개인정보 보호법』 등에 의해 처벌받을 수 있습니다.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            Text(
              '제4조 개인정보의 파기 및 절차',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '회사는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기하며, '
                  '일반적으로 채권-채무 관계가 남아 있지 않으면 회원가입 때 수집된 개인정보는 회원 탈퇴 시점에 바로 삭제됩니다. 다만, 정보주체로부터 동의 받은 개인정보 보유기간이 경과하거나 '
                  '처리목적이 달성되었음에도 불구하고 다른 법령에 따라 개인정보를 계속 보존하여야 하는 경우에는 해당 개인정보를 별도의 데이터베이스(DB)로 옮기거나 보관장소를 달리하여 보존하고, '
                  '법령에 따른 보존기간의 경과 후 파기합니다.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            Text(
              '제5조 개인정보의 안전성 확보조치',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '회사는 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다. '
                  '1) 기술적 조치: 개인정보처리시스템 등의 접근권한 관리, 접근통제시스템 설치, 고유식별정보 등의 암호화, 보안프로그램 설치 '
                  '2) 관리적 조치: 내부관리계획 수립․시행, 정기적 직원 교육 등 '
                  '3) 물리적 조치: 비인가자 출입통제, 통제구역/제한구역 분리 및 접근통제',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            Text(
              '제6조 행태정보의 관리',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '서비스 이용과정에서 이용자에 관한 서비스 이용기록 정보(서비스 이용기록, 접속로그, 쿠키, 접속IP 정보, MAC주소, 무선 단말기 정보)를 정보통신서비스 제공자가 자동화된 방법으로 생성되어 수집될 수 있습니다. '
                  '또한 이용자에게 최적화된 맞춤형 서비스 및 혜택을 제공하기 위해 아래와 같이 행태정보가 수집 및 이용됩니다.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            _buildScrollableTable4(), // 네 번째 표: 행태정보 관리
            SizedBox(height: 16),
            Text(
              '제7조 개인정보 자동 수집 장치의 설치∙운영 및 거부에 관한 사항',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '회사는 이용자에게 개별적인 맞춤서비스를 제공하기 위해 이용정보를 저장하고 수시로 불러오는 쿠키(cookie)를 사용합니다. '
                  '이용자가 방문한 각 서비스와 웹 사이트들에 대한 방문 및 이용형태, 인기 검색어, 보안접속 여부, 각종 이벤트 참여 정도의 파악을 통한 타겟 마케팅 및 개인 맞춤 서비스 제공 '
                  '이용자가 사용하시는 웹 브라우저의 옵션을 선택함으로써 모든 쿠키를 허용하거나 쿠키를 저장할 때마다 확인을 거치거나, 모든 쿠키의 저장을 거부할 수 있습니다. '
                  '다만, 쿠키 저장을 거부할 경우 맞춤형 서비스 이용에 어려움이 발생할 수 있습니다.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            Text(
              '제8조 개인정보 보호책임자 및 상담·신고',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '회사는 이용자의 개인정보를 보호하고 개인정보에 관련한 업무를 처리하기 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있으며, 개인정보와 관련한 문의사항이 있으시면 개인정보 보호책임자에게 연락주시기 바랍니다.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            _buildTextWithContacts(),
          ],
        );

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
              '회사는 정보주체의 개인정보를 수집 및 이용목적에 한해서만 처리하며, 원칙적으로 제3자에게 제공하지 않습니다. 다만, '
                  '정보주체가 사전 동의한 경우, 법률의 특별한 규정이 있는 경우, 수사 목적 등으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우 '
                  '및 당사가 제공하는 서비스를 통한 거래 당사자간의 원활한 거래 관련 정보를 제공할 필요성이 있는 경우에는 예외로 합니다. 또한, 해외작가 작품 구매 등의 사유로 회사가 이용자의 '
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
            _buildThirdPartyInfoTable(),
          ],
        );

      default:
        return Text('해당 제목에 대한 내용이 없습니다.');
    }
  }

  // 첫 번째 표: 개인정보 수집 및 이용
  Widget _buildScrollableTable1() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(), // 표 테두리 추가
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth(),
          3: IntrinsicColumnWidth(),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[200]),
            children: [
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('분류', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('목적', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('수집항목', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('보유기간', style: TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
          TableRow(children: [
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('필수정보\n가입(전체회원)'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('회원가입 및 서비스 제공'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('[이메일 회원가입] 이메일, 휴대폰번호, 닉네임, 비밀번호'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('회원 탈퇴 시 지체없이 삭제 또는 법령에 따른 보존기간'))),
          ]),
          TableRow(children: [
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('마켓입점'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('마켓 입점'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('성명, 이메일, 연락처, 신분증 정보, 은행계좌 정보'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('퇴점 1년 후 지체 없이 삭제'))),
          ]),
          // 추가 행을 필요에 맞게 추가
        ],
      ),
    );
  }

// 두 번째 표: 국내 위탁 현황
  Widget _buildScrollableTable2() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(),
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[200]),
            children: [
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('위탁업체명', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('위탁업무내용', style: TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
          TableRow(children: [
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('OO업체'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('고객상담, A/S 처리'))),
          ]),
          TableRow(children: [
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('XX업체'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('물류 배송'))),
          ]),
          // 추가 행을 필요에 맞게 추가
        ],
      ),
    );
  }

// 세 번째 표: 국외 위탁 현황
  Widget _buildScrollableTable3() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(),
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth(),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[200]),
            children: [
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('위탁업체명', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('위탁업무내용', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('위탁국가', style: TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
          TableRow(children: [
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('OO업체'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('클라우드 저장 서비스'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('미국'))),
          ]),
          TableRow(children: [
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('XX업체'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('고객상담 지원'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('일본'))),
          ]),
          // 추가 행을 필요에 맞게 추가
        ],
      ),
    );
  }

// 네 번째 표: 행태정보 관리
  Widget _buildScrollableTable4() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(),
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth(),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[200]),
            children: [
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('행태정보 수집방법', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('행태정보 항목', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('보유 및 이용기간', style: TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
          TableRow(children: [
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('웹 사이트 및 앱 방문/실행 시 자동 수집'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('광고식별자, 앱 이용내역'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('회원 탈퇴 시까지'))),
          ]),
          TableRow(children: [
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('페이스북, 인스타그램 SDK 설치'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('사용자 활동 정보'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('광고 목적 종료 시'))),
          ]),
          // 추가 행을 필요에 맞게 추가
        ],
      ),
    );
  }
  // 제3자 제공 정보 표 생성
  Widget _buildThirdPartyInfoTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(), // 테두리 추가
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth(),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[200]),
            children: [
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('제공받는 자', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('제공하는 항목', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('이용목적', style: TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
          TableRow(children: [
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('케어링크'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('이용자의 앱 이용내역, 광고식별자'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('맞춤형 서비스 제공'))),
          ]),
          // 추가 행을 필요에 맞게 추가
        ],
      ),
    );
  }



  // 연락처 정보
  Widget _buildTextWithContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '[개인정보보호 책임자] 윤지원 | kkuriyoon50072@gmail.com | 전화번호: 010-8691-5007',
          style: TextStyle(fontSize: 14),
        ),
        Text(
          '[개인정보보호 담당자] 조소현 | sohyeon0601@kyonggi.ac.kr | 전화번호: 010-8572-2285',
          style: TextStyle(fontSize: 14),
        ),
      ],
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
