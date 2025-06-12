// lib/services/staff_service.dart

import 'dart:convert';
import 'package:frontend/models/staff_profile.dart';
import 'package:frontend/services/api_client.dart';

class StaffService {
  StaffService._();
  static final StaffService instance = StaffService._();

  /// GET /member/mypage/staff/{staffId}
  Future<StaffProfile> fetchMyPage(int staffId) async {
    final resp = await ApiClient.instance.get(
      '/member/mypage/staff/$staffId',
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw Exception('마이페이지 조회 실패 (${resp.statusCode})');
    }
    final Map<String, dynamic> jsonBody = jsonDecode(resp.body);
    if (jsonBody['isSuccess'] != true) {
      throw Exception('API 오류: ${jsonBody['message']}');
    }
    return StaffProfile.fromJson(jsonBody);
  }
}
