import 'package:bluetooth_detect_01/bluetooth/bluetooth_bloc.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_event.dart';
import 'package:bluetooth_detect_01/bluetooth/models/bluetooth_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class DeviceListItem extends StatefulWidget {
  final BluetoothDevice bluetoothDevice;
  const DeviceListItem({super.key, required this.bluetoothDevice});

  @override
  State<DeviceListItem> createState() => _DeviceListItemState();
}

class _DeviceListItemState extends State<DeviceListItem> {
  void handleshowRenameDialog(BuildContext context, BluetoothDevice device) {
    final TextEditingController textController = TextEditingController(
      text: device.name,
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Renommer l\'appareil',
            style: GoogleFonts.koHo(
              textStyle: TextStyle(
                color: const Color(0xffB1602E),
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Nouveau nom',
              hintStyle: GoogleFonts.koHo(
                textStyle: TextStyle(
                  color: const Color(0xff565659),
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Annuler',
                style: GoogleFonts.koHo(
                  textStyle: TextStyle(
                    color: const Color(0xffB1602E),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(
                'Renommer',
                style: GoogleFonts.koHo(
                  textStyle: TextStyle(
                    color: const Color(0xffB1602E),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onPressed: () {
                final newName = textController.text;
                if (newName.isNotEmpty) {
                  // Envoie l'événement au BLoC
                  context.read<BluetoothBloc>().add(
                    DeviceRenameRequested(device.id, newName),
                  );
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(5.0, 6.0, 5.0, 6.0),
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
            child: ListTile(
              leading: Icon(Icons.bluetooth, color: const Color(0xff565659)),
              title: Text(
                widget.bluetoothDevice.name.isEmpty
                    ? '(Appareil inconnu)'
                    : widget.bluetoothDevice.name,
                style: GoogleFonts.koHo(
                  textStyle: TextStyle(
                    color: const Color.fromARGB(255, 58, 58, 60),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              subtitle: Text(
                widget.bluetoothDevice.id.isEmpty
                    ? ''
                    : widget.bluetoothDevice.id,
                style: GoogleFonts.koHo(
                  textStyle: TextStyle(
                    color: const Color.fromARGB(255, 58, 58, 60),

                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              trailing: PopupMenuButton<String>(
                // 'onSelected' est appelé quand un item est choisi.
                onSelected: (String value) {
                  if (value == 'rename') {
                    handleshowRenameDialog(context, widget.bluetoothDevice);
                  } else if (value == 'delete') {
                    context.read<BluetoothBloc>().add(
                      DeviceDeleteRequested(widget.bluetoothDevice.id),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'rename',
                    child: Text(
                      'Renommer',
                      style: GoogleFonts.koHo(
                        textStyle: TextStyle(
                          color: const Color.fromARGB(255, 58, 58, 60),

                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(
                      'Supprimer',
                      style: GoogleFonts.koHo(
                        textStyle: TextStyle(
                          color: const Color.fromARGB(255, 58, 58, 60),

                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
