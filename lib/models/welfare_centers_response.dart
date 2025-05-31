import 'welfare_center.dart';

class WelfareCentersResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final List<WelfareCenter> result;

  WelfareCentersResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.result,
  });

  factory WelfareCentersResponse.fromJson(Map<String, dynamic> json) {
    return WelfareCentersResponse(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      result: (json['result'] as List<dynamic>)
          .map((e) => WelfareCenter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
