import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cosntants/common_color.dart';
import 'pay_page.dart';
import '../models/firestore/user_model.dart';

class CartList extends StatefulWidget {
  const CartList({super.key});

  @override
  State<CartList> createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  final Map<String, bool> _selectedItems = {}; // 선택된 항목을 저장하는 Map
  final Set<String> _marketProcessed = {}; // 마켓 이름이 처리되었는지 확인하는 Set
  int totalShippingFee = 0;
  int totalProductPrice = 0;
  int _totalPrice = 0; // 총 결제 금액을 저장하는 변수

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    // Fetch user data if userKey is empty
    if (userModel.userKey.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userModel.fetchUserData(user.uid);
      }
    }

    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: userModel.cartStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cartItems = snapshot.data ?? [];

          if (cartItems.isEmpty) {
            return Center(child: Text('장바구니가 비어있습니다.'));
          }

          _marketProcessed.clear(); // 매번 빌드할 때 마켓 처리를 초기화

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    String imageUrl;
                    String marketName = cartItem['donaId'] != null ? '기부글' : cartItem['marketName'] ?? 'Unknown Market';

                    int shippingFee;

                    // 기부글이면 배송비 1000원, 아니면 해당 상품의 배송비를 사용
                    if (cartItem['donaId'] != null) {
                      shippingFee = 1000;
                    } else {
                      shippingFee = cartItem['shippingFee'] != null
                          ? cartItem['shippingFee'] as int
                          : 0; // 배송비가 null이면 기본값 0 설정
                    }

                    // img 필드가 리스트인지 확인하고 첫 번째 이미지를 사용
                    if (cartItem['img'] is List<dynamic> && cartItem['img'].isNotEmpty) {
                      imageUrl = cartItem['img'][0]; // 첫 번째 이미지를 가져옴
                    } else if (cartItem['img'] is String) {
                      imageUrl = cartItem['img'];
                    } else {
                      imageUrl = 'https://via.placeholder.com/150'; // 기본 이미지
                    }

                    final itemId = cartItem['sellId'] ?? cartItem['donaId'] as String;

                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        color: Colors.white,
                        elevation: 2.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                marketName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 25.0),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _selectedItems[itemId] ?? false,
                                    fillColor: MaterialStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return iconColor;
                                        }
                                        return Colors.white;
                                      },
                                    ),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _selectedItems[itemId] = value ?? false;
                                        _calculateTotalPrice(cartItems);
                                      });
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      imageUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cartItem['title'] ?? '제목 없음'),
                                        Text('${cartItem['price']}원'),
                                        Text('배송비: ${shippingFee}원'),
                                      ],
                                    ),
                                  ),
                              IconButton(
                                  icon: Icon(Icons.remove_shopping_cart, color: Colors.red[300]),
                                  onPressed: () {
                                    setState(() {
                                      userModel.removeCartItem(itemId); // 장바구니에서 아이템 삭제
                                    });
                                  },
                                ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                color: Colors.white,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPriceRow('상품 금액', totalProductPrice),
                        SizedBox(height: 10),
                        _buildPriceRow('배송비', totalShippingFee),
                        SizedBox(height: 10),
                        _buildPriceRow('총 결제 금액', _totalPrice),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedItems.isEmpty ? null : () {
                          _goToPayPage(cartItems);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: baseColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          '$_totalPrice원 결제하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      //floatingActionButton: CartBtn(),
    );
  }

  Widget _buildPriceRow(String label, int amount) {
    return Row(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(label),
          ),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('${amount}원'),
          ),
        ),
      ],
    );
  }

  // 선택된 상품들의 총 가격을 계산하는 함수
  void _calculateTotalPrice(List<Map<String, dynamic>> cartItems) {
    int totalPrice = 0;
    int totalProductPrice = 0;
    int totalShippingFee = 0;
    Set<String> processedMarkets = {}; // 이미 처리된 마켓

    for (var cartItem in cartItems) {
      final itemId = cartItem['sellId'] ?? cartItem['donaId'] as String;

      if (_selectedItems[itemId] ?? false) {
        int price = (cartItem['price'] ?? 0).toInt();
        final marketName = cartItem['marketName'] ?? 'Unknown Market';
        int shippingFee = cartItem['shippingFee'] ?? 0;

        if (cartItem['donaId'] != null) {
          shippingFee = 1000; // 기부글의 경우 배송비 1000원
        }

        // 마켓 이름이 중복되지 않으면 배송비 추가
        if (!processedMarkets.contains(marketName)) {
          totalShippingFee += shippingFee;
          processedMarkets.add(marketName); // 마켓 이름을 처리된 목록에 추가
        }

        totalProductPrice += price;
      }
    }

    totalPrice = totalProductPrice + totalShippingFee;

    setState(() {
      _totalPrice = totalPrice;
      this.totalProductPrice = totalProductPrice;
      this.totalShippingFee = totalShippingFee;
    });
  }

  // 결제 페이지로 이동하는 함수
  void _goToPayPage(List<Map<String, dynamic>> cartItems) {
    final selectedItems = cartItems
        .where((item) => _selectedItems[item['sellId'] ?? item['donaId']] ?? false)
        .toList();

    // 선택된 아이템과 배송비를 확인하는 print
    selectedItems.forEach((item) {
      print('Selected item: ${item['title']}, ShippingFee: ${item['shippingFee']}');
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayPage(cartItems: selectedItems),
      ),
    );
  }

}
