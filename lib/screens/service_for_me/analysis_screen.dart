// lib/screens/service_for_me/analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/weekly_analysis_graph.dart';
import 'package:frontend/widgets/sleep_analysis_graph.dart';
import 'package:frontend/widgets/go_out_analysis_graph.dart';
import 'package:frontend/screens/service_for_me/home_screen.dart'; // HomeScreen import
import 'package:frontend/screens/service_for_me/care_history_screen.dart';

class WeeklyReportScreen extends StatefulWidget {
  final int userId; // 로그인 시 전달받은 userId

  const WeeklyReportScreen({super.key, required this.userId});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  int _currentIndex = 1; // BottomNavigationBar에서 현재 선택된 인덱스
  final int _selectedTabIndex = 0; // 탭(0=주간분석, 1=수면분석, 2=외출분석)
  DateTime _selectedDate = DateTime.now(); // 현재 선택된 날짜(초기값 오늘)

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year, now.month, now.day),
      locale: const Locale('ko'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 48, 81, 120),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

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
      // 이미 분석 화면이므로, 단순히 인덱스만 변경
      setState(() => _currentIndex = 1);
      return;
    }
    if (idx == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MyCareHistoryScreen(userId: widget.userId),
        ),
      );
      return;
    }
    setState(() => _currentIndex = idx);
  }
  }

  final List<String> _tabs = ['주간 분석 레포트', '수면 분석', '외출 분석'];

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '분석 레포트',
      showLogoutButton: true,
      currentIndex: _currentIndex,
      onTap: _handleTap,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // ─── 날짜 선택 영역 ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: _pickDate,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 25),
                    const SizedBox(width: 8),
                    Text(
                      '선택된 날짜: '
                      '${_selectedDate.year}년 ${_selectedDate.month.toString().padLeft(2, '0')}월 '
                      '${_selectedDate.day.toString().padLeft(2, '0')}일',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            // ─── 탭 선택 바 ───
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_tabs.length, (index) {
                final isSelected = (_selectedTabIndex == index);
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTabIndex = index);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? const Color.fromARGB(255, 48, 81, 120)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // ─── 범례 ───
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _LegendItem(color: Colors.orange, label: '지난주'),
                  SizedBox(width: 12),
                  _LegendItem(color: Colors.deepPurple, label: '이번주'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ─── 탭별 콘텐츠 ───
            if (_selectedTabIndex == 0) ...[
              WeeklyAnalysisChart(
                userId: widget.userId,
                selectedDate: _selectedDate,
              ),
            ] else if (_selectedTabIndex == 1) ...[
              SleepAnalysisGraph(
                userId: widget.userId,
                selectedDate: _selectedDate,
              ),
            ] else if (_selectedTabIndex == 2) ...[
              GoOutAnalysisGraph(
                userId: widget.userId,
                selectedDate: _selectedDate,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 범례 아이템 위젯
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
