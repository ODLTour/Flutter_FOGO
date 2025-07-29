import 'package:bluetooth_detect_01/bluetooth/bluetooth_event.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_state.dart';
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
  // fb.BluetoothAdapterState _bluetoothAdapterState =
  //     fb.BluetoothAdapterState.unknown;
  // late StreamSubscription<fb.BluetoothAdapterState> _adapterStateSubscription;
  late StreamSubscription<BluetoothState> _bluetoothStateSubscription;

  @override
  void initState() {
    super.initState();
    widget.bluetoothBloc.add(
      BluetoothStatusChanged(fb.BluetoothAdapterState.unknown),
    );
    _bluetoothStateSubscription = widget.bluetoothBloc.stream.listen((state) {
      setState(() {});
    });
    // _adapterStateSubscription = fb.FlutterBluePlus.adapterState.listen((state) {
    //   _bluetoothAdapterState = state;
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
  }

  @override
  void dispose() {
    _bluetoothStateSubscription.cancel();
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
      appBar: AppBar(
        title: const Text('Scanner Bluetooth'),
        actions: [
          StreamBuilder<BluetoothState>(
            initialData: widget.bluetoothBloc.state,
            stream: widget.bluetoothBloc.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final state = snapshot.data!;

                if (state.bluetoothAdapterState !=
                    fb.BluetoothAdapterState.on) {
                  return IconButton(
                    onPressed: null,
                    icon: const Icon(Icons.bluetooth_disabled),
                  );
                }
                if (state.scanStatus == BluetoothStateStatus.scanning) {
                  return IconButton(
                    onPressed: () => widget.bluetoothBloc.add(ScanStopped()),
                    icon: const Icon(Icons.stop),
                  );
                }
                if (state.scanStatus == BluetoothStateStatus.stop) {
                  return IconButton(
                    onPressed: () => widget.bluetoothBloc.add(ScanStarted()),
                    icon: const Icon(Icons.start),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: StreamBuilder<BluetoothState>(
        initialData: widget.bluetoothBloc.state,
        stream: widget.bluetoothBloc.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final state = snapshot.data!;
            if (state.bluetoothAdapterState != fb.BluetoothAdapterState.on) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      _getBluetoothStatusMessage(state.bluetoothAdapterState),
                    ),
                    Icon(Icons.bluetooth_disabled, color: Colors.red),
                  ],
                ),
              );
            }
            if (state.scanStatus == BluetoothStateStatus.scanning) {
              //TODO
              //si la liste des appareils est vide
              //sinon
            }
            //TODO
            //si pas de scan en cours, afficher qqchose ?
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
