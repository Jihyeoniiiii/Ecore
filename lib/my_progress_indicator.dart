import 'package:flutter/material.dart';

class MyProgressIndicator extends StatelessWidget {
  final double containerSize;
  final double progressSize;

  const MyProgressIndicator({
    Key? key, // Key로 수정
    required this.containerSize, // required 키워드 추가
    this.progressSize = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      child: Center(
        child: SizedBox(
          height: progressSize,
          width: progressSize, // containerSize를 progressSize로 수정
          child: Image.asset('assets/images/loading.gif'),
        ),
      ),
    );
  }
}
