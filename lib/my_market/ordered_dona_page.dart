import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../my_page/create_review_page.dart';

class OrderedDonaPage extends StatefulWidget {
  final String marketId;

  const OrderedDonaPage({super.key, required this.marketId});

  @override
  _OrderedDonaPageState createState() => _OrderedDonaPageState();
}

class _OrderedDonaPageState extends State<OrderedDonaPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('주문 내역'),
          leading: const BackButton(),
        ),
        body: const Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('구매한 기부글', style: TextStyle(fontFamily: 'NanumSquare',)),
        leading: const BackButton(),
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
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Markets')
                  .doc(widget.marketId)
                  .collection('DonaOrders')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                  return const Center(child: Text('주문 내역이 없습니다.'));
                }

                final orders = snapshot.data!.docs;

                final filteredOrders = orders.where((order) {
                  final title = order['title']?.toString()?.toLowerCase() ?? '';
                  return title.contains(searchQuery.toLowerCase());
                }).toList();

                Map<String, List<QueryDocumentSnapshot>> groupedOrders = {};

                for (var order in filteredOrders) {
                  Timestamp timestamp = order['date'];
                  DateTime dateTime = timestamp.toDate();
                  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

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
                            groupedOrders[date]!,
                          ),
                          ...groupedOrders[date]!.map((order) {
                            return _buildCard(order);
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildCard(QueryDocumentSnapshot order) {
    String title = order['title'] ?? '제목 없음';
    String paymentMethod = order['paymentMethod'] ?? '결제 방법 없음';
    String username = order['username'] ?? 'Unknown';
    Map<String, dynamic> data = order.data() as Map<String, dynamic>;

    // 리뷰 여부 확인 (리뷰가 작성되었는지 여부를 확인하는 필드 추가)
    bool isReviewed = data['isReviewed'] ?? false;

    List<String>? donaImages = data.containsKey('donaImg')
        ? List<String>.from(data['donaImg'])
        : null;
    String donaImageUrl = donaImages != null && donaImages.isNotEmpty
        ? donaImages[0]
        : 'https://via.placeholder.com/100';

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
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    donaImageUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                      Text(paymentMethod, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      Text('기부자: $username', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                if (!isReviewed) // 리뷰가 작성되지 않은 경우에만 버튼을 표시
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateReview(
                              orderId: order.id, // 주문 ID 전달
                              itemIndex: 0, // 예시로 0을 전달
                              itemTitle: title,
                              itemImg: donaImageUrl,
                              itemPrice: data['price'] ?? 0,
                              marketId: widget.marketId,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: const Text('리뷰 작성', style: TextStyle(fontSize: 12)),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: const Color.fromRGBO(230, 245, 220, 1.0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _viewDate(String date, List<QueryDocumentSnapshot> ordersForDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton(
                  onPressed: () {
                    // 주문 상세 페이지 이동 처리
                  },
                  child: const Text(
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
}
