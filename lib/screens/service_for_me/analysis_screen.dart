import 'package:flutter/material.dart';
import 'package:frontend/widgets/go_out_analysis_graph.dart';
import 'package:frontend/widgets/sleep_analysis_graph.dart';
import 'package:frontend/widgets/weekly_analysis_graph.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/user_summary_card.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  int _selectedIndex = 1;
  int _selectedTabIndex = 0;
  DateTime _selectedDate = DateTime(2024, 8, 19); // 초기 선택값

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 8, 11),
      lastDate: DateTime(2024, 8, 24),
      locale: const Locale('ko'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 48, 81, 120), // 상단 색
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  final List<String> _tabs = ['주간 분석 레포트', '수면 분석', '외출 분석'];

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '분석 레포트',
      showLogoutButton: true,
      currentIndex: _selectedIndex,
      onTap: _onNavTapped,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserInfoBox(),
            const SizedBox(height: 8),
            _buildDateRange(),
            const SizedBox(height: 16),
            _buildTabSelector(),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 8),
            _buildSelectedContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoBox() {
    return const UserSummaryCard(
      info: {
        '이름': '김철수(남)',
        '주소': '서울시 강남구 강남대로 1번길 123',
      },
      isDanger: true,
    );
  }

  Widget _buildDateRange() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: _pickDate,
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, size: 25),
            const SizedBox(width: 8),
            Text(
              '선택된 날짜: ${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// 탭 버튼 UI
  Widget _buildTabSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_tabs.length, (index) {
        final isSelected = _selectedTabIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 20, left: 20),
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
    );
  }

  /// 탭 선택에 따라 보여줄 위젯
  Widget _buildSelectedContent() {
    switch (_selectedTabIndex) {
      case 0:
        return WeeklyAnalysisChart();
      case 1:
        return SleepAnalysisGraph(selectedDate: _selectedDate);
      case 2:
        return GoOutAnalysisGraph(selectedDate: _selectedDate);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 범례 위젯
  Widget _buildLegend() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _LegendItem(color: Colors.orange, label: '지난주'),
          SizedBox(width: 12),
          _LegendItem(color: Colors.deepPurple, label: '이번주'),
        ],
      ),
    );
  }
}

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
