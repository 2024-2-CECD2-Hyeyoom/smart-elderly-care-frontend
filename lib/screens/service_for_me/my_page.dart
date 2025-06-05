// lib/screens/service_for_me/my_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/my_page_data.dart';
import 'package:frontend/screens/service_for_me/care_history_screen.dart';
import 'package:frontend/screens/service_for_me/home_screen.dart';
import 'package:frontend/screens/service_for_me/analysis_screen.dart';
import 'package:frontend/services/my_page_service.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/edit_id.dart';
import 'package:frontend/widgets/user_info_box.dart';

class MyPageScreen extends StatefulWidget {
  final int userId; // 로그인 시 전달받은 userId

  const MyPageScreen({super.key, required this.userId});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  int _selectedIndex = 3; // “마이페이지” 탭은 idx = 3

  bool _isLoading = true;
  String? _errorMessage;
  MyPageData? _myPageData;

  @override
  void initState() {
    super.initState();
    _fetchMyPage();
  }

  Future<void> _fetchMyPage() async {
    try {
      final data = await MyPageService.instance.fetchMyPage(widget.userId);
      if (!mounted) return;
      setState(() {
        _myPageData = data;
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

  void _onNavTapped(int idx) {
    // 아래처럼 idx에 따라 각 화면으로 이동
    if (idx == 0) {
      // Home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MyHomeScreen(userId: widget.userId),
        ),
      );
      return;
    }
    if (idx == 1) {
      // Analysis
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WeeklyReportScreen(userId: widget.userId),
        ),
      );
      return;
    }
    if (idx == 2) {
      // Care History
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MyCareHistoryScreen(userId: widget.userId),
        ),
      );
      return;
    }
    if (idx == 3) {
      // 이미 Home 화면이므로, 단순히 인덱스만 변경
      setState(() => _selectedIndex = 3);
      return;
    }
    // idx == 3: 이미 “마이페이지”이므로 단순 인덱스만 교체
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '마이페이지',
      showLogoutButton: true,
      currentIndex: _selectedIndex,
      onTap: _onNavTapped,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _buildBody(),
      ),
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

    final data = _myPageData!;
    final genderText = data.gender == 0 ? '여' : '남';
    final birthStr = DateFormat('yyyy년 MM월 dd일').format(data.birthDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle, size: 100, color: Colors.grey),
        const SizedBox(height: 24),

        // “EditIdField”는 API에서 받은 elderlyId를 초기값으로 합니다.
        EditIdField(
          initialId: data.elderlyId,
          onSave: (newId) {
            // TODO: ID 수정 위한 API 호출이 필요하면 이곳에 넣고,
            //       다시 _fetchMyPage() 등을 호출하여 화면을 갱신하십시오.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('아이디가 변경되었습니다.')),
            );
          },
        ),

        // 나머지 유저 정보 박스
        UserInfoBox(text: '이름: ${data.name} ($genderText)'),
        UserInfoBox(text: '생년월일: $birthStr'),
        UserInfoBox(text: '전화번호: ${data.phone}'),
        UserInfoBox(text: '주소: ${data.address}'),
        UserInfoBox(text: '고유코드: ${data.elderlyId}'),
        UserInfoBox(text: '관리기관: ${data.welfareCenterName}'),
        UserInfoBox(text: '기저질환: ${data.underlyingDiseases.join(', ')}'),
        const SizedBox(height: 20),

        TextButton(
          onPressed: () {
            // TODO: “계정 탈퇴” API 호출 또는 화면 전환 로직
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
    );
  }
}
