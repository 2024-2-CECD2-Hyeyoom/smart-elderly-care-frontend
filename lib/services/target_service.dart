// lib/services/target_service.dart

import 'dart:convert';
import 'package:frontend/models/care_target_name.dart';
import 'package:frontend/services/api_client.dart';

class TargetService {
  TargetService._();
  static final TargetService instance = TargetService._();

  /// GET /care/{memberId}/targets/names
  /// 돌봄 담당자가 관리하는 대상자들의 이름 + userId 목록을 가져옵니다.
  Future<List<CareTargetName>> fetchTargetNames(int memberId) async {
    final resp = await ApiClient.instance.get(
      '/care/$memberId/targets/names',
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw Exception('대상자 이름 목록 조회 실패 (${resp.statusCode})');
    }
    final Map<String, dynamic> jsonBody = jsonDecode(resp.body);
    if (jsonBody['isSuccess'] != true) {
      throw Exception('API 오류(message): ${jsonBody['message']}');
    }
    final List<dynamic> rawList = jsonBody['result'] as List<dynamic>;
    return rawList
        .map((e) => CareTargetName.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
