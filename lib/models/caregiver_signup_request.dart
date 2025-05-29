class CaregiverSignupRequest {
  final String name;
  final String phone;
  final int gender;
  final String address;
  final List<String> elderlyIds;
  final String password;

  CaregiverSignupRequest({
    required this.name,
    required this.phone,
    required this.gender,
    required this.address,
    required this.elderlyIds,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "gender": gender,
        "address": address,
        "elderlyIds": elderlyIds,
        "password": password,
      };
}
