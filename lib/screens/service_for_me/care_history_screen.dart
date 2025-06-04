// lib/screens/service_for_me/care_history_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/care_history_card.dart';
import 'package:frontend/models/care_history.dart';
import 'package:frontend/services/care_history_service.dart';
import 'package:frontend/screens/service_for_me/home_screen.dart'; // HomeScreen import
import 'package:frontend/screens/service_for_me/analysis_screen.dart';

class MyCareHistoryScreen extends StatefulWidget {
  final int userId; // 로그인 시 전달받은 userId
  const MyCareHistoryScreen({super.key, required this.userId});

  @override
  _CareHistoryScreenState createState() => _CareHistoryScreenState();
}

class _CareHistoryScreenState extends State<MyCareHistoryScreen> {
  String _searchQuery = '';
  DateTimeRange? _selectedRange;
  int _currentIndex = 2; // pan_tool_alt 탭이므로 초기 인덱스를 2로 설정

  late final List<CareHistory> _allHistory;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final List<CareHistory> list =
          await CareHistoryService.instance.fetchHistory(widget.userId);
      if (!mounted) return;
      setState(() {
        _allHistory = list;
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

  /// BottomNavigationBar 클릭 처리
  void _handleTap(int idx) {
    if (idx == 0) {
      // “Home” 버튼 클릭 → MyHomeScreen(사용자 홈)으로 돌아갑니다.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MyHomeScreen(userId: widget.userId),
        ),
      );
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
    if (idx == 2) {
      // 이미 이 화면이므로, 단순 인덱스만 바꾸기
      setState(() => _currentIndex = 2);
      return;
    }
    // 그 외 인덱스는 단순히 인덱스만 바꿔 줍니다.
    setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '돌봄 이력',
      showLogoutButton: true,
      currentIndex: _currentIndex,
      onTap: _handleTap,
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

    // _allHistory가 null일 수 없도록 initState에서 초기화 했다고 가정합니다.
    final filtered = _allHistory.where((h) {
      final matchesText = _searchQuery.isEmpty ||
          [h.purpose, h.content, h.counselorName]
              .any((v) => v.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesRange = _selectedRange == null ||
          (h.visitDate.isAfter(
                  _selectedRange!.start.subtract(const Duration(days: 1))) &&
              h.visitDate
                  .isBefore(_selectedRange!.end.add(const Duration(days: 1))));
      return matchesText && matchesRange;
    }).toList();

    String rangeText;
    if (_selectedRange == null) {
      rangeText = '기간을 선택하세요.';
    } else {
      rangeText =
          '${_selectedRange!.start.year}.${_selectedRange!.start.month.toString().padLeft(2, '0')}.${_selectedRange!.start.day.toString().padLeft(2, '0')} - '
          '${_selectedRange!.end.year}.${_selectedRange!.end.month.toString().padLeft(2, '0')}.${_selectedRange!.end.day.toString().padLeft(2, '0')}';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
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
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDateRange: _selectedRange,
                  );
                  if (picked != null) {
                    setState(() => _selectedRange = picked);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '필터 초기화',
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedRange = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(rangeText,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          ...filtered.map((h) => CareHistoryCard(history: h)),
          const SizedBox(height: 16),
          Text(
            '총 ${filtered.length}개의 방문 이력이 있습니다.',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
