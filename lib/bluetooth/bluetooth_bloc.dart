import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_event.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_state.dart';
import 'package:bluetooth_detect_01/bluetooth/models/bluetooth_device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  late StreamSubscription<fb.BluetoothAdapterState> _adapterStateSubscription;
  late final StreamSubscription<List<fb.ScanResult>> _scanResultsSubscription;

  BluetoothBloc() : super(const BluetoothState()) {
    on<ScanStarted>(handleScanStarted);
    on<ScanStopped>(handleScanStopped);
    on<BluetoothStatusChanged>(handleBluetoothStatusChanged);
    on<DeviceDiscovered>(handleDeviceDiscovered);
    _scanResultsSubscription = fb.FlutterBluePlus.scanResults.listen((devices) {
      for (var device in devices) {
        add(DeviceDiscovered(device));
      }
    });
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
    await fb.FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    emit(
      state.copyWith(
        scanStatus: BluetoothStateStatus.scanning,
        discoveredDevices: [],
      ),
    );
    if (kDebugMode) {
      debugPrint("Scan Started");
    }
  }

  Future<void> handleScanStopped(
    ScanStopped event,
    Emitter<BluetoothState> emit,
  ) async {
    await fb.FlutterBluePlus.stopScan();
    emit(
      state.copyWith(
        scanStatus: BluetoothStateStatus.stop,
        discoveredDevices: [],
      ),
    );
    if (kDebugMode) {
      debugPrint("Scan Stopped");
    }
  }

  Future<void> handleBluetoothStatusChanged(
    BluetoothStatusChanged event,
    Emitter<BluetoothState> emit,
  ) async {
    emit(state.copyWith(bluetoothAdapterState: event.status));
    if (kDebugMode) {
      debugPrint("State changed : ${event.status}");
    }
  }

  void handleDeviceDiscovered(
    DeviceDiscovered event,
    Emitter<BluetoothState> emit,
  ) {
    final newDevice = BluetoothDevice(
      id: event.deviceScanResult.device.remoteId.toString(),
      name: event.deviceScanResult.device.platformName,
      rssi: event.deviceScanResult.device.readRssi().toString(),
      scanResult: event.deviceScanResult,
    );
    final updatedDevices = List<BluetoothDevice>.from(state.discoveredDevices);
    final index = updatedDevices.indexWhere(
      (device) => device.id == newDevice.id,
    );
    if (index != -1) {
      updatedDevices[index] = newDevice;
      if (kDebugMode) {
        debugPrint("Device $index updated : $newDevice");
      }
    } else {
      updatedDevices.add(newDevice);
      if (kDebugMode) {
        debugPrint("Device added : $newDevice");
      }
    }
    emit(state.copyWith(discoveredDevices: updatedDevices));
  }

  @override
  Future<void> close() {
    _adapterStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    fb.FlutterBluePlus.stopScan();
    if (kDebugMode) {
      debugPrint("close");
    }
    return super.close();
  }
}
