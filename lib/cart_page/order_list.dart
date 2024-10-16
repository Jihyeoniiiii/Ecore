import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../my_page/create_review_page.dart';
import 'order_detail_page.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  String searchQuery = ''; // 검색어를 저장할 변수

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('주문 내역'),
          leading: BackButton(),
        ),
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('주문 내역'),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: '검색',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value; // 검색어를 업데이트
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.uid)
                  .collection('Orders')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                  return Center(child: Text('주문 내역이 없습니다.'));
                }

                final orders = snapshot.data!.docs;

                // Fetch items for each order
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchOrdersWithItems(orders),
                  builder: (context, itemsSnapshot) {
                    if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (itemsSnapshot.hasError) {
                      return Center(child: Text('Error: ${itemsSnapshot.error}'));
                    }

                    if (!itemsSnapshot.hasData || itemsSnapshot.data!.isEmpty) {
                      return Center(child: Text('주문 내역이 없습니다.'));
                    }

                    final filteredOrders = itemsSnapshot.data!.where((order) {
                      final items = order['items'] as List<dynamic>?;
                      return items != null && items.any((item) {
                        return item['title']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase());
                      });
                    }).toList();

                    // 날짜별로 그룹화된 주문 데이터
                    Map<String, List<Map<String, dynamic>>> groupedOrders = {};

                    for (var order in filteredOrders) {
                      Timestamp timestamp = order['date'];
                      DateTime dateTime = timestamp.toDate();
                      String formattedDate =
                      DateFormat('yyyy-MM-dd').format(dateTime);

                      if (groupedOrders.containsKey(formattedDate)) {
                        groupedOrders[formattedDate]!.add(order);
                      } else {
                        groupedOrders[formattedDate] = [order];
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListView(
                        children: groupedOrders.keys.map((date) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _viewDate(
                                date,
                                groupedOrders[date]!, // 해당 날짜의 모든 주문 항목 전달
                              ),
                              ...groupedOrders[date]!.map((order) {
                                return Column(
                                  children: (order['items'] as List<dynamic>?)
                                      ?.asMap()
                                      .entries
                                      .map((entry) {
                                    final item = entry.value;
                                    final index = entry.key;
                                    final List<String> imageList =
                                    (item['img'] is List)
                                        ? (item['img'] as List<dynamic>)
                                        .cast<String>()
                                        : [
                                      item['img'] ??
                                          'https://via.placeholder.com/150'
                                    ];

                                    return _buildCard(
                                      imageList,
                                      item,
                                      order['id'], // 주문 ID 전달
                                      index, // 아이템 인덱스 전달
                                      item['marketId'] ?? 'unknown_store',
                                    );
                                  }).toList() ??
                                      [],
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchOrdersWithItems(
      List<QueryDocumentSnapshot> orders) async {
    List<Map<String, dynamic>> ordersWithItems = [];

    for (var orderDoc in orders) {
      final orderId = orderDoc.id;
      final orderData = orderDoc.data() as Map<String, dynamic>;

      // Fetch items for this order
      final itemsQuerySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Orders')
          .doc(orderId)
          .collection('items')
          .get();

      final items = itemsQuerySnapshot.docs.map((doc) => doc.data()).toList();

      ordersWithItems.add({
        ...orderData,
        'id': orderId,
        'items': items,
      });
    }

    return ordersWithItems;
  }

  Padding _buildCard(
      List<String> imageList, item, String orderId, int itemIndex, String marketId) {
    bool isReviewed = item['reviewed'] ?? false;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _orderBox(imageList, item),
              SizedBox(height: 16),
              if (!isReviewed) // 리뷰가 작성되지 않은 경우에만 버튼을 표시
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateReview(
                            orderId: orderId,
                            itemIndex: itemIndex,
                            itemTitle: item['title'] ?? '제목 없음',
                            itemImg: imageList.isNotEmpty ? imageList[0] : '',
                            itemPrice: item['price'] ?? 0,
                            marketId: item['marketId'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: Text('리뷰 작성'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Color.fromRGBO(230, 245, 220, 1.0), // 버튼 색상 변경
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _viewDate(String date, List<Map<String, dynamic>> ordersForDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: Colors.grey,
            thickness: 3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailPage(ordersForDate: ordersForDate),
                      ),
                    );
                  },
                  child: Text(
                    '주문상세 >',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column _orderBox(List<String> imageList, item) {
    return Column(
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
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
