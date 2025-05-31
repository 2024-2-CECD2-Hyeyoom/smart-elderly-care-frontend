// lib/services/profile_service.dart

import 'dart:convert';
import 'package:frontend/models/dashboard_data.dart';
import 'package:frontend/services/api_client.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  /// /care/{userId}/profile 호출
  Future<DashboardData> fetchProfile(int userId) async {
    final resp = await ApiClient.instance.get(
      '/care/$userId/profile',
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw Exception('프로필 조회 실패 (${resp.statusCode})');
    }

    final Map<String, dynamic> jsonBody = jsonDecode(resp.body);
    if (jsonBody['isSuccess'] != true) {
      throw Exception('API 오류: ${jsonBody['message']}');
    }

    final result = jsonBody['result'] as Map<String, dynamic>;
    return DashboardData.fromJson(result);
  }
}
