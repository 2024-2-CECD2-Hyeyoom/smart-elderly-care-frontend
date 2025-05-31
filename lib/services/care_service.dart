// lib/services/care_service.dart

import 'dart:convert';
import 'package:frontend/models/care_target.dart';
import 'package:frontend/models/care_target_list.dart';
import 'package:frontend/services/api_client.dart';

class CareService {
  CareService._();
  static final CareService instance = CareService._();

  /// /care/{memberId}/targets 호출
  Future<List<CareTarget>> fetchTargets(int memberId) async {
    final resp = await ApiClient.instance.get(
      '/care/$memberId/targets',
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw Exception('대상자 목록 조회 실패 (${resp.statusCode})');
    }

    final Map<String, dynamic> jsonBody = jsonDecode(resp.body);
    if (jsonBody['isSuccess'] != true) {
      throw Exception('API 오류: ${jsonBody['message']}');
    }

    // CareTargetList.fromJson 은 result 배열을 파싱해서 List<CareTarget>을 반환합니다.
    final dto = CareTargetList.fromJson(jsonBody);
    return dto.careTargets;
  }
}
