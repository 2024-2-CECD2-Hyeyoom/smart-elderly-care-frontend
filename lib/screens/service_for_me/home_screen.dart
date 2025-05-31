// lib/screens/service_for_me/home_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/models/dashboard_data.dart';
import 'package:frontend/services/profile_service.dart'; // ← ProfileService를 import
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/user_summary_card.dart';

class MyHomeScreen extends StatefulWidget {
  final int userId; // 로그인 시 전달받은 userId
  const MyHomeScreen({super.key, required this.userId});

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  // ProfileService를 singleton 방식으로 사용합니다.
  final ProfileService _profileService = ProfileService.instance;

  DashboardData? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      // ProfileService.fetchProfile을 호출해서 데이터를 받아옵니다.
      final data = await _profileService.fetchProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '모니터링', // AppBar 타이틀
      showLogoutButton: true, // 로그아웃 버튼 보이기
      currentIndex: _currentIndex, // 하단 바 선택 index
      onTap: (i) => setState(() => _currentIndex = i),
      body: _buildBody(), // CustomLayout의 body 부분
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final data = _dashboardData!;
    final infoMap = {
      '이름': data.name,
      '성별': data.gender == 0 ? '여' : '남',
      '주소': data.address,
      '담당복지센터': data.welfareCenter,
      '연락처': data.phoneNumber,
      '보호자 연락처': data.guardianPhone,
      '기저질환': data.underlyingConditions.join(', '),
    };
    final isDanger = data.careStatus != 0;

    return Center(
      child: UserSummaryCard(info: infoMap, isDanger: isDanger),
    );
  }
}
