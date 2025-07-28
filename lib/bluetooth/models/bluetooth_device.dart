import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDevice extends Equatable {
  const BluetoothDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.scanResult,
  });

  final String id;
  final String name;
  final String rssi;
  final ScanResult? scanResult;

  @override
  List<Object> get props => [
    id,
    name,
    rssi,
    [scanResult],
  ];
}
