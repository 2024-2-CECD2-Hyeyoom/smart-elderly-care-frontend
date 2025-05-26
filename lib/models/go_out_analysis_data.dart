class GoOutAnalysisData {
  final DateTime selectedDate; // 선택한 날짜
  final int totalGoOutCount; // 총 외출 횟수
  final String totalGoOutTime; // 총 외출 시간
  final double lastWeekAverageTime; // 지난주의 평균 외출 시간
  final List<double> thisWeekTime; // 이번주 7일 동안 각각 총 외출 시간

  GoOutAnalysisData({
    required this.selectedDate,
    required this.totalGoOutCount,
    required this.totalGoOutTime,
    required this.lastWeekAverageTime,
    required this.thisWeekTime,
  });
}
