import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wifi_iot/wifi_iot.dart';
import '../view/in_app_web_view_screen.dart';

class WifiController extends GetxController {
  Future<void> connectToWifi(String ssid) async {
    try {
      // 연결 중임을 알리는 메시지
      Get.snackbar("연결 중입니다...", "", duration: Duration(seconds: 2));

      bool isConnected = false;

      if (ssid == "FARM_AP") {
        isConnected = await WiFiForIoTPlugin.connect(
          ssid,
          password: "12345678",
          joinOnce: true,
          withInternet: true,
          security: NetworkSecurity.WPA,
        );
      } else {
        isConnected = await WiFiForIoTPlugin.connect(ssid,
            joinOnce: true, withInternet: true);
      }

      if (isConnected) {
        // Get.snackbar("연결 성공!", "$ssid에 연결되었습니다.",
        // backgroundColor: Colors.white);
        // 연결 성공 후 InAppWebViewScreen으로 이동
        Get.to(() => InAppWebViewScreen(url: 'http://192.168.0.1'));
      } else {
        _showReconnectDialog(ssid);
      }
    } catch (e) {
      print("연결 중 오류 발생: $e");
      _showReconnectDialog(ssid);
    }
  }

  void _showReconnectDialog(String ssid) {
    Get.defaultDialog(
      title: "연결 실패",
      middleText: "연결에 실패했습니다. \n다시 시도하시겠습니까?",
      confirm: TextButton(
        onPressed: () {
          Get.back();
          connectToWifi(ssid);
        },
        child: const Text("예"),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("아니오"),
      ),
    );
  }
}
