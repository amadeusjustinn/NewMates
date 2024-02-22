import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Scanner'),
        ),
        body: Center(
          child: ScanButton(),
        ),
      ),
    );
  }
}

class ScanButton extends StatefulWidget {
  @override
  _ScanButtonState createState() => _ScanButtonState();
}

class _ScanButtonState extends State<ScanButton> {
  List<BluetoothDiscoveryResult> results = [];

  StreamSubscription<BluetoothDiscoveryResult>? subscription;
  final serial = FlutterBluetoothSerial.instance;

  void scanDevices() async {
    bool permissionStatus = false;
    PermissionStatus permissionAdvertise =
        await Permission.bluetoothAdvertise.request();
    PermissionStatus permissionConnect =
        await Permission.bluetoothConnect.request();
    PermissionStatus permissionScan = await Permission.bluetoothScan.request();
    permissionStatus = (permissionAdvertise == PermissionStatus.granted) &
        (permissionConnect == PermissionStatus.granted) &
        (permissionScan == PermissionStatus.granted);

    if (permissionStatus) {
      print("Listening. Results below:\n");
      subscription = serial.startDiscovery().listen((result) {
        setState(() {
          print("${result.device.name} found! Rssi: ${result.rssi}\n");
          final existingIdx = results.indexWhere(
              (element) => element.device.address == result.device.address);
          if (existingIdx > -1) {
            results[existingIdx] = result;
          } else {
            results.add(result);
          }
          results.map((r) => {print(r.device.name)});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: scanDevices,
          child: const Text('Scan Bluetooth Devices'),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: results.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(results[index].device.name!),
              subtitle: Text(results[index].rssi.toString()),
            );
          },
        ),
      ],
    );
  }
}
