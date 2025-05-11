import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/edit_id.dart';
import 'package:frontend/widgets/user_info_box.dart';

class CarerMyPageScreen extends StatefulWidget {
  const CarerMyPageScreen({super.key});

  @override
  State<CarerMyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<CarerMyPageScreen> {
  int _selectedIndex = 3;

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.grey),
            const SizedBox(height: 24),
            const UserInfoBox(text: '이름: 남보호(여)'),
            EditIdField(
              initialId: '1234',
              onSave: (newId) {
                // 저장 후 처리 로직
                print('변경된 아이디: $newId');
              },
            ),
            const UserInfoBox(text: '생년월일: 1900년 00월 00일'),
            const UserInfoBox(text: '전화번호: 010-0000-0000'),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {},
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
      ),
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
