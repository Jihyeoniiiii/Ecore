import 'package:flutter/material.dart';
import 'search_feed_list.dart'; // 글 검색 결과 표시용 위젯
import 'search_market_list.dart'; // 마켓 검색 결과 표시용 위젯

class SearchResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> donationResults;
  final List<Map<String, dynamic>> sellPostResults;
  final List<Map<String, dynamic>> marketResults;
  final bool? isDonationSearch;

  SearchResultsScreen({
    required this.donationResults,
    required this.sellPostResults,
    required this.marketResults,
    required this.isDonationSearch,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> combinedResults = [];

    // 모든 검색 결과를 하나의 리스트로 합침
    combinedResults.addAll(donationResults);
    combinedResults.addAll(sellPostResults);
    combinedResults.addAll(marketResults);

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: ListView.builder(
        itemCount: combinedResults.length,
        itemBuilder: (context, index) {
          final result = combinedResults[index];

          // result가 마켓에서 나온 것인지 확인
          final isMarketResult = marketResults.any((market) => market['id'] == result['id']);

          if (isMarketResult) {
            // 마켓 검색 결과를 표시
            return SearchMarketList(result, context);
          } else {
            // 기부글 또는 판매글 검색 결과를 표시
            return SearchFeedList(result, isDonationSearch ?? false, context);
          }
        },
      ),
    );
  }
}
