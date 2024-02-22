import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  List<ScanResult> devices = [];
  
  Future scanDevices() async {
    // Start scanning for 5 seconds
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Listen to scanning results
    var subscription = FlutterBluePlus.scanResults.listen((results) {
      print("Hello. Results below:\n");
      for (ScanResult r in results) {
        print(r.device.platformName);
        devices.add(r);
      }
    });
    print(subscription);
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<void> connect(BluetoothDevice device) async {
    await device.connect();
  }
}
