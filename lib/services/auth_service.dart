// lib/services/auth_service.dart

import 'dart:convert';
import 'package:frontend/models/login_request.dart';
import 'package:frontend/models/login_response.dart';
import 'package:frontend/services/secure_storage_service.dart';
import 'package:frontend/services/api_client.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Future<LoginResponse> login(LoginRequest req) async {
    final resp = await ApiClient.instance.post(
      '/member/login',
      body: jsonEncode(req.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception('로그인 실패: ${resp.statusCode}');
    }

    final loginResp = LoginResponse.fromJson(jsonDecode(resp.body));

    // result 가 null 이 아닌 경우에만 저장
    if (loginResp.isSuccess && loginResp.result != null) {
      await SecureStorageService.writeToken(loginResp.result!.token);
    }

    return loginResp;
  }
}
