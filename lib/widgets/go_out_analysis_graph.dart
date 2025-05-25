import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GoOutAnalysisGraph extends StatelessWidget {
  final List<double> thisWeekGoOutTime = [6.5, 7.0, 5.8, 6.2, 6.7, 5.5, 6.9];
  final double lastWeekAverageTime = 6.0;

  final DateTime selectedDate;

  GoOutAnalysisGraph({super.key, required this.selectedDate});

  List<String> get days {
    // 선택한 날짜 기준으로 7일 전부터 오늘까지 날짜 문자열 리스트 생성
    return List.generate(7, (i) {
      final date = selectedDate.subtract(Duration(days: 6 - i));
      return DateFormat('d').format(date); // '19', '20'처럼 일만 표시
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 16, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.door_back_door, size: 20),
              SizedBox(width: 8),
              Text('외출 횟수 : 3 회',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 20),
                SizedBox(width: 8),
                Text('총 외출 시간 : 8시간 00분',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 13),
            child: Text('시간', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black.withValues(alpha: 0.75),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)} 시간',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: _buildBarGroups(),
                maxY: 16,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.3),
                    strokeWidth: 1,
                    dashArray: [4, 2],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 2,
                      getTitlesWidget: (value, _) {
                        if (value % 2 == 0) {
                          return Text('${value.toInt()}',
                              style: const TextStyle(fontSize: 10));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(days[value.toInt()],
                              style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: lastWeekAverageTime,
                      color: Colors.orange,
                      strokeWidth: 2,
                      dashArray: [4, 2],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Center(
            child: Text(
              '일 (날짜)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(thisWeekGoOutTime.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: thisWeekGoOutTime[i],
            color: Colors.deepPurple,
            width: 18,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }
}
