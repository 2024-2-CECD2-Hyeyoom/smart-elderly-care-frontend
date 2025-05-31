// lib/services/signup_service.dart

import 'dart:convert';
import 'package:frontend/models/user_signup_request.dart';
import 'package:frontend/models/user_signup_response.dart';
import 'package:frontend/models/staff_signup_request.dart';
import 'package:frontend/models/caregiver_signup_request.dart';
import 'package:frontend/services/api_client.dart';

class SignupService {
  /// 일반 사용자
  Future<UserSignupResponse> signupUser(UserSignupRequest req) async {
    final resp = await ApiClient.instance.post(
      '/member/signup/user',
      body: jsonEncode(req.toJson()),
    );
    if (resp.statusCode != 200) {
      throw Exception('회원가입 실패(${resp.statusCode})');
    }
    return UserSignupResponse.fromJson(jsonDecode(resp.body));
  }

  /// 복지담당자
  Future<UserSignupResponse> signupStaff(StaffSignupRequest req) async {
    final resp = await ApiClient.instance.post(
      '/member/signup/staff',
      body: jsonEncode(req.toJson()),
    );
    if (resp.statusCode != 200) {
      throw Exception('직원 회원가입 실패(${resp.statusCode})');
    }
    return UserSignupResponse.fromJson(jsonDecode(resp.body));
  }

  /// 보호자
  Future<UserSignupResponse> signupCaregiver(CaregiverSignupRequest req) async {
    final resp = await ApiClient.instance.post(
      '/member/signup/caregiver',
      body: jsonEncode(req.toJson()),
    );
    if (resp.statusCode != 200) {
      throw Exception('보호자 회원가입 실패(${resp.statusCode})');
    }
    return UserSignupResponse.fromJson(jsonDecode(resp.body));
  }
}
