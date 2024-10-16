import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressAndPlaceSearchPage extends StatefulWidget {
  @override
  _AddressAndPlaceSearchPageState createState() => _AddressAndPlaceSearchPageState();
}

class _AddressAndPlaceSearchPageState extends State<AddressAndPlaceSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  // Kakao API 호출 함수 (주소 + 장소 통합 검색)
  Future<void> _search(String query) async {
    if (query.isEmpty) {
      print('검색어가 비어 있습니다.');
      return; // 검색어가 비어 있으면 API 호출을 하지 않음
    }

    // Kakao API 키를 여기에 입력하세요
    final String kakaoApiKey = '44cd9bd8d2b5fb2024c1758ba89083ac';

    // 검색어를 URL 인코딩
    final String encodedQuery = Uri.encodeComponent(query);

    // Kakao 장소 검색 API URL
    final String placeApiUrl = 'https://dapi.kakao.com/v2/local/search/keyword.json?query=$encodedQuery';

    // 장소 검색 API 호출
    final placeResponse = await http.get(
      Uri.parse(placeApiUrl),
      headers: {'Authorization': 'KakaoAK $kakaoApiKey'},
    );

    if (placeResponse.statusCode == 200) {
      final Map<String, dynamic> placeData = jsonDecode(placeResponse.body);
      final List<dynamic> placeDocuments = placeData['documents'];

      setState(() {
        _searchResults = placeDocuments.map((doc) {
          final placeName = doc['place_name'] ?? ''; // 장소 이름
          final roadAddress = doc['road_address_name'] ?? ''; // 도로명 주소
          final address = doc['address_name'] ?? ''; // 지번 주소

          // 주소 결합: 도로명 주소가 있으면 도로명 + 장소 이름, 없으면 지번 주소 + 장소 이름
          final fullAddress = roadAddress.isNotEmpty
              ? '$roadAddress $placeName'
              : '$address $placeName';

          return fullAddress; // 결합된 주소를 반환
        }).toList();
      });
    } else {
      print('Error: Failed to fetch data from Kakao API. Status Code: ${placeResponse.statusCode}');
      print('Response body: ${placeResponse.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경 흰색
      appBar: AppBar(
        title: Text('주소 검색'),
        backgroundColor: Colors.white, // AppBar 배경 흰색
        elevation: 0, // 그림자 없애기
        iconTheme: IconThemeData(color: Colors.black), // AppBar 아이콘 색상
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20), // 제목 색상
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '지번, 도로명, 건물명으로 검색',
                prefixIcon: Icon(Icons.search, color: Colors.black), // 검색 아이콘 색상
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.black), // 삭제 아이콘 색상
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults.clear();
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // 테두리 둥글게
                  borderSide: BorderSide(
                    color: Colors.grey, // 테두리 색상
                    width: 2.0, // 테두리 두께
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.black, // 포커스 시 테두리 색상
                    width: 2.0,
                  ),
                ),
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  _search(query); // 검색어가 입력되었을 때만 API 호출
                }
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_searchResults[index]),
                    onTap: () {
                      // 검색 결과 선택 시 데이터를 반환하고 메인 페이지로 돌아감
                      Navigator.pop(context, _searchResults[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
