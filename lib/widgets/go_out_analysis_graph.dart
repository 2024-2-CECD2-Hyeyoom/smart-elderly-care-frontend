import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/outing_analysis.dart';
import 'package:frontend/services/analysis_service.dart';

/// 외출 분석 레포트 위젯
class GoOutAnalysisGraph extends StatelessWidget {
  final int userId;
  final DateTime selectedDate; // to 날짜

  const GoOutAnalysisGraph({
    super.key,
    required this.userId,
    required this.selectedDate,
  });

  Future<OutingAnalysis> _fetchOutingAnalysis() async {
    final toStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final fromDate = selectedDate.subtract(const Duration(days: 6));
    final fromStr = DateFormat('yyyy-MM-dd').format(fromDate);

    return await AnalysisService.instance.fetchOutingAnalysis(
      userId: userId,
      to: toStr,
      from: fromStr,
    );
  }

  /// 서버가 준 이번 주 범위를 DateTime으로 받아와서 7일치 날짜 리스트(“1”, “2”, …)로 변환
  List<String> _generateDaysFromPeriod(DateTime from, DateTime to) {
    final days = <String>[];
    for (var dt = from; !dt.isAfter(to); dt = dt.add(const Duration(days: 1))) {
      days.add(DateFormat('d').format(dt));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OutingAnalysis>(
      future: _fetchOutingAnalysis(),
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
        // 서버가 준 기간을 DateTime으로 꺼냅니다.
        final fromDt = data.period.currentWeek.fromDate();
        final toDt = data.period.currentWeek.toDate();

        // 실제 레이블(“1”, “2”, …, “7”) 생성
        final displayDays = _generateDaysFromPeriod(fromDt, toDt);

        // “오늘” 외출 횟수는 data.dataCurrent.last(마지막 인덱스)라고 가정
        final todayCount =
            data.dataCurrent.isNotEmpty ? data.dataCurrent.last : 0;
        // 평균 외출 횟수
        final averageCount = data.averageCurrent;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow(Icons.door_back_door, '외출 횟수 : $todayCount 회'),
              const SizedBox(height: 8),
              _buildRow(
                Icons.access_time,
                '총 외출 시간 : ${data.outingDurationMinutes ?? 0} 분',
              ),

              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.only(bottom: 13),
                child: Text(
                  '일별 외출 횟수',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // BarChart: data.dataCurrent (List<int>)
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
                            '${rod.toY.toInt()}회',
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
                        ? (data.dataCurrent.reduce((a, b) => a > b ? a : b) + 5)
                            .toDouble()
                        : 10.0,
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 5,
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
                          interval: 5,
                          getTitlesWidget: (value, _) {
                            if (value % 5 == 0) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              );
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
                            if (idx >= 0 && idx < displayDays.length) {
                              return Text(
                                displayDays[idx],
                                style: const TextStyle(fontSize: 10),
                              );
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
                          y: averageCount,
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

  List<BarChartGroupData> _buildBarGroups(List<int> values) {
    return List.generate(values.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i].toDouble(),
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
