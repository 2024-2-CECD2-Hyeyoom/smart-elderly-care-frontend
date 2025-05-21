// lib/widgets/care_history_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/care_history.dart';

/// 방문 기록 카드 위젯
class CareHistoryCard extends StatelessWidget {
  final CareHistory history;

  const CareHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // 방문일자를 'yyyy년 MM월 dd일' 형식으로 포맷
    final formattedDate = DateFormat('yyyy년 MM월 dd일').format(history.visitDate);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 인터폴레이션을 사용해 변수 값을 삽입
            Text(
              '방문일자: $formattedDate',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '목적: ${history.purpose}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '내용: ${history.content}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '상담자명: ${history.counselorName}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
