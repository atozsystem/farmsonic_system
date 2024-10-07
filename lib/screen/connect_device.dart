import 'package:farmsonic_system/screen/setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_iot/wifi_iot.dart';

class ConnectDeviceScreen extends StatefulWidget {
  const ConnectDeviceScreen({super.key});

  @override
  _ConnectDeviceScreenState createState() => _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends State<ConnectDeviceScreen> {
  List<WifiNetwork> _wifiList = [];
  bool _isLoading = true;  // 로딩 상태를 나타내는 변수
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadWifiList();
  }

  Future<void> _loadWifiList() async {
    setState(() {
      _isLoading = true;  // 로딩 상태로 변경
    });

    try {
      List<WifiNetwork>? networks = await WiFiForIoTPlugin.loadWifiList();
      setState(() {
        _wifiList = networks ?? [];
        _isLoading = false;  // Wi-Fi 목록 로딩 완료 시 로딩 상태 해제
      });
    } catch (e) {
      print("Wi-Fi 목록 로드 중 오류 발생: $e");
      setState(() {
        _isLoading = false;  // 오류 발생 시에도 로딩 상태 해제
      });
    }
  }

  Future<void> _connectToWifi(String ssid) async {
    try {
      if (ssid == "AtoZ_LAB") {
        bool isConnected = await WiFiForIoTPlugin.connect(ssid,
            password: "atoz9897!",
            joinOnce: true,
            withInternet: true,
            security: NetworkSecurity.WPA); // WPA 보안 방식 사용

        if (isConnected) {
          print("Wi-Fi 연결 성공: $ssid");
          _launchURL('192.168.0.1');
        } else {
          print("Wi-Fi 연결 실패");
        }
      } else {
        bool isConnected = await WiFiForIoTPlugin.connect(ssid,
            joinOnce: true,
            withInternet: true);
        if (isConnected) {
          print("Wi-Fi 연결 성공: $ssid");
        } else {
          print("Wi-Fi 연결 실패");
        }
      }
    } catch (e) {
      print("Wi-Fi 연결 중 오류 발생: $e");
    }
  }

  void _launchURL(String url) async {
    final formattedUrl = url.startsWith('http') ? url : 'http://$url';

    if (await canLaunch(formattedUrl)) {
      await launch(formattedUrl);
    } else {
      throw 'Could not launch $formattedUrl';
    }
  }

  void _showExitDialog() {
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
                _exitApp();
              },
            ),
          ],
        );
      },
    );
  }

  void _exitApp() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,  // GlobalKey 추가
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('AtoZ System'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, size: 30,),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const ConnectDeviceScreen()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, size: 30,color: Colors.black,),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();  // EndDrawer 열기
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 입체적인 "연결 가능한 디바이스 목록" 부분
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "연결 가능한 디바이스 목록",
                  style: TextStyle(fontSize: 18),
                ),
                const Icon(Icons.wifi),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),  // 로딩 중일 때 로딩 인디케이터 표시
            )
                : _wifiList.isEmpty
                ? const Center(
              child: Text("Wi-Fi 네트워크를 찾을 수 없습니다."),
            )
                : ListView.builder(
              itemCount: _wifiList.length,
              itemBuilder: (context, index) {
                String ssid = _wifiList[index].ssid!;
                return ListTile(
                  title: Text(ssid),
                  trailing: ElevatedButton(
                    onPressed: () => _connectToWifi(ssid),
                    child: const Text('연결'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // 버튼 배경색을 파란색으로 설정
                      foregroundColor: Colors.white,  // 글자색
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(  // EndDrawer로 변경
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
                Get.to(() => const SettingScreen());// 드로어 닫기
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('종료'),
              onTap: () {
                Get.back(); // 드로어 닫기
                _showExitDialog(); // 종료 다이얼로그 열기
              },
            ),
          ],
        ),
      ),
    );
  }
}
