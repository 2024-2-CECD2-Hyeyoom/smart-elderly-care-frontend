// lib/services/caregiver_service.dart

import 'dart:convert';
import 'package:frontend/models/caregiver_profile.dart';
import 'package:frontend/services/api_client.dart';

class CaregiverService {
  CaregiverService._();
  static final CaregiverService instance = CaregiverService._();

  /// GET /member/mypage/caregiver/{caregiverId}
  Future<CaregiverProfile> fetchMyPage(int caregiverId) async {
    final resp = await ApiClient.instance.get(
      '/member/mypage/caregiver/$caregiverId',
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw Exception('보호자 프로필 조회 실패 (${resp.statusCode})');
    }
    final Map<String, dynamic> jsonBody = jsonDecode(resp.body);
    if (jsonBody['isSuccess'] != true) {
      throw Exception('API 오류: ${jsonBody['message']}');
    }
    return CaregiverProfile.fromJson(jsonBody);
  }
}
