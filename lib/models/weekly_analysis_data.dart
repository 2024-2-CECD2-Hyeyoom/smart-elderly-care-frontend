// 주간 분석 레포트 모델
class WeeklyAnalysisData {
  final String label; //
  final String displayLastWeekValue; // 문자 출력용 지난주 평균 값
  final String displayThisWeekValue; // 문자 출력용 이번주 평균 값
  final double lastWeekValue; // 그래프 출력용 지난주 평균 값
  final double thisWeekValue; // 그래프 출력용 이번주 평균값

  WeeklyAnalysisData({
    required this.label,
    required this.displayLastWeekValue,
    required this.displayThisWeekValue,
    required this.lastWeekValue,
    required this.thisWeekValue,
  });
}
