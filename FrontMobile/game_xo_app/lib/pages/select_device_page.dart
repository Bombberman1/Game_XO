import 'dart:async';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './bt_dev_list_entry.dart';

class SelectBondedDevicePage extends StatefulWidget {
  final bool checkAvailability;

  const SelectBondedDevicePage({super.key, this.checkAvailability = true});

  @override
  SelectBondedDevicePageState createState() => SelectBondedDevicePageState();
}

enum FoundedDeviceAvailability {
  no,
  maybe,
  yes,
}

class FoundedDeviceWithAvailability {
  BluetoothDevice device;
  FoundedDeviceAvailability availability;
  int? rssi;

  FoundedDeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class SelectBondedDevicePageState extends State<SelectBondedDevicePage> {
  List<FoundedDeviceWithAvailability> devices =
      List<FoundedDeviceWithAvailability>.empty(growable: true);

  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool _isDiscovering = false;

  SelectBondedDevicePageState();

  @override
  void initState() {
    super.initState();

    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering) {
      _startDiscovery();
    }

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => FoundedDeviceWithAvailability(
                device,
                widget.checkAvailability
                    ? FoundedDeviceAvailability.maybe
                    : FoundedDeviceAvailability.yes,
              ),
            )
            .toList();
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var foundedDevice = i.current;
          if (foundedDevice.device == r.device) {
            foundedDevice.availability = FoundedDeviceAvailability.yes;
            foundedDevice.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription?.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
        .where(
          (foundedDevice) =>
              foundedDevice.availability == FoundedDeviceAvailability.yes,
        )
        .map((foundedDevice) => BluetoothDeviceListEntry(
              device: foundedDevice.device,
              rssi: foundedDevice.rssi,
              enabled:
                  foundedDevice.availability == FoundedDeviceAvailability.yes,
              onTap: () {
                Navigator.of(context).pop(foundedDevice.device);
              },
            ))
        .toList();
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                iconSize: 28,
                color: Colors.white,
                padding: const EdgeInsets.all(8),
              ),
              title: const Center(
                child: Text('Select device'),
              ),
              actions: <Widget>[
                _isDiscovering
                    ? FittedBox(
                        child: Container(
                          margin: const EdgeInsets.all(16.0),
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.replay),
                        onPressed: _restartDiscovery,
                        iconSize: 28,
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                      )
              ],
            ),
          ),
          Positioned(
            top: kToolbarHeight + 30,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(children: list),
            ),
          ),
        ],
      ),
    );
  }
}
