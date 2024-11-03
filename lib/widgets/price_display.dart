import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceDisplay extends StatelessWidget {
  final int price;
  final double fontSize; // 추가된 매개변수

  PriceDisplay({required this.price, this.fontSize = 14}); // 기본값은 14

  @override
  Widget build(BuildContext context) {
    // 숫자를 쉼표가 들어간 문자열로 포맷팅
    final formattedPrice = NumberFormat('#,###').format(price);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.0),
      child: Text(
        '$formattedPrice', // 쉼표가 들어간 숫자 표시
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize, // 전달받은 fontSize 사용
        ),
      ),
    );
  }
}
