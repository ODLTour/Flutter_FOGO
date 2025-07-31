import 'package:bluetooth_detect_01/bluetooth/models/bluetooth_device.dart';
import 'package:flutter/material.dart';

class DeviceListItem extends StatelessWidget {
  final BluetoothDevice bluetoothDevice;
  const DeviceListItem({super.key, required this.bluetoothDevice});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [Text(bluetoothDevice.name), Text(bluetoothDevice.id)],
      ),
    );
  }
}
