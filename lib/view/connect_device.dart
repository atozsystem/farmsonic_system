import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wifi_iot/wifi_iot.dart';
import '../controller/wificontroller.dart';
import 'setting.dart';
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
  final WifiController _wifiController = Get.put(
      WifiController()); // WifiController 인스턴스 생성

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
        _wifiList = networks?.where((network) {
          // FARM_AP와 AtoZ_LAB만 필터링
          return network.ssid == "FARM_AP" || network.ssid == "AtoZ_LAB";
        }).toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print("Wi-Fi 목록 로드 중 오류 발생: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('AtoZ System'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.home, size: 30,),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const ConnectDeviceScreen()),
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
                      onPressed: () => _wifiController.connectToWifi(ssid),
                      // WifiController 사용
                      child: const Text('연결'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(50, 40),
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
                leading: const Icon(Icons.home),
                title: const Text("홈"),
                onTap: () {
                  Get.back();
                  Get.to(ConnectDeviceScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('설정'),
                onTap: () {
                  Get.back();
                  Get.to(SettingScreen());
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
      ),
    );
  }

  void _showExitDialog() {
    Get.defaultDialog(
      title: "종료",
      content: const Text("앱을 종료하시겠습니까?"),
      actions: <Widget>[
        TextButton(
          child: const Text("아니오"),
          onPressed: () {
            Get.back(); // 다이얼로그 닫기
          },
        ),
        TextButton(
          child: const Text("예"),
          onPressed: () {
            Get.back(); // 다이얼로그 닫기
            _exitApp(); // 앱 종료 함수 호출
          },
        ),
      ],
    );
  }

  void _exitApp() {
    SystemNavigator.pop(); // 앱 종료
  }
}