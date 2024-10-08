import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import 'setting.dart';

class InAppWebViewScreen extends StatelessWidget {
  final String url;

  const InAppWebViewScreen({required this.url, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('AtoZ System'),
        backgroundColor: Colors.blue,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.black), // 메뉴 아이콘 색상 변경 (검정색)
                onPressed: () {
                  Scaffold.of(context).openEndDrawer(); // 메뉴 아이콘을 누르면 Drawer 열기
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            // InAppWebView는 화면의 대부분을 차지하도록 설정
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(url)), // WebUri 생성자 사용
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InAppWebViewScreen(
                      url: 'http://192.168.0.1/setup',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼 배경색 (파란색)
                padding: const EdgeInsets.symmetric(vertical: 16.0), // 버튼 패딩
                textStyle: const TextStyle(fontSize: 15),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('공장 초기화', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('설정'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const SettingScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('종료'),
              onTap: () {
                Get.back();
                _showExitDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("종료"),
          content: const Text("앱을 종료하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: const Text("아니오"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("예"),
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
