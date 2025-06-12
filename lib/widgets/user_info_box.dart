// lib/widgets/user_info_box.dart

import 'package:flutter/material.dart';

/// 마이페이지 유저 정보 표시용 박스 위젯
class UserInfoBox extends StatelessWidget {
  final String text;

  const UserInfoBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}