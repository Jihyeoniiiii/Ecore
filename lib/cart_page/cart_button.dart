import 'package:ecore/cart_page/pay_page.dart';
import 'package:ecore/cosntants/common_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/firestore/user_model.dart';

class CartBtn extends StatelessWidget {
  const CartBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Provider.of<UserModel>(context).cartStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 40),
              child: FloatingActionButton.extended(
                onPressed: null,
                label: Text(
                  'Loading...',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: Colors.blue[50],
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final cartItems = snapshot.data ?? [];
        int totalPrice = cartItems.fold(0, (sum, item) {
          final price = item['price'] as int? ?? 0;
          final quantity = item['quantity'] as int? ?? 1;
          return sum + (price * quantity);
        });

        final isCartEmpty = cartItems.isEmpty;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 40),
            child: FloatingActionButton.extended(
              onPressed: isCartEmpty ? null : () async {
                try {
                  // 주문 목록 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PayPage(
                        cartItems: cartItems,
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              label: Text(
                '${totalPrice}원  주문하기',
                style: TextStyle(fontSize: 15),
              ),
              backgroundColor: baseColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        );
      },
    );
  }
}
