// lib/models/period.dart

/// 한 주의 시작(from) ~ 끝(to) 범위
class WeekRange {
  final String from; // "yyyy-MM-dd"
  final String to; // "yyyy-MM-dd"

  WeekRange({
    required this.from,
    required this.to,
  });

  factory WeekRange.fromJson(Map<String, dynamic> json) {
    return WeekRange(
      from: json['from'] as String,
      to: json['to'] as String,
    );
  }

  /// 필요하다면 DateTime 으로 변환 할 수 있음
  DateTime fromDate() => DateTime.parse(from);
  DateTime toDate() => DateTime.parse(to);
}

/// 주간 분석 시에 “이번 주”, “지난주” 기간을 감싸고 있는 객체
class Period {
  final WeekRange currentWeek;
  final WeekRange previousWeek;

  Period({
    required this.currentWeek,
    required this.previousWeek,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      currentWeek:
          WeekRange.fromJson(json['currentWeek'] as Map<String, dynamic>),
      previousWeek:
          WeekRange.fromJson(json['previousWeek'] as Map<String, dynamic>),
    );
  }
}
