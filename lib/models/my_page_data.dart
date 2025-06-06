// lib/models/my_page_data.dart

class MyPageData {
  final int userId;
  final String name;
  final int gender;
  final DateTime birthDate;
  final String address;
  final String elderlyId;
  final String welfareCenterName;
  final String phone;
  final List<String> underlyingDiseases;

  MyPageData({
    required this.userId,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.address,
    required this.elderlyId,
    required this.welfareCenterName,
    required this.phone,
    required this.underlyingDiseases,
  });

  factory MyPageData.fromJson(Map<String, dynamic> json) {
    return MyPageData(
      userId: json['userId'] as int,
      name: json['name'] as String,
      gender: json['gender'] as int,
      // "birthDate"는 ISO8601 형식 문자열로 넘어온다고 가정
      birthDate: DateTime.parse(json['birthDate'] as String),
      address: json['address'] as String,
      elderlyId: json['elderlyId'] as String,
      welfareCenterName: json['welfareCenterName'] as String,
      phone: json['phone'] as String,
      underlyingDiseases:
      List<String>.from(json['underlyingDiseases'] as List<dynamic>),
    );
  }
}