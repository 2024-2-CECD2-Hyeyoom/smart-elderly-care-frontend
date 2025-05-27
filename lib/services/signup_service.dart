// lib/services/signup_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user_signup_request.dart';
import 'package:frontend/models/user_signup_response.dart';

class SignupService {
  static const _baseUrl = 'http://localhost:8080';

  Future<UserSignupResponse> signupUser(UserSignupRequest req) async {
    final uri = Uri.parse('$_baseUrl/member/signup/user');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(req.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Network error: ${response.statusCode}');
    }

    return UserSignupResponse.fromJson(jsonDecode(response.body));
  }
}
