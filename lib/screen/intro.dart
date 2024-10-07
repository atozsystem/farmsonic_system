import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'connect_device.dart';  // ConnectDeviceScreen 파일 import

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  void initState() {
    super.initState();

    // 3초 후 ConnectDeviceScreen으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      Get.to(() => ConnectDeviceScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // 흰색 배경
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 위아래 여백 생성
        children: [
          Spacer(),  // 상단 여백
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Text(
              'Farmsonic System',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic
              ),
            ),
          ),
          Spacer(),  // 중앙에 텍스트를 배치하기 위해 Spacer 사용
          Align(
            alignment: Alignment.bottomCenter,  // 이미지 하단 중앙 정렬
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),  // 하단에 약간의 여백 추가
              child: Image.asset(
                'assets/인트로로고.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
