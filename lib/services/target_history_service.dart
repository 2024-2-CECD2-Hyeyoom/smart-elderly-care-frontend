// lib/services/target_history_service.dart

import 'dart:convert';
import 'package:frontend/models/target_history.dart';
import 'package:frontend/services/api_client.dart';

class TargetHistoryService {
  TargetHistoryService._();
  static final TargetHistoryService instance = TargetHistoryService._();

  /// GET /care/{memberId}/targets/history
  Future<List<TargetHistory>> fetchTargetHistories(int memberId) async {
    final resp = await ApiClient.instance.get(
      '/care/$memberId/targets/history',
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw Exception('돌봄 이력 조회 실패 (${resp.statusCode})');
    }
    final Map<String, dynamic> jsonBody = jsonDecode(resp.body);
    if (jsonBody['isSuccess'] != true) {
      throw Exception('API 오류: ${jsonBody['message']}');
    }
    final List<dynamic> rawList = jsonBody['result'] as List<dynamic>;
    return rawList
        .map((e) => TargetHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /care/history
  /// 새로운 돌봄 이력을 저장합니다.
  Future<void> addHistory({
    required int userId,
    required DateTime visitDate,
    required String purpose,
    required String content,
    required int counselorId,
  }) async {
    final bodyJson = {
      "userId": userId,
      // 서버가 ISO8601 형식을 받는다고 가정
      "visitDate": visitDate.toIso8601String().split('T')[0], // "yyyy-MM-dd"
      "purpose": purpose,
      "content": content,
      "counselorId": counselorId,
    };

    final resp = await ApiClient.instance.post(
      '/care/history',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyJson),
    );
    if (resp.statusCode != 200) {
      throw Exception('돌봄 이력 저장 실패 (${resp.statusCode})');
    }
    final Map<String, dynamic> jsonBody = jsonDecode(resp.body);
    if (jsonBody['isSuccess'] != true) {
      throw Exception('API 오류: ${jsonBody['message']}');
    }
    // 성공 시 리턴 값(result)은 별도로 사용하지 않으므로 void 처리
  }

  /// PUT /care/history/{careHistoryId}
  /// 기존 돌봄 이력을 수정합니다.
  Future<void> updateHistory({
    required int careHistoryId,
    required int userId,
    required DateTime visitDate,
    required String purpose,
    required String content,
    required int counselorId,
  }) async {
    final bodyJson = {
      "userId": userId,
      "visitDate": visitDate.toIso8601String().split('T')[0],
      "purpose": purpose,
      "content": content,
      "counselorId": counselorId,
    };

    final resp = await ApiClient.instance.put(
      '/care/history/$careHistoryId',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyJson),
    );
    if (resp.statusCode != 200) {
      throw Exception('돌봄 이력 수정 실패 (${resp.statusCode})');
    }
    final Map<String, dynamic> jsonBody = jsonDecode(resp.body);
    if (jsonBody['isSuccess'] != true) {
      throw Exception('API 오류: ${jsonBody['message']}');
    }
    // 수정 결과는 별도 리턴값 없으므로 void
  }

  /// DELETE /care/history/{careHistoryId}
  /// 지정된 careHistoryId의 이력을 삭제합니다.
  Future<void> deleteHistory(int careHistoryId) async {
    final resp = await ApiClient.instance.delete(
      '/care/history/$careHistoryId',
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw Exception('돌봄 이력 삭제 실패 (${resp.statusCode})');
    }
    final Map<String, dynamic> jsonBody = jsonDecode(resp.body);
    if (jsonBody['isSuccess'] != true) {
      throw Exception('API 오류: ${jsonBody['message']}');
    }
    // 삭제 성공 시 특별히 반환값을 사용하지 않으므로 void
  }
}
