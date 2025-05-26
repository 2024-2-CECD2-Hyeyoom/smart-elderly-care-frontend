import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/go_out_analysis_data.dart';

// 외출 분석 레포트 위젯

class GoOutAnalysisGraph extends StatelessWidget {
  final DateTime selectedDate;

  const GoOutAnalysisGraph({super.key, required this.selectedDate});

  Future<GoOutAnalysisData> fetchGoOutData(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return GoOutAnalysisData(
      selectedDate: date,
      totalGoOutCount: 3,
      totalGoOutTime: '8시간 00분',
      lastWeekAverageTime: 6.0,
      thisWeekTime: [6.5, 7.0, 5.8, 6.2, 6.7, 5.5, 6.9],
    );
  }

  List<String> _generateDays(DateTime date) {
    return List.generate(7, (i) {
      final d = date.subtract(Duration(days: 6 - i));
      return DateFormat('d').format(d);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GoOutAnalysisData>(
      future: fetchGoOutData(selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 48, 81, 120)));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('데이터를 불러올 수 없습니다.'));
        }

        final data = snapshot.data!;
        final days = _generateDays(data.selectedDate);

        return Padding(
          padding: const EdgeInsets.only(right: 16, left: 16, bottom: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow(
                  Icons.door_back_door, '외출 횟수 : ${data.totalGoOutCount} 회'),
              const SizedBox(height: 8),
              _buildRow(Icons.access_time, '총 외출 시간 : ${data.totalGoOutTime}'),
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.only(bottom: 13),
                child:
                    Text('시간', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    barGroups: _buildBarGroups(data.thisWeekTime),
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
                            if (value.toInt() >= 0 &&
                                value.toInt() < days.length) {
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
                          y: data.lastWeekAverageTime,
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
      },
    );
  }

  Widget _buildRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<double> values) {
    return List.generate(values.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i],
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
