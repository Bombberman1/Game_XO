import 'dart:async';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// ignore: depend_on_referenced_packages
import 'package:location/location.dart';

import './game_page.dart';
import './select_device_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  bool _isGpsEnabled = false;

  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  Timer? _gpsCheckTimer;
  Location location = Location();
  bool requestSended = false;

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {});
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        _discoverableTimeoutTimer = null;
      });
    });

    _checkGpsStatus();
    _startGpsStatusCheckTimer();
  }

  void _startGpsStatusCheckTimer() {
    _gpsCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkGpsStatus();
    });
  }

  Future<void> _checkGpsStatus() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled && !requestSended) {
      requestSended = true;
      serviceEnabled = await location.requestService();
    }
    if (serviceEnabled) {
      requestSended = false;
    }
    setState(() {
      _isGpsEnabled = serviceEnabled;
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    _gpsCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 90, 131, 202),
                  Color.fromARGB(255, 208, 167, 215),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent.withOpacity(0.05),
              elevation: 0,
              title: const Center(
                child: Text('Game X/O Settings'),
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight + 30,
            left: 0,
            right: 0,
            bottom: 0,
            child: ListView(
              children: <Widget>[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: const Text('Bluetooth status'),
                  subtitle: _bluetoothState == BluetoothState.STATE_ON
                      ? Row(children: const [
                          Icon(
                            Icons.bluetooth_connected_sharp,
                            color: Color.fromARGB(255, 26, 112, 183),
                          ),
                          Text(
                            'On',
                            style: TextStyle(
                                color: Color.fromARGB(255, 26, 112, 183)),
                          )
                        ])
                      : Row(children: const [
                          Icon(
                            Icons.bluetooth_disabled,
                          ),
                          Text(
                            'Off',
                          )
                        ]),
                  trailing: ElevatedButton.icon(
                    style: ButtonStyle(
                        elevation: const MaterialStatePropertyAll(0),
                        backgroundColor: MaterialStatePropertyAll(
                          Colors.transparent.withOpacity(0.05),
                        ),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )),
                    icon: const Icon(Icons.settings, color: Colors.black38),
                    label: const Text(
                      'Settings',
                      style: TextStyle(color: Colors.black38),
                    ),
                    onPressed: () {
                      FlutterBluetoothSerial.instance.openSettings();
                    },
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: const Text('Device name'),
                  subtitle: Text(_name),
                  onLongPress: null,
                ),
                const ListTile(title: SizedBox(height: 30)),
                (_bluetoothState == BluetoothState.STATE_ON && _isGpsEnabled)
                    ? ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 30),
                        title: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                Colors.transparent.withOpacity(0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ).copyWith(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            shadowColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          onPressed:
                              (_bluetoothState == BluetoothState.STATE_ON &&
                                      _isGpsEnabled)
                                  ? () async {
                                      final BluetoothDevice? selectedDevice =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return const SelectBondedDevicePage(
                                              checkAvailability: true,
                                            );
                                          },
                                        ),
                                      );

                                      if (selectedDevice != null) {
                                        print(
                                            'Connect -> selected ${selectedDevice.address}');
                                        if (mounted) {
                                          _startChat(context, selectedDevice);
                                        }
                                      } else {
                                        print('Connect -> no device selected');
                                      }
                                    }
                                  : null,
                          child: const Text(
                            'Connect',
                            style: TextStyle(color: Colors.black38),
                          ),
                        ),
                      )
                    : const ListTile()
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return GamePage(server: server);
        },
      ),
    );
  }
}
