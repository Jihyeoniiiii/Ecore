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
    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: imgList.length,
          itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
              Image.asset(
                imgList[itemIndex],
                fit: BoxFit.cover, // 이미지를 꽉 차게 보여줍니다.
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
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_currentIndex + 1}/${imgList.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
