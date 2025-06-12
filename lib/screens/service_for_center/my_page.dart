// lib/screens/service_for_center/my_page.dart

import 'package:flutter/material.dart';
import 'package:frontend/models/staff_profile.dart';
import 'package:frontend/services/staff_service.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/user_info_box.dart';
import 'package:frontend/screens/service_for_center/analysis_screen.dart';
import 'package:frontend/screens/service_for_center/home_screen.dart';
import 'package:frontend/screens/service_for_center/care_manage_screen.dart';

class CenterMyPageScreen extends StatefulWidget {
  final int memberId; // 로그인 시 받은 staffId
  final String counselorName; // (Optional) 뒤로 돌아갈 때 사용할 이름

  const CenterMyPageScreen({
    super.key,
    required this.memberId,
    required this.counselorName,
  });

  @override
  State<CenterMyPageScreen> createState() => _CenterMyPageScreenState();
}

class _CenterMyPageScreenState extends State<CenterMyPageScreen> {
  late Future<StaffProfile> _futureProfile;
  int _selectedIndex = 3; // 마이페이지 탭은 인덱스 3

  @override
  void initState() {
    super.initState();
    // 화면이 열리면 바로 API 호출
    _futureProfile = StaffService.instance.fetchMyPage(widget.memberId);
  }

  void _onNavTapped(int idx) {
    // 인덱스 이동 처리: 0=Home, 1=Analysis, 2=CareManage, 3=MyPage
    if (idx == 0) {
      // “🏠” → 담당자 홈(목록) 화면으로 돌아간다
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CenterHomeScreen(
            memberId: widget.memberId,
            counselorName: widget.counselorName,
          ),
        ),
      );
      return;
    }
    if (idx == 1) {
      // 분석 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CenterAnalysisScreen(
            memberId: widget.memberId,
            counselorName: widget.counselorName,
          ),
        ),
      );
      return;
    }
    if (idx == 2) {
      // 돌봄 관리 화면으로 이동
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
    if (idx == 3) {
      setState(() => _selectedIndex = 3);
      return;
    }
    // idx == 3 (자기 자신 탭) 또는 그 외 인덱스는 단순 변경
    setState(() => _selectedIndex = idx);
  }

  String formatPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '마이페이지',
      showLogoutButton: true,
      currentIndex: _selectedIndex,
      onTap: _onNavTapped,
      body: FutureBuilder<StaffProfile>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 중인 상태
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // 에러 발생 시 메시지
            return Center(
              child: Text(
                '데이터를 불러올 수 없습니다.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 데이터가 정상적으로 로드된 경우
          final profile = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 상단 프로필 아이콘
                const Icon(Icons.account_circle, size: 100, color: Colors.grey),
                const SizedBox(height: 24),

                // 1) 이름
                UserInfoBox(text: '이름: ${profile.name}'),

                // 3) 전화번호
                UserInfoBox(text: '전화번호: ${formatPhoneNumber(profile.phone)}'),

                // 4) 소속기관
                UserInfoBox(text: '소속기관: ${profile.welfareCenterName}'),

                const SizedBox(height: 20),

                // 5) 계정 탈퇴 버튼
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
