// lib/models/care_target_list.dart
import 'package:frontend/models/care_target.dart';

class CareTargetList {
  final bool isSuccess;
  final String code;
  final String message;
  final List<CareTarget> careTargets;

  CareTargetList({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.careTargets,
  });

  factory CareTargetList.fromJson(Map<String, dynamic> json) {
    final rawList = json['result'] as List<dynamic>;
    final targets = rawList
        .map((e) => CareTarget.fromJson(e as Map<String, dynamic>))
        .toList();

    return CareTargetList(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      careTargets: targets,
    );
  }
}
