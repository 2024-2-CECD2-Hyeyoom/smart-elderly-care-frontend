// lib/models/care_target_name.dart

class CareTargetName {
  final int userId;
  final String name;

  CareTargetName({
    required this.userId,
    required this.name,
  });

  factory CareTargetName.fromJson(Map<String, dynamic> json) {
    return CareTargetName(
      userId: json['userId'] as int,
      name: json['name'] as String,
    );
  }
}
