import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class GamePage extends StatefulWidget {
  final BluetoothDevice server;

  const GamePage({super.key, required this.server});

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  BluetoothConnection? connection;

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;
  final List<bool> _tapped = List.filled(9, false);

  @override
  void initState() {
    super.initState();

    _connectToBluetooth();
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  void _connectToBluetooth() {
    BluetoothConnection.toAddress(widget.server.address).then((connectionArg) {
      print('Connected to the device');
      connection = connectionArg;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
    }).catchError((error) {
      print('Cannot connect, exception occurred');
      print(error);
    });
  }

  void _onTapCell(int index) {
    _sendMessage(index.toString());

    setState(() {
      _tapped[index] = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _tapped[index] = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final serverName = widget.server.name ?? "Unknown";
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
              leading: SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  iconSize: 28,
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              title: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: Center(
                        child: isConnecting
                            ? serverName.length <= 10
                                ? Text('Connecting to $serverName...')
                                : Text(
                                    'Connecting to ${serverName.substring(0, 10)}...')
                            : isConnected
                                ? const Text('Game X/O')
                                : serverName.length <= 10
                                    ? Text('Log with $serverName')
                                    : Text(
                                        'Log with ${serverName.substring(0, 10)}')),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: <Widget>[
              const SizedBox(height: kToolbarHeight + 30),
              Container(
                margin: const EdgeInsets.all(48.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _onTapCell(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          gradient: _tapped[index]
                              ? LinearGradient(
                                  colors: [
                                    const Color.fromARGB(255, 90, 131, 202)
                                        .withOpacity(0.5),
                                    const Color.fromARGB(255, 208, 167, 215)
                                        .withOpacity(0.5),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.8),
                                    Colors.white.withOpacity(0.5)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: SizedBox.shrink(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.isNotEmpty && isConnected) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text)));
        await connection!.output.allSent;
      } catch (e) {
        setState(() {});
      }
    } else {
      print('Connection Lost');
    }
  }
}
