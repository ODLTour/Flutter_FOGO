import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:bluetooth_detect_01/bluetooth/models/bluetooth_device.dart';

enum BluetoothStateStatus { init, scanning, stop, error }

class BluetoothState extends Equatable {
  const BluetoothState({
    this.scanStatus = BluetoothStateStatus.init,
    this.discoveredDevices = const [],
    this.bluetoothAdapterState = fb.BluetoothAdapterState.unknown,
  });
  final BluetoothStateStatus scanStatus;
  final List<BluetoothDevice> discoveredDevices;
  final fb.BluetoothAdapterState bluetoothAdapterState;

  @override
  List<Object> get props => [
    scanStatus,
    discoveredDevices,
    bluetoothAdapterState,
  ];

  BluetoothState copyWith({
    BluetoothStateStatus? scanStatus,
    List<BluetoothDevice>? discoveredDevices,
    fb.BluetoothAdapterState? bluetoothAdapterState,
  }) {
    return BluetoothState(
      scanStatus: scanStatus ?? this.scanStatus,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
    );
  }
}
