import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const GreenhouseApp());

class GreenhouseApp extends StatelessWidget {
  const GreenhouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Моніторинг теплиці',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
