import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Scanner Bluetooth')),
        body: Center(
          child: Text(
            'Bienvenue dans le scanner bluetooth !',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
