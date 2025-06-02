// lib/screens/service_for_carer/home_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/models/care_target.dart';
import 'package:frontend/services/care_service.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/filter_button.dart';
import 'package:frontend/widgets/target_card.dart';

class CarerHomeScreen extends StatefulWidget {
  final int memberId;
  const CarerHomeScreen({super.key, required this.memberId});

  @override
  _CarerHomeScreenState createState() => _CarerHomeScreenState();
}

class _CarerHomeScreenState extends State<CarerHomeScreen> {
  List<CareTarget> _careTargets = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  bool _filterDanger = false;
  int _currentIndex = 0;

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

    // 검색 및 필터링 로직
    final filtered = _careTargets.where((t) {
      final matchQuery = t.name.contains(_searchQuery);
      final matchDanger = !_filterDanger || t.isDanger;
      return matchQuery && matchDanger;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 검색 텍스트필드
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

        // 위험군 필터 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilterButton(
            label: '위험군',
            color: Colors.redAccent,
            active: _filterDanger,
            onTap: () => setState(() => _filterDanger = !_filterDanger),
          ),
        ),

        // 대상자 수 텍스트
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '총 ${filtered.length}명의 관리 대상자가 있습니다.',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        // 대상자 카드 리스트
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
