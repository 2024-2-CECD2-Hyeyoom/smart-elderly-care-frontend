// lib/services/care_history_service.dart

import 'dart:convert';
import 'package:frontend/models/care_history_list.dart';
import 'package:frontend/models/care_history.dart';
import 'package:frontend/services/api_client.dart';

class CareHistoryService {
  CareHistoryService._();
  static final CareHistoryService instance = CareHistoryService._();

  /// /care/{userId}/history 호출
  Future<List<CareHistory>> fetchHistory(int userId) async {
    // GET 메소드로 프로필 조회
    final resp = await ApiClient.instance.get(
      '/care/$userId/history',
      headers: {'Content-Type': 'application/json'},
    );

    if (resp.statusCode != 200) {
      throw Exception('돌봄 이력 조회 실패 (${resp.statusCode})');
    }

    // 응답 JSON 파싱
    final Map<String, dynamic> jsonBody = jsonDecode(resp.body);
    if (jsonBody['isSuccess'] != true) {
      throw Exception('API 오류: ${jsonBody['message']}');
    }

    // result는 배열 형태이므로, CareHistoryList.fromJson 이용
    final dto = CareHistoryList.fromJson(jsonBody);
    return dto.careHistories;
  }
}
