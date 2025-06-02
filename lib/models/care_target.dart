class CareTarget {
  // 돌봄 대상자 모델 정의
  final int userId;
  final String name;
  final int gender;
  final String address;
  final String welfareCenterName;
  final String phoneNumber;
  final int careStatus;

  CareTarget({
    required this.userId,
    required this.name,
    required this.gender,
    required this.address,
    required this.welfareCenterName,
    required this.phoneNumber,
    required this.careStatus,
  });

  factory CareTarget.fromJson(Map<String, dynamic> json) {
    return CareTarget(
      userId: json['userId'] as int,
      name: json['name'] as String,
      gender: json['gender'] as int,
      address: json['address'] as String,
      welfareCenterName: json['welfareCenterName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      careStatus: json['careStatus'] as int,
    );
  }

  /// 위험 상태 여부
  bool get isDanger => careStatus != 0;
}
