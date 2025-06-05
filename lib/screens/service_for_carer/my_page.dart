// lib/screens/service_for_carer/my_page.dart

import 'package:flutter/material.dart';
import 'package:frontend/models/caregiver_profile.dart';
import 'package:frontend/services/caregiver_service.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/edit_id.dart';
import 'package:frontend/widgets/user_info_box.dart';
import 'package:frontend/screens/service_for_carer/analysis_screen.dart';
import 'package:frontend/screens/service_for_carer/home_screen.dart';
import 'package:frontend/screens/service_for_carer/care_manage_screen.dart';

class CarerMyPageScreen extends StatefulWidget {
  final int memberId; // 로그인 시 전달된 caregiverId
  final String counselorName; // (뒤로 돌아갈 때 필요하면)

  const CarerMyPageScreen({
    super.key,
    required this.memberId,
    required this.counselorName,
  });

  @override
  State<CarerMyPageScreen> createState() => _CarerMyPageScreenState();
}

class _CarerMyPageScreenState extends State<CarerMyPageScreen> {
  late Future<CaregiverProfile> _futureProfile;
  int _selectedIndex = 3; // 마이페이지 탭 인덱스

  @override
  void initState() {
    super.initState();
    // 화면이 열리면 백엔드 호출
    _futureProfile = CaregiverService.instance.fetchMyPage(widget.memberId);
  }

  void _onNavTapped(int idx) {
    // 0: 홈, 1: 분석, 2: 돌봄 관리, 3: 마이페이지(현재)
    if (idx == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CarerHomeScreen(
            memberId: widget.memberId,
            counselorName: widget.counselorName,
          ),
        ),
      );
      return;
    }
    if (idx == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CarerAnalysisScreen(
            memberId: widget.memberId,
            counselorName: widget.counselorName,
          ),
        ),
      );
      return;
    }
    if (idx == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CareManageScreen(
            memberId: widget.memberId,
            counselorName: widget.counselorName,
          ),
        ),
      );
      return;
    }
    // idx == 3 : 자기 자신 탭(마이페이지)이므로 인덱스만 변경
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '마이페이지',
      showLogoutButton: true,
      currentIndex: _selectedIndex,
      onTap: _onNavTapped,
      body: FutureBuilder<CaregiverProfile>(
        future: _futureProfile,
        builder: (context, snapshot) {
          // 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 에러
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '데이터를 불러올 수 없습니다.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 정상적으로 데이터가 로드된 경우
          final profile = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1) 프로필 아이콘
                const Icon(Icons.account_circle, size: 100, color: Colors.grey),
                const SizedBox(height: 24),

                // 2) 이름
                UserInfoBox(text: '이름: ${profile.name}'),

                // 3) (편의상) “아이디(EditIdField)” → 실제로는 로그인 아이디일 수 있습니다.
                EditIdField(
                  initialId: profile.caregiverId.toString(),
                  onSave: (newId) {
                    // TODO: 로그인 아이디 변경 API가 필요하다면 호출
                    print('변경된 아이디: $newId');
                  },
                ),

                // 4) 전화번호
                UserInfoBox(text: '전화번호: ${profile.phone}'),

                // 5) 돌봄 대상자(노인) 리스트 (예시로 단순 나열)
                const SizedBox(height: 16),
                const Text(
                  '돌봄 대상자 목록',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  profile.elderlyNames.length,
                  (i) => UserInfoBox(
                    text:
                        '${profile.elderlyNames[i]} (전화: ${profile.elderlyPhones[i]})',
                  ),
                ),

                const SizedBox(height: 20),

                // 6) 계정 탈퇴 버튼
                TextButton(
                  onPressed: () {
                    // TODO: 계정 탈퇴 로직
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 48, 81, 120),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(80, 40),
                  ),
                  child: const Text(
                    '계정 탈퇴',
                    style: TextStyle(color: Color.fromARGB(255, 48, 81, 120)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
