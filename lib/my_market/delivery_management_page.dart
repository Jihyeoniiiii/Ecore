import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../cosntants/common_color.dart';

class DeliveryManagementPage extends StatefulWidget {
  final String marketId;

  const DeliveryManagementPage({Key? key, required this.marketId}) : super(key: key);

  @override
  _DeliveryManagementPageState createState() => _DeliveryManagementPageState();
}

class _DeliveryManagementPageState extends State<DeliveryManagementPage> {
  num totalPrice = 0;
  String selectedStatus = "배송 준비";
  List<String> selectedOrders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('배송 관리', style: TextStyle(fontFamily: 'NanumSquare',)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            _buildStatusButtons(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Markets')
                      .doc(widget.marketId)
                      .collection('SellOrders')
                      .where('shippingStatus', isEqualTo: selectedStatus)
                      .orderBy('date', descending: true)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('판매 내역이 없습니다'));
                    }

                    totalPrice =
                        snapshot.data!.docs.fold(0, (previousValue, element) {
                          return previousValue + (element['price'] ?? 0);
                        });

                    final sellOrders = snapshot.data!.docs;

                    Map<String, List<QueryDocumentSnapshot>> groupedOrders = {};
                    for (var order in sellOrders) {
                      Timestamp timestamp = order['date'];
                      DateTime dateTime = timestamp.toDate();
                      String formattedDate = DateFormat('yyyy-MM-dd').format(
                          dateTime);

                      if (groupedOrders.containsKey(formattedDate)) {
                        groupedOrders[formattedDate]!.add(order);
                      } else {
                        groupedOrders[formattedDate] = [order];
                      }
                    }

                    return ListView(
                      children: groupedOrders.keys.map((date) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 15.0),
                              child: Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...groupedOrders[date]!.map((doc) {
                              Map<String, dynamic> data = doc.data() as Map<
                                  String,
                                  dynamic>;
                              String sellImageUrl = data.containsKey(
                                  'sellImg') && data['sellImg'] != null
                                  ? data['sellImg'][0]
                                  : 'https://via.placeholder.com/70';

                              return Card(
                                elevation: 3.0,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 13.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      if (selectedStatus != "배송 완료")
                                        Checkbox(
                                          fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                                            if (states.contains(MaterialState.selected)) {
                                              return Colors.green;
                                            }
                                            return Colors.white;
                                          }),
                                          value: selectedOrders.contains(
                                              doc.id),
                                          onChanged: (bool? isSelected) {
                                            setState(() {
                                              if (isSelected ?? false) {
                                                selectedOrders.add(doc.id);
                                              } else {
                                                selectedOrders.remove(doc.id);
                                              }
                                            });
                                          },
                                        ),
                                      SizedBox(width: 15,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            5.0),
                                        child: Image.network(
                                          sellImageUrl,
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 12,),
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(horizontal: 12.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    data['title'] ?? '상품명 없음',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${data['price'] ?? 0}원',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  Text(
                                                    '구매자 : ${data['username']}' ??
                                                        '',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Spacer(),
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
                    );
                  },
                ),
              ),
            ),
            if (selectedStatus != "배송 완료") Padding(
              padding: const EdgeInsets.all(15.0),
              child: _buildChangeStatusButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeStatusButton() {
    bool isSelected = selectedOrders.isNotEmpty;

    return ElevatedButton(
      onPressed: isSelected
          ? () {
        _updateSelectedOrdersStatus();
      }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: baseColor,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      ),
      child: Text(
        '상태 변경',
        style: TextStyle(
          fontSize: 15,
          color: isSelected ? Colors.black : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildStatusButtons() {
    final List<String> statuses = ["배송 준비", "배송 중", "배송 완료"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: statuses.map((status) {
        final isSelected = selectedStatus == status;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            constraints: BoxConstraints(maxWidth: 100, maxHeight: 45),
            decoration: BoxDecoration(
              color: isSelected ? baseColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  selectedStatus = status;
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _updateSelectedOrdersStatus() async {
    String nextStatus = '';
    if (selectedStatus == "배송 준비") {
      nextStatus = "배송 중";
    } else if (selectedStatus == "배송 중") {
      nextStatus = "배송 완료";
    }

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (String orderId in selectedOrders) {
      DocumentReference orderRef = FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId)
          .collection('SellOrders')
          .doc(orderId);

      DocumentSnapshot orderSnapshot = await orderRef.get();

      if (orderSnapshot.exists) {
        Map<String, dynamic>? orderData = orderSnapshot.data() as Map<String, dynamic>?;
        String userId = orderData?['buyerId'] ?? '';
        String sellId = orderData?['sellId'] ?? '';

        batch.update(orderRef, {'shippingStatus': nextStatus});

        if (userId.isNotEmpty && sellId.isNotEmpty) {
          QuerySnapshot userOrdersSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('Orders')
              .where('orderId', isEqualTo: sellId)
              .get();

          if (userOrdersSnapshot.docs.isNotEmpty) {
            for (var userOrderDoc in userOrdersSnapshot.docs) {
              DocumentReference userOrderRef = userOrderDoc.reference;

              QuerySnapshot itemsQuerySnapshot = await userOrderRef.collection('items')
                  .where('sellId', isEqualTo: sellId)
                  .get();

              if (itemsQuerySnapshot.docs.isNotEmpty) {
                for (var itemDoc in itemsQuerySnapshot.docs) {
                  batch.update(itemDoc.reference, {'shippingStatus': nextStatus});
                }
              } else {
                print('해당 sellId에 맞는 아이템이 없습니다: $sellId');
              }
            }
          } else {
            print('유저 주문 문서가 존재하지 않습니다: $sellId');
          }
        }
      } else {
        print('해당 주문 문서가 존재하지 않습니다: $orderId');
      }
    }

    await batch.commit();

    setState(() {
      selectedOrders.clear();
      selectedStatus = nextStatus;
    });
  }
}
