import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SettlementPage extends StatefulWidget {
  final String marketId;

  const SettlementPage({Key? key, required this.marketId}) : super(key: key);

  @override
  _SettlementPageState createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  num totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('정산 관리', style: TextStyle(fontFamily: 'NanumSquare',)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(3.0),
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('Markets')
              .doc(widget.marketId)
              .collection('SellOrders')
              .orderBy('date', descending: true)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('판매 내역이 없습니다'));
            }

            totalPrice = snapshot.data!.docs.fold(0, (previousValue, element) {
              return previousValue + (element['price'] ?? 0);
            });

            final sellOrders = snapshot.data!.docs;

            Map<String, List<QueryDocumentSnapshot>> groupedOrders = {};
            for (var order in sellOrders) {
              Timestamp timestamp = order['date'];
              DateTime dateTime = timestamp.toDate();
              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

              if (groupedOrders.containsKey(formattedDate)) {
                groupedOrders[formattedDate]!.add(order);
              } else {
                groupedOrders[formattedDate] = [order];
              }
            }

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '총 판매 금액 : ₩$totalPrice',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: ListView(
                      children: groupedOrders.keys.map((date) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                              child: Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...groupedOrders[date]!.map((doc) {
                              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                              String sellImageUrl = data.containsKey('sellImg') && data['sellImg'] != null
                                  ? data['sellImg'][0]
                                  : 'https://via.placeholder.com/70';

                              return Card(
                                elevation: 2.0,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5.0),
                                        child: Image.network(
                                          sellImageUrl,
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      // const SizedBox(width: 40),
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data['title'] ?? '상품명 없음',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                      data['paymentMethod'] ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                  ),
                                                  Text(
                                                    '구매자 : ${data['username']}' ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              '+ ₩${data['price'] ?? 0}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[300],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
