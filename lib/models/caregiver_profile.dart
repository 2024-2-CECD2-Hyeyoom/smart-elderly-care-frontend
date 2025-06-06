// lib/models/caregiver_profile.dart

class CaregiverProfile {
  final int caregiverId;
  final String name;
  final String phone;
  final List<String> elderlyIds;
  final List<String> elderlyNames;
  final List<String> elderlyPhones;

  CaregiverProfile({
    required this.caregiverId,
    required this.name,
    required this.phone,
    required this.elderlyIds,
    required this.elderlyNames,
    required this.elderlyPhones,
  });

  factory CaregiverProfile.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>;
    return CaregiverProfile(
      caregiverId: result['caregiverId'] as int,
      name: result['name'] as String,
      phone: result['phone'] as String,
      elderlyIds: (result['elderlyIds'] as List<dynamic>).cast<String>(),
      elderlyNames: (result['elderlyNames'] as List<dynamic>).cast<String>(),
      elderlyPhones: (result['elderlyPhones'] as List<dynamic>).cast<String>(),
    );
  }
}
