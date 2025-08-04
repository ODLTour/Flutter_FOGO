import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_event.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_state.dart';
import 'package:bluetooth_detect_01/bluetooth/models/bluetooth_device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  late StreamSubscription<fb.BluetoothAdapterState> _adapterStateSubscription;
  StreamSubscription<fb.ScanResult>? _scanSubscription;

  BluetoothBloc() : super(const BluetoothState()) {
    on<ScanStarted>(handleScanStarted);
    on<ScanStopped>(handleScanStopped);
    on<BluetoothStatusChanged>(handleBluetoothStatusChanged);
    on<DeviceDiscovered>(handleDeviceDiscovered);
    on<DeviceDeleteRequested>(handleDeviceDeleteRequested);
    on<DeviceRenameRequested>(handleDeviceRenameRequested);

    _adapterStateSubscription = fb.FlutterBluePlus.adapterState.listen((
      status,
    ) {
      add(BluetoothStatusChanged(status));
    });
  }

  Future<void> handleScanStarted(
    ScanStarted event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      await fb.FlutterBluePlus.stopScan(); // stoppe scan précédent si actif
      emit(
        state.copyWith(
          scanStatus: BluetoothStateStatus.scanning,
          discoveredDevices: [],
        ),
      );

      // Annule une subscription précédente pour éviter les conflits
      await _scanSubscription?.cancel();

      // Écoute en mode "legacy" et dispatch des événements individuels
      _scanSubscription = fb.FlutterBluePlus.scanResults
          .expand((list) => list)
          .listen((scanResult) {
            add(DeviceDiscovered(scanResult));
          });

      await fb.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true, // ✅ important !
      );
    } catch (e) {
      emit(state.copyWith(scanStatus: BluetoothStateStatus.error));
    }
  }

  Future<void> handleScanStopped(
    ScanStopped event,
    Emitter<BluetoothState> emit,
  ) async {
    await fb.FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();

    emit(
      state.copyWith(
        scanStatus: BluetoothStateStatus.stop,
        discoveredDevices:
            [], // A commenter si on ne veut pas vider la liste à la fin du scan
      ),
    );
  }

  Future<void> handleBluetoothStatusChanged(
    BluetoothStatusChanged event,
    Emitter<BluetoothState> emit,
  ) async {
    emit(state.copyWith(bluetoothAdapterState: event.status));
    if (kDebugMode) {
      debugPrint("Bluetooth state changé : ${event.status}");
    }
  }

  void handleDeviceDiscovered(
    DeviceDiscovered event,
    Emitter<BluetoothState> emit,
  ) {
    final scanResult = event.deviceScanResult;
    final newDevice = BluetoothDevice(
      id: scanResult.device.remoteId.toString(),
      name: scanResult.device.platformName,
      rssi: scanResult.rssi.toString(),
      scanResult: scanResult,
    );
    final updatedDevices = List<BluetoothDevice>.from(state.discoveredDevices);
    final index = updatedDevices.indexWhere((dev) => dev.id == newDevice.id);
    if (index != -1) {
      updatedDevices[index] = newDevice;
      debugPrint("App updated: ${newDevice.name} (RSSI ${newDevice.rssi})");
    } else {
      updatedDevices.add(newDevice);
      debugPrint("App added: ${newDevice.name} (RSSI ${newDevice.rssi})");
    }
    emit(state.copyWith(discoveredDevices: updatedDevices));
  }

  void handleDeviceDeleteRequested(
    DeviceDeleteRequested event,
    Emitter<BluetoothState> emit,
  ) {
    final updatedDevices = List<BluetoothDevice>.from(state.discoveredDevices)
      ..removeWhere((device) => device.id == event.deviceId);

    emit(state.copyWith(discoveredDevices: updatedDevices));
  }

  void handleDeviceRenameRequested(
    DeviceRenameRequested event,
    Emitter<BluetoothState> emit,
  ) {
    final updatedDevices = List<BluetoothDevice>.from(state.discoveredDevices);
    final index = updatedDevices.indexWhere(
      (device) => device.id == event.deviceId,
    );
    if (index != -1) {
      final oldDevice = updatedDevices[index];
      updatedDevices[index] = BluetoothDevice(
        id: oldDevice.id,
        name: event.newName,
        rssi: oldDevice.rssi,
        scanResult: oldDevice.scanResult,
      );
    }
    emit(state.copyWith(discoveredDevices: updatedDevices));
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    _adapterStateSubscription.cancel();
    fb.FlutterBluePlus.stopScan();
    if (kDebugMode) {
      debugPrint("BluetoothBloc fermé");
    }
    return super.close();
  }
}
