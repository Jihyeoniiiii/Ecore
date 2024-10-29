import 'package:flutter/material.dart';

import '../cosntants/common_color.dart';
import '../signinup_page/terms.dart';

class BusinessInformation extends StatelessWidget {
  const BusinessInformation({
    super.key,
  });

  void _onTermsTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsDetailPage(title: '이용 약관'),
      ),
    );
  }

  void _onPrivacyPolicyTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsDetailPage(title: '개인정보 처리방침'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: baseColor, // 배경 색상
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('(주)케어링크 사업자 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), ),
            SizedBox(height: 20),
            Text('대표이사 윤지원', style: TextStyle(fontSize: 10)),
            Text('주소 서울 구로구 구로동로28길 42', style: TextStyle(fontSize: 10)),
            Text('문의전화 010-8691-5007', style: TextStyle(fontSize: 10)),
            Text('이메일 kkuriyoon5007@gmail.com', style: TextStyle(fontSize: 10)),
            Text('사업자등록번호 455-66-00754', style: TextStyle(fontSize: 10)),
            Text('통신판매업 신고번호 2020-수원광교-2024호', style: TextStyle(fontSize: 10)),
            Text('Hosting by (주)Carelink', style: TextStyle(fontSize: 10)),
            const Divider(thickness: 2),
            Row(
              children: [
                Text('사업자 정보 조회 • ', style: TextStyle(fontSize: 10)),
                InkWell(
                  onTap: () => _onTermsTap(context),
                  child: const Text(
                    '이용약관',
                    style: TextStyle(fontSize: 10, decoration: TextDecoration.underline, decorationThickness: 1.5,),
                  ),
                ),
                const Text(' • ', style: TextStyle(fontSize: 10)),
                InkWell(
                  onTap: () => _onPrivacyPolicyTap(context),
                  child: const Text(
                    '개인정보처리방침',
                    style: TextStyle(fontSize: 10, decoration: TextDecoration.underline, decorationThickness: 1.5,),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('(주)케어링크는 통신판매중개자로서 통신판매의 당사자가 아닙니다.', style: TextStyle(fontSize: 6)),
            Text('따라서, 등록된 상품, 거래정보 및 거래에 대하여 (주)케어링크는 어떠한 책임도 지지 않습니다.', style: TextStyle(fontSize: 6)),
            SizedBox(height: 5),
            Text('*호스팅 사업자 2012년부터 시행된 전자상거래법 제 10조 1항에 따라 모든 쇼핑몰 하단에 사업자 정보와 함께 호스팅 제공자도 표시되어야 합니다', style: TextStyle(fontSize: 6)),
          ],
        ),
      ),
    );
  }
}
