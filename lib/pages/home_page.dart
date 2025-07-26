import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'dart:async';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothAdapterState _bluetoothAdapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((
      state,
    ) {
      _bluetoothAdapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  String _getBluetoothStatusMessage(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.unavailable:
        return 'BluetoothAdapterState.unavailable';
      case BluetoothAdapterState.unauthorized:
        return 'BluetoothAdapterState.unauthorized';
      case BluetoothAdapterState.off:
        return 'BluetoothAdapterState.off';
      case BluetoothAdapterState.on:
        return 'BluetoothAdapterState.on';
      default:
        return 'default';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner Bluetooth')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getBluetoothStatusMessage(_bluetoothAdapterState),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: _bluetoothAdapterState == BluetoothAdapterState.on
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
