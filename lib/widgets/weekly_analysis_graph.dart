import 'package:flutter/material.dart';

class WeeklyAnalysisChart extends StatelessWidget {
  final double maxWidth = 300; // 막대 최대 너비

  final List<Map<String, dynamic>> data = [
    {
      'label': '하루 평균 수면 시간',
      'unit': '시간',
      'lastWeek': 6.5,
      'thisWeek': 5.8,
      'max': 16.0,
    },
    {
      'label': '하루 평균 외출 횟수',
      'unit': '회',
      'lastWeek': 1.2,
      'thisWeek': 2.0,
      'max': 15.0,
    },
    {
      'label': '하루 평균 실내 활동량',
      'unit': '',
      'lastWeek': 2500.0,
      'thisWeek': 2000.0,
      'max': 4000.0,
    },
  ];

  WeeklyAnalysisChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5),
        ...data.map((entry) => _buildBarGroup(entry)),
      ],
    );
  }

  Widget _buildBarGroup(Map<String, dynamic> entry) {
    final label = entry['label'];
    final unit = entry['unit'];
    final lastWeek = entry['lastWeek'] as double;
    final thisWeek = entry['thisWeek'] as double;
    final max = entry['max'] as double;

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
              _buildBar(lastWeek, max, Colors.orange),
              const SizedBox(height: 3),
              _buildBar(thisWeek, max, Colors.deepPurple),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('지난주: ${lastWeek.toStringAsFixed(1)} $unit'),
              const SizedBox(width: 16),
              Text('이번주: ${thisWeek.toStringAsFixed(1)} $unit'),
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
