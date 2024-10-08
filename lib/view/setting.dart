import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  bool _isLoading = false;  // 로딩 상태 관리

  // 공백 오류 검증 함수
  bool _isInputValid() {
    if (_ssidController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _urlController.text.isEmpty) {
      return false;
    }
    return true;
  }

  // 데이터를 로컬에 저장하는 함수
  Future<void> _saveSettings() async {
    if (!_isInputValid()) {
      // 공백 오류 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('wifi_ssid', _ssidController.text);
      await prefs.setString('wifi_password', _passwordController.text);
      await prefs.setString('url', _urlController.text);

      print("설정이 저장되었습니다: SSID=${_ssidController.text}, URL=${_urlController.text}");

      // 저장 완료 메시지 표시 (Snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정이 성공적으로 저장되었습니다!')),
      );
    } catch (e) {
      print("설정 저장 중 오류 발생: $e");

      // 오류 메시지 표시 (Snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정 저장 중 오류가 발생했습니다.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // 저장된 데이터를 불러오는 함수
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ssidController.text = prefs.getString('wifi_ssid') ?? '';
      _passwordController.text = prefs.getString('wifi_password') ?? '';
      _urlController.text = prefs.getString('url') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();  // 화면 로드시 저장된 설정을 불러오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('설정 화면'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(labelText: 'Wi-Fi: SSID'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Wi-Fi: 비밀번호'),
              obscureText: true,  // 비밀번호 필드 숨김 처리
            ),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()  // 로딩 상태 표시
                : ElevatedButton(
              onPressed: _saveSettings,  // 연결 대신 저장 기능
              child: const Text('저장'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
