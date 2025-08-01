import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_bloc.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_event.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_state.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  final BluetoothBloc bluetoothBloc;
  const MyHomePage({super.key, required this.bluetoothBloc});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription<BluetoothState> _bluetoothStateSubscription;

  @override
  void initState() {
    super.initState();
    // Ne lance pas de scan automatique ici
    widget.bluetoothBloc.add(
      BluetoothStatusChanged(fb.BluetoothAdapterState.unknown),
    );
    _bluetoothStateSubscription = widget.bluetoothBloc.stream.listen((_) {
      setState(() {}); // Pour forcer rebuild si besoin
    });
  }

  @override
  void dispose() {
    _bluetoothStateSubscription.cancel();
    super.dispose();
  }

  Future<bool> requestBluetoothPermissions() async {
    final statusScan = await Permission.bluetoothScan.request();
    final statusConnect = await Permission.bluetoothConnect.request();
    final statusLocation = await Permission.locationWhenInUse.request();

    return statusScan.isGranted &&
        statusConnect.isGranted &&
        statusLocation.isGranted;
  }

  void _startScan() async {
    final granted = await requestBluetoothPermissions();
    if (granted) {
      widget.bluetoothBloc.add(ScanStarted());
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions Bluetooth et localisation requises'),
          ),
        );
      }
    }
  }

  void _stopScan() {
    widget.bluetoothBloc.add(ScanStopped());
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
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final state = snapshot.data!;

              if (state.bluetoothAdapterState != fb.BluetoothAdapterState.on) {
                return IconButton(
                  onPressed: null,
                  icon: const Icon(Icons.bluetooth_disabled),
                );
              }

              if (state.scanStatus == BluetoothStateStatus.scanning) {
                return IconButton(
                  onPressed: _stopScan,
                  icon: const Icon(Icons.stop),
                  tooltip: 'Arrêter le scan',
                );
              }

              return IconButton(
                onPressed: _startScan,
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Démarrer le scan',
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<BluetoothState>(
        initialData: widget.bluetoothBloc.state,
        stream: widget.bluetoothBloc.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final state = snapshot.data!;

          if (state.bluetoothAdapterState != fb.BluetoothAdapterState.on) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_getBluetoothStatusMessage(state.bluetoothAdapterState)),
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.bluetooth_disabled,
                    color: Colors.red,
                    size: 60,
                  ),
                ],
              ),
            );
          }

          final devices = state.discoveredDevices;

          if (devices.isEmpty) {
            return const Center(
              child: Text('Aucun appareil trouvé à proximité'),
            );
          }

          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ListTile(
                leading: const Icon(Icons.bluetooth),
                title: Text(device.name.isEmpty ? '(Inconnu)' : device.name),
                subtitle: Text(device.id ?? ''),
              );
            },
          );
        },
      ),
    );
  }

  String _getBluetoothStatusMessage(fb.BluetoothAdapterState state) {
    switch (state) {
      case fb.BluetoothAdapterState.unavailable:
        return 'Bluetooth indisponible';
      case fb.BluetoothAdapterState.unauthorized:
        return 'Bluetooth non autorisé';
      case fb.BluetoothAdapterState.off:
        return 'Bluetooth désactivé';
      case fb.BluetoothAdapterState.on:
        return 'Bluetooth activé';
      default:
        return 'État Bluetooth inconnu';
    }
  }
}
