// lib/widgets/sleep_analysis_graph.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/sleep_analysis.dart';
import 'package:frontend/services/analysis_service.dart';

/// 수면 분석 레포트 위젯
class SleepAnalysisGraph extends StatelessWidget {
  final int userId;
  final DateTime selectedDate;

  const SleepAnalysisGraph({
    super.key,
    required this.userId,
    required this.selectedDate,
  });

  Future<SleepAnalysis> _fetchSleepAnalysis() async {
    final toStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final fromDate = selectedDate.subtract(const Duration(days: 6));
    final fromStr = DateFormat('yyyy-MM-dd').format(fromDate);

    return await AnalysisService.instance.fetchSleepAnalysis(
      userId: userId,
      to: toStr,
      from: fromStr,
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
    return FutureBuilder<SleepAnalysis>(
      future: _fetchSleepAnalysis(),
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
            child: Text(
              '데이터를 불러올 수 없습니다.\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        final data = snapshot.data!;
        final days = _generateDays(selectedDate);

        // “하루 총 수면 시간”을 계산하려면, sleepStartTime/ sleepEndTime 문자열을 DateTime.parse해서
        // 차이를 구해야 합니다.
        String dailyTotalSleep() {
          if (data.sleepStartTime == null || data.sleepEndTime == null) {
            return '-';
          }
          final start = DateTime.parse(data.sleepStartTime!);
          final end = DateTime.parse(data.sleepEndTime!);
          final diff = end.difference(start);
          final hh = diff.inHours;
          final mm = diff.inMinutes % 60;
          return '$hh시간 ${mm.toString().padLeft(2, '0')}분';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1) “취침시각”, “기상시각”
              _buildRow(Icons.nightlight_round,
                  '취침시각 : ${data.sleepStartTime ?? '-'}'),
              const SizedBox(height: 8),
              _buildRow(Icons.wb_sunny, '기상시각 : ${data.sleepEndTime ?? '-'}'),
              const SizedBox(height: 8),

              // 2) “평균 수면 시간” ⇐ API가 준 averageCurrent (ex: 7.2 시간)
              _buildRow(Icons.access_time,
                  '평균 수면 시간 : ${data.averageCurrent.toStringAsFixed(1)}시간'),

              const SizedBox(height: 15),

              const Padding(
                padding: EdgeInsets.only(bottom: 13),
                child: Text('일별 수면 시간 (단위: 시간)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),

              // 3) BarChart: data.dataCurrent (List<double>)
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.black.withOpacity(0.75),
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
                    barGroups: _buildBarGroups(data.dataCurrent),
                    maxY: data.dataCurrent.isNotEmpty
                        ? (data.dataCurrent.reduce((a, b) => a > b ? a : b) + 2)
                        : 10.0,
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 2,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.3),
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
                            final idx = value.toInt();
                            if (idx >= 0 && idx < days.length) {
                              return Text(days[idx],
                                  style: const TextStyle(fontSize: 10));
                            }
                            return const SizedBox.shrink();
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
                          y: data.averageCurrent,
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
        Expanded(
          child: Text(text,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
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
