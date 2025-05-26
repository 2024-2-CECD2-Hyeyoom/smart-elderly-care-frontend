import 'package:flutter/material.dart';
import 'package:frontend/widgets/weekly_analysis_graph.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/user_summary_card.dart';

class CenterWeeklyReportScreen extends StatefulWidget {
  const CenterWeeklyReportScreen({super.key});

  @override
  State<CenterWeeklyReportScreen> createState() =>
      _CenterWeeklyReportScreenState();
}

class _CenterWeeklyReportScreenState extends State<CenterWeeklyReportScreen> {
  int _selectedIndex = 1;
  int _selectedTabIndex = 0; // 주간/수면/외출 탭 인덱스

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            const SizedBox(height: 16),
            _buildUserInfoBox(),
            const SizedBox(height: 8),
            _buildTabSelector(),
            const SizedBox(height: 16),
            _buildDateRange(),
            const SizedBox(height: 16),
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
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16),
          SizedBox(width: 8),
          Text('2024년 8월 11일 ~ 8월 25일'),
        ],
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
            padding: const EdgeInsets.only(bottom: 4), // 밑줄 아래 여백
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
      //return WeeklyAnalysisChart(); // 주간 분석 그래프
      case 1:
        return const Text("수면 분석 레포트");
      case 2:
        return const Text("외출 분석 레포트");
      default:
        return const SizedBox.shrink();
    }
  }
}
