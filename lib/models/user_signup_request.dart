// lib/models/user_signup_request.dart

class UserSignupRequest {
  final String name;
  final String phone;
  final int gender;
  final String birthDate;
  final String address;
  final String welfareCenterName;
  final List<String> underlyingDiseases;
  final String password;

  UserSignupRequest({
    required this.name,
    required this.phone,
    required this.gender,
    required this.birthDate,
    required this.address,
    required this.welfareCenterName,
    required this.underlyingDiseases,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'gender': gender,
        'birthDate': birthDate,
        'address': address,
        'welfareCenterName': welfareCenterName,
        'underlyingDiseases': underlyingDiseases,
        'password': password,
      };
}
