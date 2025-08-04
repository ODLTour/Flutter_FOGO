import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pages/home_page.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_bloc.dart';
import 'package:bluetooth_detect_01/bluetooth/bluetooth_bloc_observer.dart';
import 'package:bluetooth_detect_01/bluetooth/mock_bluetooth_bloc.dart';

const bool useMockBloc = true;
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 54, 51, 50),
        ),
      ),
      home: BlocProvider(
        /*create: (_) => bluetoothBloc*/ create: (context) =>
            useMockBloc ? MockBluetoothBloc() : bluetoothBloc,
        child: MyHomePage(),
      ),
    );
  }
}
