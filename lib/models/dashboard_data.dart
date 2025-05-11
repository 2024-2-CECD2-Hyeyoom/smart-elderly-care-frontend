// lib/models/dashboard_data.dart

class DashboardData {
  // 대상자 프로필 카드 모델 정의
  final int userId;
  final String name;
  final int gender;
  final String address;
  final String welfareCenter;
  final String phoneNumber;
  final String guardianPhone;
  final List<String> underlyingConditions;
  final int careStatus;

  DashboardData({
    required this.userId,
    required this.name,
    required this.gender,
    required this.address,
    required this.welfareCenter,
    required this.phoneNumber,
    required this.guardianPhone,
    required this.underlyingConditions,
    required this.careStatus,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      userId: json['userId'] as int,
      name: json['name'] as String,
      gender: json['gender'] as int,
      address: json['address'] as String,
      welfareCenter: json['welfareCenter'] as String,
      phoneNumber: json['phoneNumber'] as String,
      guardianPhone: json['guardianPhone'] as String,
      underlyingConditions:
          List<String>.from(json['underlyingConditions'] as List),
      careStatus: json['careStatus'] as int,
    );
  }
}
