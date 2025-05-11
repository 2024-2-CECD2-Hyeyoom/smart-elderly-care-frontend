import 'package:flutter/material.dart';

class CareStatus extends StatelessWidget {
  // UserSummaryCard 위젯 내에서 사용됨. 돌봄 상태 표시 위젯
  final bool isDanger;
  const CareStatus({super.key, required this.isDanger});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          const Text('돌봄상태: ', style: TextStyle(fontSize: 16)),
          Icon(
            Icons.warning,
            color: isDanger ? Colors.red : Colors.grey.shade400,
            size: 28,
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.check_circle,
            color: !isDanger ? Colors.green : Colors.grey.shade400,
            size: 28,
          ),
          const SizedBox(width: 16),
          Text(
            isDanger ? '위험' : '정상',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDanger ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
