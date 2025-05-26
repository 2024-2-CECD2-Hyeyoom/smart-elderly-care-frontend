import 'package:flutter/material.dart';
import 'package:frontend/models/weekly_analysis_data.dart';

class WeeklyAnalysisChart extends StatelessWidget {
  final double maxWidth = 300;
  final DateTime selectedDate;

  const WeeklyAnalysisChart({super.key, required this.selectedDate});

  Future<List<WeeklyAnalysisData>> fetchWeeklyAnalysisData(
      DateTime date) async {
    // TODO: 서버 연동 시 여기를 수정하여 API 호출
    await Future.delayed(const Duration(milliseconds: 300)); // 네트워크 지연 시뮬레이션

    return [
      WeeklyAnalysisData(
        label: '하루 평균 수면 시간',
        displayLastWeekValue: '6시간 30분',
        displayThisWeekValue: '5시간 48분',
        lastWeekValue: 6.5,
        thisWeekValue: 5.8,
      ),
      WeeklyAnalysisData(
        label: '하루 평균 외출 횟수',
        displayLastWeekValue: '1.2회',
        displayThisWeekValue: '2.0회',
        lastWeekValue: 1.2,
        thisWeekValue: 2.0,
      ),
      WeeklyAnalysisData(
        label: '하루 평균 실내 활동량',
        displayLastWeekValue: '2500',
        displayThisWeekValue: '2000',
        lastWeekValue: 2500.0,
        thisWeekValue: 2000.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WeeklyAnalysisData>>(
      future: fetchWeeklyAnalysisData(selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('데이터를 불러올 수 없습니다.'));
        }

        final data = snapshot.data!;

        return Column(
          children: [
            const SizedBox(height: 5),
            ...data.map((entry) => _buildBarGroup(entry)),
          ],
        );
      },
    );
  }

  Widget _buildBarGroup(WeeklyAnalysisData entry) {
    double maxValue;
    if (entry.label.contains('수면')) {
      maxValue = 16.0;
    } else if (entry.label.contains('외출')) {
      maxValue = 15.0;
    } else if (entry.label.contains('실내')) {
      maxValue = 4000.0;
    } else {
      maxValue = 100.0; // fallback value
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBar(entry.lastWeekValue, maxValue, Colors.orange),
              const SizedBox(height: 3),
              _buildBar(entry.thisWeekValue, maxValue, Colors.deepPurple),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('지난주: ${entry.displayLastWeekValue}'),
              const SizedBox(width: 16),
              Text('이번주: ${entry.displayThisWeekValue}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double value, double max, Color color) {
    final ratio = (value / max).clamp(0.0, 1.0);
    final width = (ratio * maxWidth).toDouble();
    return Container(
      height: 13,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
    );
  }
}
