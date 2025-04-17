import 'package:flutter/material.dart';
import 'package:frontend/screens/start_screen.dart';

void main() {
  runApp(const HyApp());
}

class HyApp extends StatelessWidget {
  const HyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StartScreen(),
    );
  }
}
