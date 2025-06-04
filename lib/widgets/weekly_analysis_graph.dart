// lib/widgets/weekly_analysis_graph.dart

import 'package:flutter/material.dart';
import 'package:frontend/models/weekly_analysis.dart';
import 'package:frontend/services/analysis_service.dart';
import 'package:intl/intl.dart';

class WeeklyAnalysisChart extends StatelessWidget {
  final int userId;
  final DateTime selectedDate;

  const WeeklyAnalysisChart({
    super.key,
    required this.userId,
    required this.selectedDate,
  });

  /// API 호출: 주간 분석 데이터 가져오기
  Future<WeeklyAnalysis> _fetchWeeklyData() async {
    final toStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final fromDate = selectedDate.subtract(const Duration(days: 6));
    final fromStr = DateFormat('yyyy-MM-dd').format(fromDate);

    return await AnalysisService.instance.fetchWeeklyAnalysis(
      userId: userId,
      to: toStr,
      from: fromStr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeeklyAnalysis>(
      future: _fetchWeeklyData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 48, 81, 120),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text('데이터를 불러올 수 없습니다.\n${snapshot.error}',
                textAlign: TextAlign.center),
          );
        }

        final data = snapshot.data!;
        // data.labels: ["수면", "온도", "습도", "외출 횟수", "실내 활동량"]
        // data.dataCurrent: 이번 주 값 e.g. [7.5, 25.7, 20.0, 7.2, 120.5]
        // data.dataPrevious: 지난주 값 e.g. [6.3, 26.2, 24.0, 6.8, 104.1]

        return Column(
          children: [
            const SizedBox(height: 5),
            ...List.generate(data.labels.length, (index) {
              return _buildBarGroup(
                label: data.labels[index],
                lastWeekValue: data.dataPrevious[index],
                thisWeekValue: data.dataCurrent[index],
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildBarGroup({
    required String label,
    required double lastWeekValue,
    required double thisWeekValue,
  }) {
    double maxValue;
    // 레이블에 따라 적절한 최대값을 설정
    if (label.contains('수면')) {
      maxValue = 16.0;
    } else if (label.contains('외출')) {
      maxValue = 15.0;
    } else if (label.contains('실내')) {
      maxValue = 4000.0;
    } else if (label.contains('온도') || label.contains('습도')) {
      maxValue = 50.0; // 온도/습도 단위가 0~50 정도라고 가정
    } else {
      maxValue = 100.0;
    }

    // 화면 너비의 90%를 기준으로 막대 너비 계산
    final maxWidth =
        MediaQueryData.fromView(WidgetsBinding.instance.window).size.width *
            0.9;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBar(lastWeekValue, maxValue, Colors.orange, maxWidth),
              const SizedBox(height: 3),
              _buildBar(thisWeekValue, maxValue, Colors.deepPurple, maxWidth),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('지난주: ${lastWeekValue.toStringAsFixed(1)}'),
              const SizedBox(width: 16),
              Text('이번주: ${thisWeekValue.toStringAsFixed(1)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
      double value, double max, Color color, double totalMaxWidth) {
    final ratio = (value / max).clamp(0.0, 1.0);
    final width = (ratio * totalMaxWidth).toDouble();
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
