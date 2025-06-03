class LoginResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final _Result? result;

  LoginResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    this.result,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      result: json['result'] != null ? _Result.fromJson(json['result']) : null,
    );
  }
}

class _Result {
  final int memberId;
  final String role;
  final String token;
  final String name;

  _Result({
    required this.memberId,
    required this.role,
    required this.token,
    required this.name,
  });

  factory _Result.fromJson(Map<String, dynamic> json) {
    return _Result(
      memberId: json['memberId'] as int,
      role: json['role'] as String,
      token: json['token'] as String,
      name: json['name'] as String,
    );
  }
}
