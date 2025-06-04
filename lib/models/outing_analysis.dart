// lib/models/outing_analysis.dart

import 'package:frontend/models/period.dart';

class OutingAnalysis {
  final Period period;
  final List<String> labels;
  final List<int> dataCurrent;
  final List<int> dataPrevious;
  final double averageCurrent;
  final double averagePrevious;
  final int? outingDurationMinutes;

  OutingAnalysis({
    required this.period,
    required this.labels,
    required this.dataCurrent,
    required this.dataPrevious,
    required this.averageCurrent,
    required this.averagePrevious,
    this.outingDurationMinutes,
  });

  factory OutingAnalysis.fromJson(Map<String, dynamic> json) {
    return OutingAnalysis(
      period: Period.fromJson(json['period'] as Map<String, dynamic>),
      labels: List<String>.from(json['labels'] as List<dynamic>),
      dataCurrent: (json['data']['currentWeek'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      dataPrevious: (json['data']['previousWeek'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      averageCurrent: (json['averageCurrentWeek'] as num).toDouble(),
      averagePrevious: (json['averagePreviousWeek'] as num).toDouble(),
      outingDurationMinutes: json['outingDurationMinutes'] as int?,
    );
  }
}
