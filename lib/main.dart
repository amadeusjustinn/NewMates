import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
  List<DiscoveredDevice> devices = [];
  final flutterReactiveBle = FlutterReactiveBle();

  void scanDevices() async {
    bool permissionStatus = false;
    // await FlutterBluePlus.startScan(timeout: const Duration(seconds: 100));
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
      flutterReactiveBle.scanForDevices(withServices: []).listen((result) {
        // code for handling results
        print("${result.name} found!\n");
        setState(() {
          devices.add(result);
        });
      }, onError: (e) {
        print("Houston, we've got a problem.\n$e");
      });
    }
    // FlutterBluePlus.scanResults.listen((results) {
    //   for (ScanResult result in results) {
    //     print(result);
    //     setState(() {
    //       devices.add(result);
    //     });
    //   }
    // });
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
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(devices[index].name),
              subtitle: Text(devices[index].id),
            );
          },
        ),
      ],
    );
  }
}
