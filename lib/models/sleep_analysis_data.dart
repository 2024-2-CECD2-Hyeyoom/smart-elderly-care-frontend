class SleepAnalysisData {
  final DateTime selectedDate; // 선택한 날짜
  final String sleepTime; // 취침 시간
  final String wakeTime; // 기상 시간
  final String totalSleep; // 총 수면 시간
  final double lastWeekAverage; // 지난 주 평균 수면 시간
  final List<double> thisWeekSleep; // 이번주 7일 동안 각각 총 수면 시간

  SleepAnalysisData({
    required this.selectedDate,
    required this.sleepTime,
    required this.wakeTime,
    required this.totalSleep,
    required this.lastWeekAverage,
    required this.thisWeekSleep,
  });
}
