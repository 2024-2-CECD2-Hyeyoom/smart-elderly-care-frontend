// lib/screens/service_for_me/home_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/models/dashboard_data.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/user_summary_card.dart';
import 'package:frontend/screens/service_for_me/care_history_screen.dart';
import 'package:frontend/screens/service_for_me/analysis_screen.dart';

class MyHomeScreen extends StatefulWidget {
  final int userId; // 로그인 시 전달받은 userId
  const MyHomeScreen({super.key, required this.userId});

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final ProfileService _profileService = ProfileService.instance;

  DashboardData? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentIndex = 0; // 하단바에서 현재 선택된 인덱스 (0부터 시작)

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
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

  /// 하단바 아이콘 클릭 처리 함수
  void _onTapNavBar(int idx) {
    // idx == 0: Home 아이콘 클릭
    if (idx == 0) {
      // 이미 Home 화면이므로, 단순히 인덱스만 변경
      setState(() => _currentIndex = 0);
      return;
    }
    if (idx == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WeeklyReportScreen(userId: widget.userId),
        ),
      );
      return;
    }
    // idx == 2: pan_tool_alt 아이콘 클릭 → Care History 화면으로 이동
    if (idx == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MyCareHistoryScreen(userId: widget.userId),
        ),
      );
      return;
    }
    // 그 외 인덱스(3)는 여기서 특별 처리하지 않으므로, 인덱스만 변경
    setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '모니터링',
      showLogoutButton: true,
      currentIndex: _currentIndex,
      onTap: _onTapNavBar, // ← 하단바 클릭 시 호출될 콜백
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
