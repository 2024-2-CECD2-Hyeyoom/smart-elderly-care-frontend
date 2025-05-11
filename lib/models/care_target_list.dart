import 'care_target.dart';

class CareTargetList {
  // 돌봄 대상자 리스트 모델 정의
  final List<CareTarget> careTargets;

  CareTargetList({required this.careTargets});

  factory CareTargetList.fromJson(Map<String, dynamic> json) {
    return CareTargetList(
      careTargets: (json['careTargets'] as List)
          .map((e) => CareTarget.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
