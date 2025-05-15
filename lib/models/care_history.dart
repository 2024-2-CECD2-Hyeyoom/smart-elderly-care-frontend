/// 단일 돌봄 이력 모델
class CareHistory {
  final int careHistoryId;
  final DateTime visitDate;
  final String purpose;
  final String content;
  final String counselorName;

  CareHistory({
    required this.careHistoryId,
    required this.visitDate,
    required this.purpose,
    required this.content,
    required this.counselorName,
  });

  factory CareHistory.fromJson(Map<String, dynamic> json) {
    return CareHistory(
      careHistoryId: json['CareHistoryId'] as int,
      visitDate: DateTime.parse(json['visitDate'] as String),
      purpose: json['purpose'] as String,
      content: json['content'] as String,
      counselorName: json['counselorName'] as String,
    );
  }
}
