// lib/models/sleep_analysis.dart

import 'package:frontend/models/period.dart';

class SleepAnalysis {
  final Period period;
  final List<String> labels;
  final List<double> dataCurrent;
  final List<double> dataPrevious;
  final double averageCurrent;
  final double averagePrevious;
  final String? sleepStartTime;
  final String? sleepEndTime;

  SleepAnalysis({
    required this.period,
    required this.labels,
    required this.dataCurrent,
    required this.dataPrevious,
    required this.averageCurrent,
    required this.averagePrevious,
    this.sleepStartTime,
    this.sleepEndTime,
  });

  factory SleepAnalysis.fromJson(Map<String, dynamic> json) {
    return SleepAnalysis(
      period: Period.fromJson(json['period'] as Map<String, dynamic>),
      labels: List<String>.from(json['labels'] as List<dynamic>),
      dataCurrent: (json['data']['currentWeek'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      dataPrevious: (json['data']['previousWeek'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      averageCurrent: (json['averageCurrentWeek'] as num).toDouble(),
      averagePrevious: (json['averagePreviousWeek'] as num).toDouble(),
      sleepStartTime: json['sleepStartTime'] as String?,
      sleepEndTime: json['sleepEndTime'] as String?,
    );
  }
}
