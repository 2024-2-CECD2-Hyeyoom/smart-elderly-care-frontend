import 'package:flutter/material.dart';
import 'package:frontend/models/weekly_analysis.dart';
import 'package:frontend/services/analysis_service.dart';
import 'package:intl/intl.dart';

class WeeklyAnalysisChart extends StatelessWidget {
  final int userId;
  final DateTime selectedDate; // to 날짜

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

  /// 서버가 준 기간(period.currentWeek)을 기준으로 "일"을 문자열 ["1", "2", ...] 꼴로 뽑아주는 헬퍼
  List<String> _generateDaysFromPeriod(DateTime from, DateTime to) {
    final days = <String>[];
    for (var dt = from; !dt.isAfter(to); dt = dt.add(const Duration(days: 1))) {
      days.add(DateFormat('d').format(dt));
    }
    return days;
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
            child: Text(
              '데이터를 불러올 수 없습니다.\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        final data = snapshot.data!;
        // 서버가 준 이번 주 범위(from~to)를 DateTime으로 꺼냅니다.
        final fromDt = data.period.currentWeek.fromDate();
        final toDt = data.period.currentWeek.toDate();

        // 실제 레이블(“1”, “2”, … “7” 등)을 fromDt~toDt로 생성
        final displayDays = _generateDaysFromPeriod(fromDt, toDt);

        return Column(
          children: [
            const SizedBox(height: 5),
            // 라벨 수만큼 막대 그래프를 그리는데, 레이블은 displayDays를 통해 찍습니다.
            ...List.generate(data.labels.length, (index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.labels[index],
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // 지난주, 이번주 막대를 _buildBarGroup을 통해 그립니다.
                        _buildBarGroup(
                          label: data.labels[index],
                          lastWeekValue: data.dataPrevious[index],
                          thisWeekValue: data.dataCurrent[index],
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            // (아래에 ‘지난주: xx, 이번주: yy’ 등의 요약용 텍스트를 추가해도 좋습니다.)
          ],
        );
      },
    );
  }

  Widget _buildBarGroup({
    required String label,
    required double lastWeekValue,
    required double thisWeekValue,
    required double maxWidth,
  }) {
    double maxValue;
    if (label.contains('수면')) {
      maxValue = 16.0;
    } else if (label.contains('외출')) {
      maxValue = 15.0;
    } else if (label.contains('실내')) {
      maxValue = 4000.0;
    } else if (label.contains('온도') || label.contains('습도')) {
      maxValue = 50.0;
    } else {
      maxValue = 100.0;
    }

    // 막대 생성
    final lastRatio = (lastWeekValue / maxValue).clamp(0.0, 1.0);
    final thisRatio = (thisWeekValue / maxValue).clamp(0.0, 1.0);
    final lastWidth = lastRatio * maxWidth;
    final thisWidth = thisRatio * maxWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 13,
          width: lastWidth,
          decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          height: 13,
          width: thisWidth,
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
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
    );
  }
}
