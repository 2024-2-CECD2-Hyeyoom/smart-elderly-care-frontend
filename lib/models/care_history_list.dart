import 'care_history.dart';

/// 돌봄 이력 목록 모델
class CareHistoryList {
  final List<CareHistory> careHistories;

  CareHistoryList({required this.careHistories});

  factory CareHistoryList.fromJson(Map<String, dynamic> json) {
    return CareHistoryList(
      careHistories: (json['careHistories'] as List)
          .map((e) => CareHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
