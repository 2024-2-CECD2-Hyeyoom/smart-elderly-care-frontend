// lib/models/staff_profile.dart

class StaffProfile {
  final int staffId;
  final String name;
  final String phone;
  final String welfareCenterName;

  StaffProfile({
    required this.staffId,
    required this.name,
    required this.phone,
    required this.welfareCenterName,
  });

  factory StaffProfile.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>;
    return StaffProfile(
      staffId: result['staffId'] as int,
      name: result['name'] as String,
      phone: result['phone'] as String,
      welfareCenterName: result['welfareCenterName'] as String,
    );
  }
}
