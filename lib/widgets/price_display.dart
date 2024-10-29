import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceDisplay extends StatelessWidget {
  final int price;

  PriceDisplay({required this.price});

  @override
  Widget build(BuildContext context) {
    // 숫자를 쉼표가 들어간 문자열로 포맷팅
    final formattedPrice = NumberFormat('#,###').format(price);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
      child: Text(
        '$formattedPrice원', // 쉼표가 들어간 숫자 표시
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
