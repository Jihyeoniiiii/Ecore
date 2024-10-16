import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class BusinessCheckPage extends StatefulWidget {
  @override
  _BusinessCheckPageState createState() => _BusinessCheckPageState();
}

class _BusinessCheckPageState extends State<BusinessCheckPage> {
  final _code1Controller = TextEditingController();
  final _code2Controller = TextEditingController();
  final _code3Controller = TextEditingController();
  String _resultMessage = '';

  Future<void> _checkBusinessNumber() async {
    String code1 = _code1Controller.text;
    String code2 = _code2Controller.text;
    String code3 = _code3Controller.text;

    if (code1.isEmpty || code2.isEmpty || code3.isEmpty) {
      setState(() {
        _resultMessage = '모든 필드를 입력해주세요.';
      });
      return;
    }

    String businessNumber = '$code1$code2$code3';

    var data = {
      "b_no": [businessNumber]
    };

    try {
      String serviceKey =
          "AC9zdZTlBsdv4Ylv3CdSllj0yXx6N7SjO%2FieWH0EiNu8CpZLRkxJ%2Ba9b1IkI3kI1Y40eIIMfJIEndaYW9ma3zg%3D%3D";

      var response = await http.post(
        Uri.parse("https://api.odcloud.kr/api/nts-businessman/v1/status?serviceKey=$serviceKey"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['match_cnt'] == 1) {
          setState(() {
            _resultMessage = '사업자 등록 번호가 유효합니다.';
          });
          Navigator.pop(context, businessNumber); // Return the valid business number
        } else {
          setState(() {
            _resultMessage = '사업자 등록 번호가 유효하지 않습니다.\n'
                '상태: ${result['data'][0]['tax_type']}';
          });
        }
      } else {
        setState(() {
          _resultMessage = "서버 에러: ${response.statusCode}\n"
              "응답 본문: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = "에러: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사업자 등록번호 확인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _code1Controller,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                  ),
                ),
                Text('-'),
                Expanded(
                  child: TextField(
                    controller: _code2Controller,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                  ),
                ),
                Text('-'),
                Expanded(
                  child: TextField(
                    controller: _code3Controller,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkBusinessNumber,
              child: Text('확인'),
            ),
            SizedBox(height: 20),
            Text(
              _resultMessage,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
