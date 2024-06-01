import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import './pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _requestPermissions();

  runApp(const GameXO());
}

Future<void> _requestPermissions() async {
  await Permission.location.request();
  await Permission.bluetooth.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothScan.request();
  await Permission.bluetoothAdvertise.request();
  await Permission.locationWhenInUse.request();
  await Permission.locationAlways.request();
}

class GameXO extends StatelessWidget {
  const GameXO({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}
