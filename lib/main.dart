import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/find_password_screen.dart';
import 'package:frontend/screens/login_screens/login_screen.dart';
import 'package:frontend/screens/login_screens/sign_up_screen.dart';
import 'package:frontend/screens/start_screen.dart';
import 'package:frontend/screens/service_for_me/my_page.dart';

void main() {
  runApp(const HyApp());
}

class HyApp extends StatelessWidget {
  const HyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyPageScreen(),
    );
  }
}
