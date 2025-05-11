import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  // UserSummaryCard 위젯 내에서 사용됨. (프로필 카드정보 중)한 행을 읽는 위젯
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }
}
