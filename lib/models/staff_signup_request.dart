class StaffSignupRequest {
  final String name;
  final String phone;
  final int gender;
  final String address;
  final String welfareCenterName;
  final String password;

  StaffSignupRequest({
    required this.name,
    required this.phone,
    required this.gender,
    required this.address,
    required this.welfareCenterName,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "gender": gender,
        "address": address,
        "welfareCenterName": welfareCenterName,
        "password": password,
      };
}
