import 'package:ecore/cart_page/cart_list.dart';
import 'package:flutter/material.dart';

class CartBanner extends StatelessWidget {

  const CartBanner({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('장바구니', style: TextStyle(fontFamily: 'NanumSquare',),),// Add BackButton to the AppBar
        ),
        body: CartList(),
    );
  }
}
