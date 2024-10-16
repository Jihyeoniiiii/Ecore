import 'package:flutter/material.dart';

class SoldOutOverlay extends StatelessWidget {
  final bool isSoldOut;
  final double radius; // 원의 크기를 설정할 수 있는 파라미터
  final double borderRadius; // 외곽 반투명 배경의 둥글기 설정을 위한 파라미터 추가

  const SoldOutOverlay({
    Key? key,
    required this.isSoldOut,
    this.radius = 50, // 기본 radius 값
    this.borderRadius = 0.0, // 기본 borderRadius 값 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isSoldOut
        ? Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6), // 반투명 검정 배경
          borderRadius: BorderRadius.circular(borderRadius), // 외곽의 둥글기 적용
        ),
        child: Center(
          child: CircleAvatar(
            radius: radius, // 전달받은 radius 값 사용
            backgroundColor: Colors.transparent, // 원형 배경 투명 처리
            child: Container(
              width: radius * 2, // 원의 크기를 radius에 맞게 설정
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2), // 하얀색 테두리
                color: Colors.black.withOpacity(0.6), // 원형 배경 반투명 검정색
              ),
              child: Center(
                child: Text(
                  '판매 완료',
                  style: TextStyle(
                    color: Colors.white, // 텍스트를 화이트로 설정
                    fontSize: radius / 2.5, // radius에 비례한 텍스트 크기
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    )
        : SizedBox.shrink(); // 재고가 있을 때는 빈 공간 반환
  }
}
