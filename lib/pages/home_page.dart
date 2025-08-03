import 'dart:async';

import 'package:bluetooth_detect_01/widgets/device_list_item.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_bloc.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_event.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_state.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Future<bool> requestBluetoothPermissions() async {
    final statusScan = await Permission.bluetoothScan.request();
    final statusConnect = await Permission.bluetoothConnect.request();
    final statusLocation = await Permission.locationWhenInUse.request();

    return statusScan.isGranted &&
        statusConnect.isGranted &&
        statusLocation.isGranted;
  }

  void _startScan(BuildContext context) async {
    final bluetoothBloc = context.read<BluetoothBloc>();
    final granted = await requestBluetoothPermissions();
    if (granted) {
      bluetoothBloc.add(ScanStarted());
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions Bluetooth et localisation requises'),
          ),
        );
      }
    }
  }

  void _stopScan(BuildContext context) {
    final bluetoothBloc = context.read<BluetoothBloc>();
    bluetoothBloc.add(ScanStopped());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Bluetooth'),
        actions: [
          BlocBuilder<BluetoothBloc, BluetoothState>(
            builder: (context, state) {
              if (state.bluetoothAdapterState != fb.BluetoothAdapterState.on) {
                return IconButton(
                  onPressed: null,
                  icon: const Icon(Icons.bluetooth_disabled),
                );
              }

              if (state.scanStatus == BluetoothStateStatus.scanning) {
                return IconButton(
                  onPressed: () => _stopScan(context),
                  icon: const Icon(Icons.stop),
                  tooltip: 'Arrêter le scan',
                );
              }

              return IconButton(
                onPressed: () => _startScan(context),
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Démarrer le scan',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BluetoothBloc, BluetoothState>(
        builder: (context, state) {
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
              return DeviceListItem(bluetoothDevice: device);
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
