class WelfareCenter {
  final String sido;
  final String sigungu;
  final String organName;
  final String address;
  final String phone;
  final String bizType;
  final String organType;

  WelfareCenter({
    required this.sido,
    required this.sigungu,
    required this.organName,
    required this.address,
    required this.phone,
    required this.bizType,
    required this.organType,
  });

  factory WelfareCenter.fromJson(Map<String, dynamic> json) {
    return WelfareCenter(
      sido: json['sido'] as String,
      sigungu: json['sigungu'] as String,
      organName: json['organName'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      bizType: json['bizType'] as String,
      organType: json['organType'] as String,
    );
  }
}
