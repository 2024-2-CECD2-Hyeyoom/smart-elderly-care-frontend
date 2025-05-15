// lib/screens/home/care_history_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/care_history_card.dart';
import 'package:frontend/models/care_history_list.dart';
import 'package:frontend/models/care_history.dart';

class CareHistoryScreen extends StatefulWidget {
  const CareHistoryScreen({super.key});

  @override
  _CareHistoryScreenState createState() => _CareHistoryScreenState();
}

class _CareHistoryScreenState extends State<CareHistoryScreen> {
  String _searchQuery = '';
  DateTimeRange? _selectedRange;
  int _currentIndex = 2;

  late final List<CareHistory> _allHistory;

  static const _dummyJson = {
    'careHistories': [
      {
        'CareHistoryId': 1,
        'visitDate': '2025-12-01',
        'purpose': '건강상담',
        'content': '혈압과 혈당 수치를 확인하고 관리 방법 논의',
        'counselorName': '김동국',
      },
      {
        'CareHistoryId': 2,
        'visitDate': '2025-11-15',
        'purpose': '영양관리',
        'content': '식단 점검 및 보충제 안내',
        'counselorName': '박영희',
      },
      {
        'CareHistoryId': 3,
        'visitDate': '2025-10-20',
        'purpose': '운동지도',
        'content': '가벼운 체조 동작 설명',
        'counselorName': '최민수',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _allHistory = CareHistoryList.fromJson(_dummyJson).careHistories;
  }

  @override
  Widget build(BuildContext context) {
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

    return CustomLayout(
      title: '돌봄 이력',
      showLogoutButton: true,
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색 + 날짜 범위 선택 + 필터 초기화 버튼
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
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
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
            Text(
              rangeText,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...filtered.map((h) => CareHistoryCard(history: h)),
            const SizedBox(height: 16),
            Text(
              '총 ${filtered.length}개의 방문 이력이 있습니다.',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
