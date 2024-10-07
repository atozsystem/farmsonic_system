import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppWebViewScreen extends StatelessWidget {
  final String url;

  const InAppWebViewScreen({required this.url, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인앱 브라우저'),
        backgroundColor: Colors.blue,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)), // WebUri 생성자 사용
      ),
    );
  }
}
