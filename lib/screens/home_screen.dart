import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final LoginType loginType;
  const HomeScreen({super.key, required this.loginType});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 사용자 모드 임시 데이터
  final _userInfo = {
    '이름': '김철수(남)',
    '주소': '서울시 강남구 강남대로 1번길 123',
    '담당복지센터': '서울시 강남구 OO복지센터',
    '연락처': '010-1234-5678',
    '보호자 연락처': '010-8765-4321',
    '기저질환': '고혈압, 당뇨',
  };
  final bool _isDanger = true;

  // 관리자 모드 임시 데이터
  final List<Map<String, dynamic>> _targets = [
    {
      'name': '김철수(남)',
      'address': '서울시 강남구 강남대로 1번길 123',
      'center': 'OO복지센터',
      'contact': '010-0000-0000',
      'isDanger': true,
      'isAbsent': false
    },
    {
      'name': '박말순(여)',
      'address': '서울시 강남구 강남대로 1번길 456',
      'center': 'OO복지센터',
      'contact': '010-0000-0000',
      'isDanger': false,
      'isAbsent': false
    },
    {
      'name': '이용은(남)',
      'address': '서울시 강남구 강남대로 1번길 789',
      'center': 'OO복지센터',
      'contact': '010-1234-5678',
      'isDanger': false,
      'isAbsent': true
    },
    // ... 추가 대상
  ];
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
              child: const Text('로그아웃',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
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
    return Center(
      child: InfoCard(
        children: [
          ..._userInfo.entries
              .map((e) => InfoRow(label: e.key, value: e.value)),
          CareStatus(isDanger: _isDanger),
        ],
      ),
    );
  }

  Widget _buildAdminView() {
    final filtered = _targets.where((t) {
      final matchQuery = t['name'].contains(_searchQuery);
      final matchDanger = !_filterDanger || t['isDanger'];
      final matchAbsent = !_filterAbsent || t['isAbsent'];
      return matchQuery && matchDanger && matchAbsent;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('총 ${filtered.length}명의 관리 대상자가 있습니다.',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final t = filtered[i];
              return TargetCard(
                name: t['name'],
                address: t['address'],
                center: t['center'],
                contact: t['contact'],
                isDanger: t['isDanger'],
                isAbsent: t['isAbsent'],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 필터 버튼 위젯
class FilterButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const FilterButton({
    super.key,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? color : Colors.grey.shade400),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// 사용자 정보 섹션 카드 (변경 없음)
class InfoCard extends StatelessWidget {
  final List<Widget> children;
  const InfoCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// 대상자 카드 위젯
class TargetCard extends StatelessWidget {
  final String name, address, center, contact;
  final bool isDanger, isAbsent;
  const TargetCard(
      {super.key,
      required this.name,
      required this.address,
      required this.center,
      required this.contact,
      required this.isDanger,
      required this.isAbsent});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Icon(
                  isDanger ? Icons.warning : Icons.check_circle,
                  color: isDanger ? Colors.red : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('주소: $address', style: const TextStyle(fontSize: 12)),
            Text('복지센터: $center', style: const TextStyle(fontSize: 12)),
            Text('연락처: $contact', style: const TextStyle(fontSize: 12)),
            if (isAbsent) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('장기부재',
                    style: TextStyle(fontSize: 10, color: Colors.black)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 정보 한 줄 표시 (레이블: 값) - 재사용
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }
}

/// 돌봄 상태 표시 위젯
class CareStatus extends StatelessWidget {
  final bool isDanger;
  const CareStatus({super.key, required this.isDanger});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          const Text('돌봄상태: ', style: TextStyle(fontSize: 16)),
          Icon(
            Icons.warning,
            color: isDanger ? Colors.red : Colors.grey.shade400,
            size: 28,
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.check_circle,
            color: !isDanger ? Colors.green : Colors.grey.shade400,
            size: 28,
          ),
          const SizedBox(width: 16),
          Text(
            isDanger ? '위험' : '정상',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDanger ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
