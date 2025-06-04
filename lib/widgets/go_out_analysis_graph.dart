// lib/widgets/go_out_analysis_graph.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/outing_analysis.dart';
import 'package:frontend/services/analysis_service.dart';

/// 외출 분석 레포트 위젯
class GoOutAnalysisGraph extends StatelessWidget {
  final int userId;
  final DateTime selectedDate;

  const GoOutAnalysisGraph({
    super.key,
    required this.userId,
    required this.selectedDate,
  });

  /// API 호출: 서버에서 외출 분석 데이터를 받아옵니다.
  Future<OutingAnalysis> _fetchOutingAnalysis() async {
    final toStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    // from 을 선택하지 않았을 때는 “서버가 알아서 to 기준으로 7일 전부터 지난주까지”를 처리해 주지만,
    // 여기서는 명시적으로 7일 전부터 조회하기로 예시를 들었습니다.
    final fromDate = selectedDate.subtract(const Duration(days: 6));
    final fromStr = DateFormat('yyyy-MM-dd').format(fromDate);

    return await AnalysisService.instance.fetchOutingAnalysis(
      userId: userId,
      to: toStr,
      from: fromStr,
    );
  }

  /// x축 레이블(날짜) 생성: “1, 2, 3, …, 7” 꼴로 반환
  List<String> _generateDays(DateTime date) {
    return List.generate(7, (i) {
      final d = date.subtract(Duration(days: 6 - i));
      return DateFormat('d').format(d);
    });
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
        // “selectedDate”를 기준으로 7일치 레이블 생성
        final displayDays = _generateDays(selectedDate);

        // “선택 날짜(=selectedDate)에 해당하는 하루 외출 횟수”를 가져오려면
        // data.labels 과 data.dataCurrent 의 순서가 동일하다고 가정할 때, selectedDate가
        // 항상 data.period.currentWeek.to ~ from 범위 안에 있다고 보면,
        // data.dataCurrent 의 마지막 인덱스(6)가 오늘의 외출 횟수입니다.
        final todayCount =
            data.dataCurrent.isNotEmpty ? data.dataCurrent.last : 0;

        // “이번 주 평균 외출 횟수”를 보여 주려면
        final averageCount = data.averageCurrent;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1) 오늘 하루(선택일)의 외출 횟수
              _buildRow(Icons.door_back_door, '외출 횟수 : $todayCount 회'),

              const SizedBox(height: 8),

              // 2) 선택 날짜의 총 외출 시간 (server가 보내준 분 단위)
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

              // 3) BarChart (7일치 막대 그래프)
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
