import 'dart:async';

import 'package:bluetooth_detect_01/widgets/device_list_item.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_bloc.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_event.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_state.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: Text(
          'SCANNER BLUETOOTH',
          style: GoogleFonts.koHo(
            textStyle: TextStyle(
              color: Colors.white,
              letterSpacing: .5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: const Color(0xffB1602E),
        actions: [
          BlocBuilder<BluetoothBloc, BluetoothState>(
            builder: (context, state) {
              if (state.bluetoothAdapterState != fb.BluetoothAdapterState.on) {
                return IconButton(
                  onPressed: null,
                  icon: const Icon(
                    Icons.bluetooth_disabled_rounded,
                    color: Colors.white,
                  ),
                );
              }

              if (state.scanStatus == BluetoothStateStatus.scanning) {
                return IconButton(
                  onPressed: () => _stopScan(context),
                  icon: const Icon(Icons.stop_rounded),
                  color: Colors.white,
                  //tooltip: 'Arrêter le scan',
                );
              }

              return IconButton(
                onPressed: () => _startScan(context),
                icon: const Icon(Icons.play_arrow_rounded),
                color: Colors.white,
                //tooltip: 'Démarrer le scan',
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
                  Text(
                    _getBluetoothStatusMessage(state.bluetoothAdapterState),
                    style: GoogleFonts.koHo(
                      textStyle: TextStyle(
                        color: const Color(0xff565659),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    Icons.bluetooth_disabled,
                    color: Colors.red[900],
                    size: 60,
                  ),
                  Text(
                    style: GoogleFonts.koHo(
                      textStyle: TextStyle(
                        color: const Color(0xff565659),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    state.bluetoothAdapterState ==
                            fb.BluetoothAdapterState.unavailable
                        ? 'Votre téléphone ne peut pas utiliser le bluetooth.'
                        : "Veuillez activer le bluetooth sur votre téléphone.",
                  ),
                ],
              ),
            );
          }

          final devices = state.discoveredDevices;

          if (devices.isEmpty) {
            return Center(
              child: Text(
                'Aucun appareil trouvé à proximité.',
                style: GoogleFonts.koHo(
                  textStyle: TextStyle(
                    color: const Color(0xff565659),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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
