import 'package:flutter/material.dart';
import 'info_row.dart';
import 'care_status.dart';

/// 사용자 요약 카드: 정보 리스트 + 돌봄 상태를 한 번에 묶은 위젯
class UserSummaryCard extends StatelessWidget {
  /// key: 위젯 키
  /// info: "레이블": "값" 쌍 맵
  /// isDanger: 돌봄 상태 위험 여부
  const UserSummaryCard({
    super.key,
    required this.info,
    required this.isDanger,
  });

  final Map<String, String> info;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // info 맵을 InfoRow로 렌더링
            ...info.entries.map(
              (e) => InfoRow(label: e.key, value: e.value),
            ),
            // 돌봄 상태
            CareStatus(isDanger: isDanger),
          ],
        ),
      ),
    );
  }
}
