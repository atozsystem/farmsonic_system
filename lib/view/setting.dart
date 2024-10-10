import 'package:farmsonic_system/view/connect_device.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';  // Get 패키지를 사용하기 위해 추가

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Scaffold Key 추가

  bool _isLoading = false; // 로딩 상태 관리

  // 공백 오류 검증 함수
  bool _isInputValid() {
    return _ssidController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _urlController.text.isNotEmpty;
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
      _ssidController.text = prefs.getString('wifi_ssid') ?? '저장된 SSID 없음';
      _passwordController.text = prefs.getString('wifi_password') ?? '저장된 비밀번호 없음';
      _urlController.text = prefs.getString('url') ?? '저장된 URL 없음';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings(); // 화면 로드시 저장된 설정을 불러오기
  }

  // 앱 종료 확인 대화상자
  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('종료 확인'),
          content: const Text('앱을 종료하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 대화상자 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 대화상자 닫기
                Get.back(); // 앱 종료
              },
              child: const Text('종료'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Scaffold Key 설정
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('설정 화면'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, size: 30, color: Colors.black), // 메뉴 아이콘 블랙으로 설정
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer(); // endDrawer 열기
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(labelText: '현재 저장된 Wi-Fi: SSID'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '현재 저장된 Wi-Fi: 비밀번호'),
              obscureText: true, // 비밀번호 필드 숨김 처리
            ),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: '현재 저장된 URL'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator() // 로딩 상태 표시
                : ElevatedButton(
              onPressed: _saveSettings, // 저장 기능
              child: const Text('저장'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

            ),
          ],
        ),
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
              leading: const Icon(Icons.home),
              title: const Text("홈"),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => ConnectDeviceScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('설정'),
              onTap: () {
                Navigator.pop(context); // Drawer 닫기
                Get.to(() => const SettingScreen()); // 설정 화면으로 이동
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('종료'),
              onTap: () {
                Navigator.pop(context); // Drawer 닫기
                _showExitDialog(); // 앱 종료 대화상자 표시
              },
            ),
          ],
        ),
      ),
    );
  }
}
