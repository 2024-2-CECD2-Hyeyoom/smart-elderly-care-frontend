// lib/models/weekly_analysis.dart

import 'package:frontend/models/period.dart';

class WeeklyAnalysis {
  final Period period;
  final List<String> labels;
  final List<double> dataCurrent;
  final List<double> dataPrevious;

  WeeklyAnalysis({
    required this.period,
    required this.labels,
    required this.dataCurrent,
    required this.dataPrevious,
  });

  factory WeeklyAnalysis.fromJson(Map<String, dynamic> json) {
    return WeeklyAnalysis(
      period: Period.fromJson(json['period'] as Map<String, dynamic>),
      labels: List<String>.from(json['labels'] as List<dynamic>),
      dataCurrent: (json['data']['currentWeek'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      dataPrevious: (json['data']['previousWeek'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}
