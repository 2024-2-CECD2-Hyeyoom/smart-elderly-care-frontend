// lib/models/target_history.dart

class TargetHistory {
  final int careHistoryId;
  final int userId;
  final String userName;
  final DateTime visitDate;
  final String purpose;
  final String content;
  final String counselorName;

  TargetHistory({
    required this.careHistoryId,
    required this.userId,
    required this.userName,
    required this.visitDate,
    required this.purpose,
    required this.content,
    required this.counselorName,
  });

  factory TargetHistory.fromJson(Map<String, dynamic> json) {
    return TargetHistory(
      careHistoryId: json['careHistoryId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      visitDate: DateTime.parse(json['visitDate'] as String),
      purpose: json['purpose'] as String,
      content: json['content'] as String,
      counselorName: json['counselorName'] as String,
    );
  }
}

/// 최종 API 전체 응답을 파싱하기 위한 DTO (isSuccess, message, result(List) 포함)
class TargetHistoryListResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final List<TargetHistory> result;

  TargetHistoryListResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.result,
  });

  factory TargetHistoryListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawList = json['result'] as List<dynamic>;
    final parsedList = rawList
        .map((e) => TargetHistory.fromJson(e as Map<String, dynamic>))
        .toList();
    return TargetHistoryListResponse(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      result: parsedList,
    );
  }
}