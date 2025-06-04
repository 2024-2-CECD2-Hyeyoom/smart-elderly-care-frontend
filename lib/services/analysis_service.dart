// lib/services/analysis_service.dart

import 'dart:convert';
import 'package:frontend/models/weekly_analysis.dart';
import 'package:frontend/models/sleep_analysis.dart';
import 'package:frontend/models/outing_analysis.dart';
import 'package:frontend/services/api_client.dart';

class AnalysisService {
  AnalysisService._();
  static final AnalysisService instance = AnalysisService._();

  /// GET /analysis/{userId}/weekly?to=yyyy-MM-dd[&from=yyyy-MM-dd]
  Future<WeeklyAnalysis> fetchWeeklyAnalysis({
    required int userId,
    required String to, // yyyy-MM-dd
    String? from, // yyyy-MM-dd, optional
  }) async {
    final query = <String, String>{'to': to};
    if (from != null) query['from'] = from;

    final resp = await ApiClient.instance.get(
      '/analysis/$userId/weekly',
      queryParameters: query,
    );
    if (resp.statusCode != 200) {
      throw Exception('주간 분석 조회 실패: ${resp.statusCode}');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (body['isSuccess'] != true) {
      throw Exception('API 오류(주간): ${body['message']}');
    }
    final result = body['result'] as Map<String, dynamic>;
    return WeeklyAnalysis.fromJson(result);
  }

  /// GET /analysis/{userId}/sleep?to=yyyy-MM-dd[&from=yyyy-MM-dd]
  Future<SleepAnalysis> fetchSleepAnalysis({
    required int userId,
    required String to,
    String? from,
  }) async {
    final query = <String, String>{'to': to};
    if (from != null) query['from'] = from;

    final resp = await ApiClient.instance.get(
      '/analysis/$userId/sleep',
      queryParameters: query,
    );
    if (resp.statusCode != 200) {
      throw Exception('수면 분석 조회 실패: ${resp.statusCode}');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (body['isSuccess'] != true) {
      throw Exception('API 오류(수면): ${body['message']}');
    }
    final result = body['result'] as Map<String, dynamic>;
    return SleepAnalysis.fromJson(result);
  }

  /// GET /analysis/{userId}/outing?to=yyyy-MM-dd[&from=yyyy-MM-dd]
  Future<OutingAnalysis> fetchOutingAnalysis({
    required int userId,
    required String to,
    String? from,
  }) async {
    final query = <String, String>{'to': to};
    if (from != null) query['from'] = from;

    final resp = await ApiClient.instance.get(
      '/analysis/$userId/outing',
      queryParameters: query,
    );
    if (resp.statusCode != 200) {
      throw Exception('외출 분석 조회 실패: ${resp.statusCode}');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (body['isSuccess'] != true) {
      throw Exception('API 오류(외출): ${body['message']}');
    }
    final result = body['result'] as Map<String, dynamic>;
    return OutingAnalysis.fromJson(result);
  }
}
