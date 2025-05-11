import 'package:flutter/material.dart';

class TargetCard extends StatelessWidget {
  // 관리자용 홈 화면에서 돌봄 대상자 카드들을 표시하는 위젯
  final String name, address, center, contact;
  final bool isDanger, isAbsent;

  const TargetCard({
    super.key,
    required this.name,
    required this.address,
    required this.center,
    required this.contact,
    required this.isDanger,
    required this.isAbsent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Icon(
                  isDanger ? Icons.warning : Icons.check_circle,
                  color: isDanger ? Colors.red : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('주소: $address', style: const TextStyle(fontSize: 12)),
            Text('복지센터: $center', style: const TextStyle(fontSize: 12)),
            Text('연락처: $contact', style: const TextStyle(fontSize: 12)),
            if (isAbsent) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('장기부재',
                    style: TextStyle(fontSize: 10, color: Colors.black)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
