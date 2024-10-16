import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailPage extends StatelessWidget {
  final List<Map<String, dynamic>> ordersForDate;

  const OrderDetailPage({Key? key, required this.ordersForDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 상세'),
      ),
      body: ListView.builder(
        itemCount: ordersForDate.length,
        itemBuilder: (context, index) {
          final order = ordersForDate[index];
          final items = order['items'] as List<dynamic>?;

          if (items == null || items.isEmpty) {
            return Center(child: Text('주문 항목을 불러올 수 없습니다.'));
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Markets')
                .doc(items[0]['marketId'])  // 첫 번째 상품의 마켓 ID를 사용
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('마켓 정보를 불러올 수 없습니다.'));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('마켓 정보를 찾을 수 없습니다.'));
              }

              final marketData = snapshot.data!.data() as Map<String, dynamic>?;
              final marketName = marketData != null ? marketData['name'] : 'Unknown Market';

              return Card(
                color: Colors.white,
                margin: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 마켓 이름을 네모 박스 맨 위 왼쪽에 표시
                      Text(
                        marketName ?? 'No Market Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(height: 16),
                      Column(
                        children: items.map((item) {
                          return _buildItemCard(item);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 주문 항목별 UI
  Widget _buildItemCard(Map<String, dynamic> item) {
    final List<String> imageList = (item['img'] is List)
        ? (item['img'] as List<dynamic>).cast<String>()
        : [item['img'] ?? 'https://via.placeholder.com/150'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageList.isNotEmpty
                    ? imageList[0]
                    : 'https://via.placeholder.com/150',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '제목 없음',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '가격: ${item['price']}원',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // 배송 현황 버튼 추가
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // 배송 현황 버튼 클릭 시 동작 (구현 안 함)
            },
            child: Text('배송 현황 보기'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Color.fromRGBO(230, 245, 220, 1.0),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
