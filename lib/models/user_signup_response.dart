// lib/models/user_signup_response.dart

class UserSignupResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final String result;

  UserSignupResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.result,
  });

  factory UserSignupResponse.fromJson(Map<String, dynamic> json) {
    return UserSignupResponse(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      result: json['result'] as String,
    );
  }
}
