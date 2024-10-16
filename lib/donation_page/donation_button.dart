import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DonationBtn extends StatefulWidget {
  const DonationBtn({super.key});

  @override
  State<DonationBtn> createState() => _DonationBtnState();
}

class _DonationBtnState extends State<DonationBtn> {
  bool extended = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        height: 60,
        width: extended ? 60 : 120,
        child: extendButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  FloatingActionButton extendButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {});
      },
      label: const Text("기부하기"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

      /// 텍스트 컬러
      foregroundColor: Colors.white,
      backgroundColor: Colors.lightBlue,
    );
  }
}
