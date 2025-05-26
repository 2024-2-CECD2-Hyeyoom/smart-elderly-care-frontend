import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/find_password_screen.dart';
import 'package:frontend/screens/login_screens/login_screen.dart';
import 'package:frontend/screens/login_screens/sign_up_screen.dart';
import 'package:frontend/screens/start_screen.dart';
import 'package:frontend/screens/service_for_me/my_page.dart';
import 'package:frontend/screens/service_for_carer/my_page.dart';
import 'package:frontend/screens/service_for_center/my_page.dart';
import 'package:frontend/screens/service_for_center/home_screen.dart';
import 'package:frontend/screens/service_for_center/analysis_screen.dart';
import 'package:frontend/screens/service_for_carer/home_screen.dart';
import 'package:frontend/screens/service_for_me/home_screen.dart';
import 'package:frontend/screens/service_for_me/care_history_screen.dart';
import 'package:frontend/screens/service_for_me/analysis_screen.dart';
import 'package:frontend/screens/service_for_carer/analysis_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const HyApp());
}

class HyApp extends StatelessWidget {
  const HyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CenterWeeklyReportScreen(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ko'), // 한국어만 지원
      ],
    );
  }
}
