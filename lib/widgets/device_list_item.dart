import 'package:bluetooth_detect_01/bluetooth/models/bluetooth_device.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeviceListItem extends StatelessWidget {
  final BluetoothDevice bluetoothDevice;
  const DeviceListItem({super.key, required this.bluetoothDevice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5.0, 6.0, 5.0, 6.0),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(15),
        ),
        shadowColor: const Color(0xffE6D799),
        elevation: 3,
        child: ListTile(
          leading: Icon(Icons.bluetooth, color: const Color(0xff565659)),
          title: Text(
            bluetoothDevice.name.isEmpty
                ? '(Appareil inconnu)'
                : bluetoothDevice.name,
            style: GoogleFonts.koHo(
              textStyle: TextStyle(
                color: const Color(0xff565659),
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          subtitle: Text(
            bluetoothDevice.id.isEmpty ? '' : bluetoothDevice.id,
            style: GoogleFonts.koHo(
              textStyle: TextStyle(
                color: const Color(0xff565659),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // trailing: IconButton(
          //   icon: const Icon(Icons.keyboard_control_rounded),
          //   onPressed: "",
          // ),
          //tileColor: const Color(0xffE6D799),
        ),
      ),
    );
  }
}
