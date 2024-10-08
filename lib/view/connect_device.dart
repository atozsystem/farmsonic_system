import 'package:farmsonic_system/view/setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'in_app_web_view_screen.dart';

class ConnectDeviceScreen extends StatefulWidget {
  const ConnectDeviceScreen({super.key});

  @override
  _ConnectDeviceScreenState createState() => _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends State<ConnectDeviceScreen> {
  List<WifiNetwork> _wifiList = [];
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadWifiList();
  }

  Future<void> _loadWifiList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<WifiNetwork>? networks = await WiFiForIoTPlugin.loadWifiList();
      setState(() {
        _wifiList = networks ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print("Wi-Fi 목록 로드 중 오류 발생: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _connectToWifi(String ssid) async {
    try {
      _showSnackbarMessage("연결 중입니다..."); // 연결 중 Snackbar 메시지 표시

      if (ssid == "FARM_AP") {
        bool isConnected = await WiFiForIoTPlugin.connect(
          ssid,
          password: "12345678",
          joinOnce: true,
          withInternet: true,
          security: NetworkSecurity.WPA,
        );

        if (isConnected) {
          print("연결 성공: $ssid");
          _showSnackbarMessage("Wi-Fi 연결 성공!"); // 연결 성공 Snackbar 메시지 표시
          _launchInAppBrowser('http://192.168.0.1');  // 인앱 브라우저로 열기
        } else {
          print("연결 실패");
          _showReconnectDialog(ssid); // 연결 실패 시 재연결 여부 묻는 다이얼로그 표시
        }
      } else {
        bool isConnected = await WiFiForIoTPlugin.connect(ssid,
            joinOnce: true, withInternet: true);
        if (isConnected) {
          print("연결 성공: $ssid");
          _showSnackbarMessage("연결 성공!"); // 연결 성공 Snackbar 메시지 표시
        } else {
          print("연결 실패");
          _showReconnectDialog(ssid); // 연결 실패 시 재연결 여부 묻는 다이얼로그 표시
        }
      }
    } catch (e) {
      print("연결 중 오류 발생: $e");
      _showReconnectDialog(ssid); // 오류 발생 시에도 재연결 여부 묻는 다이얼로그 표시
    }
  }

  void _showReconnectDialog(String ssid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("연결 실패"),
          content: const Text("연결에 실패했습니다. 다시 시도하시겠습니까?"),
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
                _connectToWifi(ssid); // 재연결 시도
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackbarMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black,
      ),
    );
  }

  void _launchInAppBrowser(String url) {
    Get.to(() => InAppWebViewScreen(url: url));
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
      key: _scaffoldKey,
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
            icon: const Icon(Icons.menu, size: 30, color: Colors.black,),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "연결 가능한 디바이스 목록",
                  style: TextStyle(fontSize: 18),
                ),
                Icon(Icons.wifi),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
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
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                );
              },
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
                _showExitDialog();
              },
            ),
          ],
        ),
      ),
    );
  }
}
