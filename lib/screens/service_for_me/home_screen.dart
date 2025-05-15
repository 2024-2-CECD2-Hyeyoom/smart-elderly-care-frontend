import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/login_screen.dart';
import 'package:frontend/models/dashboard_data.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/user_summary_card.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '모니터링',
      showLogoutButton: true,
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      body: _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    const dummyJson = {
      'userId': 12345,
      'name': '홍길동',
      'gender': 1,
      'address': '서울시 강남구 테헤란로 10길 20',
      'welfareCenter': '강북복지센터',
      'phoneNumber': '010-1111-2222',
      'guardianPhone': '010-3333-4444',
      'underlyingConditions': ['고혈압', '당뇨'],
      'careStatus': 0,
    };

    final data = DashboardData.fromJson(dummyJson);
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
