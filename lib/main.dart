import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pages/home_page.dart';
import 'package:bloc/bloc.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_bloc.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_bloc_observer.dart';

void main() {
  Bloc.observer = BluetoothBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final BluetoothBloc bluetoothBloc = BluetoothBloc();

    return MaterialApp(
      title: 'Scanner Bluetooth BLE',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: BlocProvider(create: (_) => bluetoothBloc, child: MyHomePage()),
    );
  }
}
