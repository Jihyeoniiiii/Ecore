import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CareouselSlider extends StatefulWidget {
  const CareouselSlider({super.key});

  @override
  State<CareouselSlider> createState() => _CareouselSliderState();
}

class _CareouselSliderState extends State<CareouselSlider> {
  final List<String> imgList = [
    'assets/images/메인배너1.jpeg',
    'assets/images/메인배너2.jpeg',
    'assets/images/메인배너3.jpeg',
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: imgList.length,
          itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
              Container(
                child: Image.asset(
                  imgList[itemIndex],
                  fit: BoxFit.cover, // 이미지를 꽉 차게 보여줍니다.
                ),
              ),
          options: CarouselOptions(
            height: 250,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 4),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            viewportFraction: 1.0, // 화면을 가득 채우도록 설정
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = entry.key; // 현재 인덱스를 업데이트합니다.
                });
              },
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key
                      ? Colors.blueAccent
                      : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
