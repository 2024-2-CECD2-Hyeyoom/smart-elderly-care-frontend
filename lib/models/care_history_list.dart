// lib/models/care_history_list.dart

import 'package:frontend/models/care_history.dart';

class CareHistoryList {
  final bool isSuccess;
  final String code;
  final String message;
  final List<CareHistory> careHistories;

  CareHistoryList({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.careHistories,
  });

  factory CareHistoryList.fromJson(Map<String, dynamic> json) {
    return CareHistoryList(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      careHistories: (json['result'] as List<dynamic>)
          .map((e) => CareHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
