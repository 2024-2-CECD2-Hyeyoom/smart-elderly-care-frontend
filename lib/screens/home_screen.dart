// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/login_screen.dart';

// 모델 import
import 'package:frontend/models/dashboard_data.dart';
import 'package:frontend/models/care_target_list.dart';

// 위젯 import
import 'package:frontend/widgets/user_summary_card.dart';
import 'package:frontend/widgets/filter_button.dart';
import 'package:frontend/widgets/target_card.dart';

class HomeScreen extends StatefulWidget {
  final LoginType loginType;
  const HomeScreen({super.key, required this.loginType});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  bool _filterDanger = false;
  bool _filterAbsent = false;

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.loginType == LoginType.user ? '모니터링' : '관리 대상자',
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 0,
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: widget.loginType == LoginType.user
          ? _buildUserView()
          : _buildAdminView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // TODO: index에 따라 화면 전환
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '분석'),
          BottomNavigationBarItem(icon: Icon(Icons.handshake), label: '돌봄'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내정보'),
        ],
      ),
    );
  }

  Widget _buildUserView() {
    // 임시 JSON response body
    const dummyJson = {
      'userId': 12345,
      'name': '홍길동',
      'gender': 1, // 0=여, 1=남
      'address': '서울시 강남구 테헤란로 10길 20',
      'welfareCenter': '강북복지센터',
      'phoneNumber': '010-1111-2222',
      'guardianPhone': '010-3333-4444',
      'underlyingConditions': ['고혈압', '당뇨'],
      'careStatus': 0, // 0=정상, 1=위험
    };

    // 모델로 파싱
    final data = DashboardData.fromJson(dummyJson);

    // Map<String,String> 으로 가공
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

    // 요약 카드 표시
    return Center(
      child: UserSummaryCard(
        info: infoMap,
        isDanger: isDanger,
      ),
    );
  }

  Widget _buildAdminView() {
    // 1) 더미 JSON (백엔드 완성되면 fetch 결과로 대체)
    const dummyAdminJson = {
      'careTargets': [
        {
          'userId': 111,
          'name': '김철수(남)',
          'gender': 1,
          'address': '서울시 강남구 강남대로 100번길 123',
          'welfareCenter': 'OO복지센터',
          'phoneNumber': '010-0000-0000',
          'careStatus': 1,
        },
        {
          'userId': 222,
          'name': '박말순(여)',
          'gender': 0,
          'address': '서울시 강남구 강남대로 1번길 456',
          'welfareCenter': 'OO복지센터',
          'phoneNumber': '010-0000-0000',
          'careStatus': 0,
        },
      ]
    };

    // 2) 모델로 파싱
    final all = CareTargetList.fromJson(dummyAdminJson).careTargets;

    // 3) 필터링: 검색어 + 위험군
    final filtered = all.where((t) {
      final matchQuery = t.name.contains(_searchQuery);
      final matchDanger = !_filterDanger || t.isDanger;
      return matchQuery && matchDanger;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 검색창
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요.',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),

        // 필터 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterButton(
                label: '위험군',
                color: Colors.redAccent,
                active: _filterDanger,
                onTap: () => setState(() => _filterDanger = !_filterDanger),
              ),
              const SizedBox(width: 8),
              FilterButton(
                label: '장기부재',
                color: Colors.yellow.shade700,
                active: _filterAbsent,
                onTap: () => setState(() => _filterAbsent = !_filterAbsent),
              ),
            ],
          ),
        ),

        // 대상자 수
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '총 ${filtered.length}명의 관리 대상자가 있습니다.',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        // 대상자 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final t = filtered[i];
              return TargetCard(
                name: t.name,
                address: t.address,
                center: t.welfareCenter,
                contact: t.phoneNumber,
                isDanger: t.isDanger,
                isAbsent: false, // json에 없는 '장기부재' 데이터이기에 임시로 false로 지정하였음.
              );
            },
          ),
        ),
      ],
    );
  }
}
