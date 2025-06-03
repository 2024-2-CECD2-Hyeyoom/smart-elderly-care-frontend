// lib/widgets/target_history_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/target_history.dart';
import 'package:frontend/services/target_history_service.dart';
import 'package:frontend/screens/service_for_carer/edit_care_history_screen.dart';
import 'package:frontend/screens/service_for_carer/care_manage_screen.dart';

/// 한 개의 돌봄 대상자 이력을 카드 형태로 보여주는 위젯
class TargetHistoryCard extends StatelessWidget {
  final TargetHistory history;
  final int memberId; // “상담자(돌봄 담당자)”의 ID
  final String counselorName; // 로그인된 상담자 이름

  const TargetHistoryCard({
    super.key,
    required this.history,
    required this.memberId,
    required this.counselorName,
  });

  @override
  Widget build(BuildContext context) {
    // API로 받은 visitDate(DateTime)를 한국어 “yyyy년 MM월 dd일” 형식으로 포맷
    final formattedDate = DateFormat('yyyy년 MM월 dd일').format(history.visitDate);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 돌봄 대상자 이름
            Text(
              '돌봄 대상자: ${history.userName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            // 방문일자
            Text(
              '방문일자: $formattedDate',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            // 목적
            Text(
              '목적: ${history.purpose}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            // 내용
            Text(
              '내용: ${history.content}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            // 삭제·수정 버튼 + 상담자
            Row(
              children: [
                /// ───────────────────────── 삭제 버튼 ─────────────────────────
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    // 1) 사용자에게 “진짜 삭제할지” 확인 다이얼로그
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('이력 삭제'),
                        content: const Text('정말 이력을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text(
                              '삭제',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    // 2) “삭제” 선택 시 실제 삭제 API 호출
                    if (shouldDelete == true) {
                      try {
                        await TargetHistoryService.instance
                            .deleteHistory(history.careHistoryId);

                        // 삭제 성공 시, 스낵바 알림 후 목록 갱신
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('이력이 삭제되었습니다.')),
                          );
                          // CareManageScreen 으로 돌아가면서 전체 목록 재조회
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => CareManageScreen(
                                memberId: memberId,
                                counselorName: counselorName,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('삭제 실패: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  },
                ),

                const SizedBox(width: 8),

                /// ───────────────────────── 수정 버튼 ─────────────────────────
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () {
                    // EditCareHistoryScreen으로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditCareHistoryScreen(
                          memberId: memberId,
                          counselorName: counselorName,
                          history: history,
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // 우측 끝에 상담자명
                Text(
                  '상담자명: ${history.counselorName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
