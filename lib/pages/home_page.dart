import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:bluetooth_detect_01/bluetooth/bluetooth_bloc.dart';

import 'dart:async';

class MyHomePage extends StatefulWidget {
  final BluetoothBloc bluetoothBloc; //
  const MyHomePage({super.key, required this.bluetoothBloc});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  fb.BluetoothAdapterState _bluetoothAdapterState =
      fb.BluetoothAdapterState.unknown;
  late StreamSubscription<fb.BluetoothAdapterState>
  _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription = fb.FlutterBluePlus.adapterState.listen((
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

  String _getBluetoothStatusMessage(fb.BluetoothAdapterState state) {
    switch (state) {
      case fb.BluetoothAdapterState.unavailable:
        return 'BluetoothAdapterState.unavailable';
      case fb.BluetoothAdapterState.unauthorized:
        return 'BluetoothAdapterState.unauthorized';
      case fb.BluetoothAdapterState.off:
        return 'BluetoothAdapterState.off';
      case fb.BluetoothAdapterState.on:
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
                color: _bluetoothAdapterState == fb.BluetoothAdapterState.on
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
