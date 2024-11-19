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

      case '이용 약관':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '제1장 총칙',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '제1조 (목적)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
                  '이 약관은 서비스 이용자가 주식회사 케어링크(이하 ‘회사’라 합니다)가 제공하는 서비스와 관련하여 '
                  '회사와 서비스의 이용고객 간에 서비스의 이용 조건 및 절차, 상호간의 권리·의무, 책임 사항 및 기타 필요한 사항을 '
                  '규정함을 목적으로 합니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '제2조 (용어의 정의)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '이 약관에서 사용하는 용어의 정의는 다음 각호와 같으며, 정의되지 않은 용어에 대한 해석은 관계법령 및 서비스별 안내에서 정하는 바에 따릅니다.\n'
                  '1. 서비스: PC, 휴대형 단말기 등 각종 유무선 기기 또는 프로그램을 통하여 회원이 이용할 수 있도록 회사가 제공하는 서비스 플랫폼 등을 포함한 모든 인터넷 서비스를 말합니다.\n'
                  '2. 회원: 만14세 이상의 개인 또는 법인으로서 이 약관에 동의하고 회사와 이용 계약을 체결하여 회사가 제공하는 서비스를 사용하는 자를 말하며, 다음과 같이 일반회원과 판매회원으로 구분이 됩니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '제3조 (약관의 명시, 효력 및 변경)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '제4조 (대리행위·보증의 부인)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '제2장 이용계약 및 정보보호 ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
                  '제5조 (서비스 이용계약의 성립)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '① 회사의 서비스에 관한 이용계약(이하 “이용계약"이라고 합니다)은 회사의 서비스를 이용하고자 하는 자가 이 약관에 동의하여 회원가입 신청을 하고, 회사가 이용승낙의 의사표시를 해당 서비스화면에 게시하거나, 전자우편 또는 기타 방법으로 통지함으로써 성립합니다.\n'
                  '② 회원가입은 만 14세 이상의 개인 또는 사업자(개인사업자 및 법인사업자)가 할 수 있으며, 서비스를 이용하고자 하는 자가 이 약관에 동의하고, 회사가 정한 회원 가입 신청 양식에 포함된 정보(실명 등)를 사실과 다름없이 기입한 후 회사가 지정한 방법에 따라 제출하는 방법으로 합니다. 회사는 필요한 경우 관련 증빙 서류를 제출요청 할 수 있습니다.\n'
                  '③ 회사는 『청소년보호법』 상의 보호대상인 회원, 만 19세미만의 회원, 외국인 회원, 법인 및 단체 회원 등 회원별로 서비스의 이용을 제한할 수 있으며, 이러한 서비스의 제한에 대한 사항은 개별 서비스에 별도 안내 또는 공지합니다. \n'
                  '④ 회사는 다음 각호의 사유가 발생한 경우 이용신청에 대한 승낙을 거부하거나 유보할 수 있고, 해당 사유가 관련 법령을 위배하는 경우 이용 신청자는 관련 법령에 의거 처벌받을 수 있습니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
    Text(
    '1. 제출 정보(본인확인절차 포함)의 내용에 허위, 기재 누락, 오기, 제3자 정보도용이 있는 경우\n'
    '2. 회사가 본 조 제2항에 따라 제출한 정보의 정확성을 확인하기 위하여 관련 법령이 허용하는 범위 내의 증빙자료의 제공을 요청하였으나, 부당하게 이를 제공하지 않는 경우\n'
    '3. 작가회원의 가입을 요청한 자와 서비스이용료를 납입하는 자의 정보가 다를 경우\n'
    '4. 이미 가입된 회원과 정보(식별번호, 전자우편주소 등)가 동일한 경우\n'
    '5. 제출 정보의 내용에 허위, 기재 누락, 오기가 있는 경우\n'
    '6. 이 약관 또는 회사와의 계약 등에 의하여 회원자격을 상실한 적이 있거나, 이용신청의 제한이 있는 회원인 경우\n'
    '7. 회사로부터 회원자격 정지 조치 등을 받은 회원이 그 조치기간 중에 이용계약을 임의 해지하고 재이용 신청을 하는 경우\n'
    '8. 부정한 용도 또는 회사의 서비스 제공 목적에 반하여 영리를 추구할 목적으로 서비스를 이용하고자 하는 경우\n'
    '9. 작가회원의 설비에 여유가 없거나 기술상 지장이 있는 경우\n'
    '10. 이 약관에 위배되거나 위법 또는 부당한 이용신청임이 확인된 경우\n'
    '11. 기타 회사가 합리적인 판단에 의하여 필요하다고 인정하는 경우',
    textAlign: TextAlign.justify,
    style: TextStyle(fontSize: 16),
    ),
    SizedBox(height: 16),
    Text(
    '제6조 (개인정보보호)',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
            SizedBox(height: 8),
    Text(
    '① 회원은 이용신청 시 허위의 정보를 제공하여서는 아니되며, '
    '② 회원의 정보를 허위로 수정하여 회사 또는 제3자에게 손해를 입힌 경우 발생한 모든 손해를 배상하여야 합니다.\n'
    '③ 회원은 회원정보로써 기재 또는 회사에 제공한 사항(주소지, 대금결제를 위한 계좌정보 등)의 변경이 있는 경우 즉시 서비스 플랫폼 내에서 개인정보를 직접 수정하거나 '
    '전자우편 또는 기타 방법으로 회사에게 그 변경 사항을 알리는 등 최신의 정보를 유지하여야 합니다.\n'
    '④ 회사와 작가회원은 서비스 제공과 관련해 알게 된 개인정보를 본인의 승낙 없이 제3자에 누설, 배포하지 않으며 개인정보 보호법 등 관련 법령에 따릅니다.\n'
    '⑤ 회사는 관련 법령에 따라 수사기관의 요청이 있을 경우 회원의 개인정보를 제공할 수 있습니다.',
    textAlign: TextAlign.justify,
    style: TextStyle(fontSize: 16),
    ),
    SizedBox(height: 16),
    Text(
    '제7조 (ID 및 비밀번호의 관리)',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
            SizedBox(height: 8),
    Text(
    '① 회원의 ID 및 비밀번호 관리 책임은 회원에게 있으며, 이를 타인에게 양도, 증여, 대여하거나 담보로 제공할 수 없습니다.\n'
    '② 다음 각 호에 해당하는 경우, 회사는 사전 통지 없이 ID 및 비밀번호 사용을 제한하거나 변경할 수 있습니다:\n'
    '  - 타인의 개인정보를 도용하여 이용신청을 한 경우\n'
    '  - ID 또는 비밀번호가 유출된 경우\n'
    '  - 회원을 회사의 임직원이나 관계자로 오인할 우려가 있는 경우\n'
    '③ 회원은 ID 또는 비밀번호가 유출되거나 제3자가 무단으로 사용할 경우 즉시 회사에 통보해야 합니다.\n'
    '④ 회사는 회원의 ID 및 비밀번호 관리 소홀로 인한 불이익에 대해 책임지지 않습니다.',
    textAlign: TextAlign.justify,
    style: TextStyle(fontSize: 16),
    ),
          ],
        );

      case '포인트 이용 약관':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '제 1 조 (목적)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '이 약관은 [에코리]에서 제공하는 포인트 제도의 이용에 관한 사항을 규정함으로써, '
                  '사용자와 회사 간의 권리 및 의무를 명확히 하고, 원활한 서비스 이용을 도모하는 것을 목적으로 합니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '제 2 조 (정의)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. "포인트"란 사용자가 [에코리] 내에서 특정 활동을 통해 적립하거나 사용할 수 있는 가상의 통화를 의미합니다.\n'
                  '2. "사용자"란 본 앱에 가입하여 포인트를 적립하고 사용할 수 있는 개인 또는 법인을 의미합니다.\n'
                  '3. "적립"이란 사용자가 활동을 통해 포인트를 얻는 행위를 의미합니다.\n'
                  '4. "사용"이란 적립한 포인트를 통해 상품 구매나 서비스 이용을 하는 행위를 의미합니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '제 3 조 (포인트 적립)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. 사용자는 앱 내에서 제공하는 다양한 활동(예: 상품 구매, 리뷰 작성, 추천인 코드 입력 등)을 통해 포인트를 적립할 수 있습니다.\n'
                  '2. 포인트 적립 비율 및 조건은 앱 내에서 별도로 공지하며, 회사는 사전 예고 없이 이를 변경할 수 있습니다.\n'
                  '3. 특정 이벤트나 프로모션에 따라 추가 포인트가 제공될 수 있으며, 해당 조건은 각 이벤트에 명시된 바에 따릅니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '제 4 조 (포인트 사용)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. 사용자는 적립한 포인트를 앱 내에서 상품 구매 또는 서비스 이용 시 사용할 수 있습니다.\n'
                  '2. 사용자는 마켓에서 상품을 구매 시 다른 결제 수단과 함께 “에코리 포인트”를 사용할 수 있으며, “에코리 포인트”는 최대 상품금액의 7%까지 사용 가능합니다.\n'
                  '3. 포인트 사용 시 최소 사용 가능 포인트는 [금액]으로 설정되며, 이는 회사의 정책에 따라 변경될 수 있습니다.\n'
                  '4. 특정 상품이나 서비스에 대해서는 포인트 사용이 제한될 수 있으며, 이에 대한 사항은 앱 내에 별도로 공지합니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '제 5 조 (포인트 유효기간)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. 적립된 포인트는 적립일로부터 [기간] 동안 유효합니다. 유효기간이 만료된 포인트는 자동으로 소멸됩니다.\n'
                  '2. 포인트 소멸에 대한 공지는 앱 내에서 사전에 안내하며, 사용자는 이를 확인할 책임이 있습니다.\n'
                  '3. 사용자가 포인트 유효기간 만료 전에 포인트를 사용할 경우, 사용한 포인트는 소멸되지 않습니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '제 6 조 (포인트 전환 및 환불)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. 적립된 포인트는 현금으로 환전할 수 없습니다.\n'
                  '2. 사용자가 포인트를 사용한 후에는 환불이 불가능하며, 포인트 사용에 대한 모든 책임은 사용자에게 있습니다.\n'
                  '3. 포인트의 전환 및 환불 정책은 앱 내에 별도로 명시하며, 변경 시 사전 공지합니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '제 7 조 (포인트 관리)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. 사용자는 자신의 포인트 잔액 및 적립 내역을 앱 내에서 확인할 수 있습니다.\n'
                  '2. 포인트 관련 오류가 발생한 경우, 사용자는 즉시 고객센터에 문의해야 하며, 회사는 이를 확인 후 조치를 취할 수 있습니다.\n'
                  '3. 부정한 방법으로 포인트를 적립한 경우, 회사는 해당 포인트를 무효화하거나 사용자 계정을 정지할 수 있습니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '제 8 조 (포인트 대금 지급)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '마켓에서 구매한 재화 등의 대금 지급은 다음 각 호의 어느 하나의 방법으로 할 수 있습니다. 단, “회사”가 필요로 하는 경우 재화 등의 대금 지급 방법을 각 호의 방법 중 회사가 정한 방법으로 결정할 수 있습니다. 회사는 이용자의 지급방법에 대하여 재화 등의 대금에 어떠한 명목의 수수료도 추가하여 징수할 수 없습니다.\n'
                  '1. 폰뱅킹, 인터넷뱅킹, 메일 뱅킹 등의 각종 계좌이체\n'
                  '2. 선불카드, 직불카드, 신용카드 등의 각종 카드 결제\n'
                  '3. 온라인무통장입금\n'
                  '4. 전자화폐에 의한 결제 (휴대폰 결제, 온라인 결제서비스를 통한 결제 등)\n'
                  '5. 수령 시 대금지급\n'
                  '6. 에코리 포인트 등 “마켓”이 지급한 포인트에 의한 결제\n'
                  '7. 기타 전자적 지급 방법에 의한 대금 지급 등\n\n'
                  '회사는 사용자가 재화 등을 공급받기 전에 제1조제2호 및 제5호을 제외한 방법으로 재화 등의 대금을 지급하는 경우, 해당 결제 대금을 제3자에게 예치하고 공급이 완료된 후 “회사” 또는 “판매자”에게 지급하도록 하는 ‘구매안전 서비스’를 제공합니다.\n'
                  '사용자는 재화 등을 거래한 날부터 4영업일 이내에 그 사실을 회사에 통보해야 하며, 4영업일이 지나도록 정당한 사유 없이 거래한 사실을 통보하지 않는 경우 예치된 대금은 회사가 지정한 정산대행업체에게 지급될 수 있습니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '제 9 조 (약관 변경)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. 회사는 이 약관을 변경할 수 있으며, 변경 시 앱 내에 공지합니다.\n'
                  '2. 변경된 약관은 공지된 날로부터 효력이 발생하며, 사용자는 이를 확인할 책임이 있습니다.\n'
                  '3. 변경된 약관에 동의하지 않는 경우, 사용자는 포인트를 사용하지 않을 수 있으며, 필요시 계정을 삭제할 수 있습니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '제 10 조 (기타)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. 이 약관에 명시되지 않은 사항은 관련 법령 및 회사의 정책에 따릅니다.\n'
                  '2. 이 약관의 해석 및 적용에 관한 사항은 대한민국 법률에 따르며, 분쟁 발생 시 회사의 본사 소재지를 관할하는 법원에서 해결합니다.\n'
                  '3. 이 약관은 시행일부터 시행됩니다.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
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
          3: IntrinsicColumnWidth(),

        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[200]),
            children: [
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('제공받는 자', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('제공하는 항목', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('이용목적', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('보유 이용기간', style: TextStyle(fontWeight: FontWeight.bold)))),

            ],
          ),
          TableRow(children: [
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('케어링크'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('이용자의 앱 이용내역, 광고식별자'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('맞춤형 서비스 제공'))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('발송완료 후 15일'))),
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
