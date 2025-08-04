import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();

  @override
  List<Object> get props => [];
}

class ScanStarted extends BluetoothEvent {}

class ScanStopped extends BluetoothEvent {}

class BluetoothStatusChanged extends BluetoothEvent {
  final BluetoothAdapterState status;

  const BluetoothStatusChanged(this.status);

  @override
  List<Object> get props => [status];
}

class DeviceDiscovered extends BluetoothEvent {
  final ScanResult deviceScanResult;

  const DeviceDiscovered(this.deviceScanResult);

  @override
  List<Object> get props => [deviceScanResult];
}

class DeviceDeleteRequested extends BluetoothEvent {
  final String deviceId;

  const DeviceDeleteRequested(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class DeviceRenameRequested extends BluetoothEvent {
  final String deviceId;
  final String newName;

  const DeviceRenameRequested(this.deviceId, this.newName);

  @override
  List<Object> get props => [deviceId, newName];
}
