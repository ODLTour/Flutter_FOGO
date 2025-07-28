import 'package:bloc/bloc.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_event.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_state.dart';
import 'package:flutter/foundation.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  BluetoothBloc() : super(const BluetoothState()) {
    on<ScanStarted>(handleScanStarted);
    on<ScanStopped>(handleScanStopped);
    on<BluetoothStatusChanged>(handleBluetoothStatusChanged);
  }

  Future<void> handleScanStarted(
    ScanStarted event,
    Emitter<BluetoothState> emit,
  ) async {
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
}
