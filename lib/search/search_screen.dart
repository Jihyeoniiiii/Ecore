import 'package:flutter/material.dart';
import '../cosntants/common_color.dart';
import 'donation_search.dart';
import 'sell_posts_search.dart';
import 'search_result_screen.dart';
import 'market_search.dart';
import 'search_service.dart';

class SearchScreen extends StatefulWidget {
  final bool? isDonationSearch;

  SearchScreen({this.isDonationSearch});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DonationSearch _donationSearch = DonationSearch();
  final SellPostSearch _sellPostSearch = SellPostSearch();
  final MarketSearch _marketSearch = MarketSearch();
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  List<Map<String, dynamic>> _popularSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadPopularSearches();
  }

  void _loadRecentSearches() async {
    final recentSearches = await _searchService.getRecentSearches();
    setState(() {
      _recentSearches = _removeDuplicates(recentSearches);
    });
  }

  void _loadPopularSearches() async {
    final popularSearches = await _searchService.getPopularSearches();
    setState(() {
      _popularSearches = popularSearches;
    });
  }

  List<String> _removeDuplicates(List<String> searches) {
    return searches.toSet().toList();
  }

  void _performSearch() async {
    final query = _searchController.text;

    if (query.isEmpty) {
      return;
    }

    await _searchService.saveSearchTerm(query);
    _loadRecentSearches(); // 최근 검색어 갱신

    List<Map<String, dynamic>> donationResults = [];
    List<Map<String, dynamic>> sellPostResults = [];
    List<Map<String, dynamic>> marketResults = [];

    if (widget.isDonationSearch == true) {
      donationResults = await _donationSearch.searchDonations(query);
    } else if (widget.isDonationSearch == false) {
      sellPostResults = await _sellPostSearch.searchSellPosts(query);
    } else {
      donationResults = await _donationSearch.searchDonations(query);
      sellPostResults = await _sellPostSearch.searchSellPosts(query);
      marketResults = await _marketSearch.searchMarkets(query);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          donationResults: donationResults,
          sellPostResults: sellPostResults,
          marketResults: marketResults,
          isDonationSearch: widget.isDonationSearch,
        ),
      ),
    );
  }

  void _onRecentSearchTap(String term) {
    _searchController.text = term;
    _performSearch();
  }

  void _onPopularSearchTap(String term) {
    _searchController.text = term;
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 검은색 뒤로 가기 아이콘
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Stack(
          alignment: Alignment.centerRight, // 검색창 오른쪽 끝에 X 버튼 배치
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200], // 검색창 배경색 설정 (연한 회색)
                borderRadius: BorderRadius.circular(10), // 모서리를 둥글게
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  border: InputBorder.none, // 테두리 제거
                  hintText: '검색어를 입력해주세요.', // 힌트 텍스트
                  hintStyle: TextStyle(color: Colors.grey), // 힌트 텍스트 색상 설정
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty) // 검색어가 있을 때만 X 버튼 표시
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey), // X 아이콘
                onPressed: () {
                  _searchController.clear(); // 검색어 삭제
                  setState(() {}); // 상태 업데이트
                },
              ),
          ],
        ),
        centerTitle: true, // 타이틀 중앙 정렬
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: Colors.black), // 검은색 검색 아이콘
            onPressed: _performSearch, // 검색 실행
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 최근 검색어가 있는 경우에만 표시
            if (_recentSearches.isNotEmpty) ...[
              Text('최근 검색어', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _recentSearches.map((term) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () => _onRecentSearchTap(term),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: baseColor, // 배경색
                            borderRadius: BorderRadius.circular(12), // 동그란 모서리
                            border: Border.all(color: baseColor), // 테두리 색상
                          ),
                          child: Text(
                            term,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
            ],

            // 인기 검색어가 있는 경우에만 표시
            if (_popularSearches.isNotEmpty) ...[
              Text('인기 검색어', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Column(
                children: _popularSearches.asMap().entries.map((entry) {
                  int index = entry.key;
                  String term = entry.value['term'];
                  return ListTile(
                    title: Text('${index + 1}. $term'),
                    onTap: () => _onPopularSearchTap(term),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
