import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screens/login_screen.dart';
import 'package:frontend/models/care_target_list.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/filter_button.dart';
import 'package:frontend/widgets/target_card.dart';

class CenterHomeScreen extends StatefulWidget {
  const CenterHomeScreen({super.key});

  @override
  _CenterHomeScreenState createState() => _CenterHomeScreenState();
}

class _CenterHomeScreenState extends State<CenterHomeScreen> {
  String _searchQuery = '';
  bool _filterDanger = false;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '관리 대상자',
      showLogoutButton: true,
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      body: _buildAdminView(),
    );
  }

  Widget _buildAdminView() {
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

    final all = CareTargetList.fromJson(dummyAdminJson).careTargets;
    final filtered = all.where((t) {
      final matchQuery = t.name.contains(_searchQuery);
      final matchDanger = !_filterDanger || t.isDanger;
      return matchQuery && matchDanger;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilterButton(
            label: '위험군',
            color: Colors.redAccent,
            active: _filterDanger,
            onTap: () => setState(() => _filterDanger = !_filterDanger),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '총 ${filtered.length}명의 관리 대상자가 있습니다.',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
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
                isAbsent: false,
              );
            },
          ),
        ),
      ],
    );
  }
}
