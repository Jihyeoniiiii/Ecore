import 'package:flutter/material.dart';
import '../cosntants/common_color.dart';
import '../repo/sell_post_network_repo.dart';

class CategoryBtn extends StatefulWidget {
  final ValueChanged<String> onCategorySelected;

  const CategoryBtn({required this.onCategorySelected, super.key});

  @override
  State<CategoryBtn> createState() => _CategoryBtnState();
}

class _CategoryBtnState extends State<CategoryBtn> {
  final List<Map<String, String>> categories = [
    {'category': '상의'},
    {'category': '하의'},
    {'category': '가방'},
    {'category': '신발'},
    {'category': '기타'}, // 기타 카테고리 추가
  ];

  String? selectedCategory; // 선택된 카테고리 없음

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼들 간의 간격을 동일하게 조정
      children: categories.map((category) {
        final isSelected = selectedCategory == category['category'];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4), // 좌우 패딩 조정
          child: Container(
            constraints: BoxConstraints(maxWidth: 60, maxHeight: 45), // 최대 너비 제한
            decoration: BoxDecoration(
              color: isSelected ? baseColor : Colors.white, // 선택된 카테고리 색상
              borderRadius: BorderRadius.circular(20), // 둥글게
              border: Border.all(color: baseColor!), // 테두리 색상
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  selectedCategory = category['category']; // 선택된 카테고리 업데이트
                });
                sellPostNetworkRepo.getData(selectedCategory!);
                widget.onCategorySelected(selectedCategory!);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12), // 수직 패딩 조정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // 둥글게
                ),
              ),
              child: Text(
                category['category']!,
                style: TextStyle(
                  fontSize: 14, // 폰트 크기 조정
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.grey[600], // 선택된 카테고리 텍스트 색상
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
