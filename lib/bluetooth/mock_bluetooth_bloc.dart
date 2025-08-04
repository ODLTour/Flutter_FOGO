// lib/bluetooth/mock_bluetooth_bloc.dart
import 'dart:async';
import 'dart:math';

import 'package:bluetooth_detect_01/bluetooth/bluetooth_bloc.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_event.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_state.dart';
import 'package:faker/faker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;

class MockBluetoothBloc extends BluetoothBloc {
  Timer? _mockScanTimer;
  final Faker _faker = Faker();
  final Random _random = Random();

  @override
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

    _mockScanTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final mockDevice = _createMockScanResult();
      add(DeviceDiscovered(mockDevice));
    });
  }

  @override
  Future<void> handleScanStopped(
    ScanStopped event,
    Emitter<BluetoothState> emit,
  ) async {
    _mockScanTimer?.cancel();
    emit(state.copyWith(scanStatus: BluetoothStateStatus.stop));
  }

  @override
  Future<void> close() {
    _mockScanTimer?.cancel();
    return super.close();
  }

  fb.ScanResult _createMockScanResult() {
    final String fakeName =
        '${_faker.vehicle.make()} ${_faker.vehicle.model()}';
    final fb.DeviceIdentifier fakeRemoteId = fb.DeviceIdentifier(
      _faker.guid.guid(),
    );

    final fakeDevice = fb.BluetoothDevice(remoteId: fakeRemoteId);

    return fb.ScanResult(
      device: fakeDevice,
      advertisementData: fb.AdvertisementData(
        advName: fakeName,
        txPowerLevel: null,
        connectable: true,
        manufacturerData: {},
        serviceData: {},
        serviceUuids: [],
        appearance: 0,
      ),
      rssi: -30 + _random.nextInt(40),
      timeStamp: DateTime.now(),
    );
  }
}
