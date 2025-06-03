// lib/screens/service_for_center/home_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/models/care_target.dart';
import 'package:frontend/services/care_service.dart';
import 'package:frontend/screens/service_for_carer/care_manage_screen.dart'; // ← 돌봄 관리 화면 import
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/filter_button.dart';
import 'package:frontend/widgets/target_card.dart';

class CenterHomeScreen extends StatefulWidget {
  final int memberId;
  final String counselorName;

  const CenterHomeScreen({
    super.key,
    required this.memberId,
    required this.counselorName,
  });

  @override
  _CenterHomeScreenState createState() => _CenterHomeScreenState();
}

class _CenterHomeScreenState extends State<CenterHomeScreen> {
  List<CareTarget> _careTargets = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  bool _filterDanger = false;
  int _currentIndex = 0; // 하단바에서 현재 선택된 인덱스

  @override
  void initState() {
    super.initState();
    _fetchTargets();
  }

  Future<void> _fetchTargets() async {
    try {
      final targets = await CareService.instance.fetchTargets(widget.memberId);
      if (!mounted) return;
      setState(() {
        _careTargets = targets;
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

  /// 하단바 아이콘 클릭 처리
  void _onTapNavBar(int idx) {
    // 0번(🏠) 클릭 → 이미 이 화면이므로 인덱스만 바꿔주고 리턴
    if (idx == 0) {
      setState(() => _currentIndex = 0);
      return;
    }

    // 2번(🤚) 클릭 → 돌봄 관리 화면(CareManageScreen)으로 대체(pushReplacement)
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

    // 나머지(1, 3) 클릭 시에는 그냥 인덱스만 바꿉니다.
    setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '관리 대상자',
      showLogoutButton: true,
      currentIndex: _currentIndex,
      onTap: _onTapNavBar, // ← 기존의 setState 콜백을 이 함수로 교체
      body: _buildAdminView(),
    );
  }

  Widget _buildAdminView() {
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

    // 검색어 + 필터링
    final filtered = _careTargets.where((t) {
      final matchQuery = t.name.contains(_searchQuery);
      final matchDanger = !_filterDanger || t.isDanger;
      return matchQuery && matchDanger;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ───────────── 1) 검색창 ─────────────
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),

        // ───────────── 2) 위험군 필터 버튼 ─────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilterButton(
            label: '위험군',
            color: Colors.redAccent,
            active: _filterDanger,
            onTap: () => setState(() => _filterDanger = !_filterDanger),
          ),
        ),

        // ───────────── 3) 대상자 수 텍스트 ─────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '총 ${filtered.length}명의 관리 대상자가 있습니다.',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        // ───────────── 4) 대상자 카드 리스트 ─────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final t = filtered[i];
              return TargetCard(
                name: t.name,
                address: t.address,
                center: t.welfareCenterName,
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
