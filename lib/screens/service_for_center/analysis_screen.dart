// lib/screens/service_for_center/analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/models/care_target_name.dart';
import 'package:frontend/models/care_target.dart';
import 'package:frontend/services/target_service.dart';
import 'package:frontend/services/care_service.dart';
import 'package:frontend/widgets/target_card.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/weekly_analysis_graph.dart';
import 'package:frontend/widgets/sleep_analysis_graph.dart';
import 'package:frontend/widgets/go_out_analysis_graph.dart';
import 'package:intl/intl.dart';
import 'package:frontend/screens/service_for_center/home_screen.dart';
import 'package:frontend/screens/service_for_center/care_manage_screen.dart';
import 'package:frontend/screens/service_for_center/my_page.dart';

class CenterAnalysisScreen extends StatefulWidget {
  final int memberId;
  final String counselorName;

  const CenterAnalysisScreen({
    super.key,
    required this.memberId,
    required this.counselorName,
  });

  @override
  _CenterAnalysisScreenState createState() => _CenterAnalysisScreenState();
}

class _CenterAnalysisScreenState extends State<CenterAnalysisScreen> {
  final TargetService _targetService = TargetService.instance;
  final CareService _careService = CareService.instance;

  // 1) 드롭다운에 쓰일 간단한 이름 리스트
  List<CareTargetName> _targets = [];
  // 2) 선택된 CareTargetName
  CareTargetName? _selectedTargetName;

  // 3) 위에 카드로 보여줄 풀 정보 리스트
  List<CareTarget> _fullTargets = [];
  // 4) 선택된 대상자(CareTargetName.userId와 매칭되는 CareTarget)를 구할 변수
  CareTarget? _selectedCareTarget;

  DateTime _selectedDate = DateTime.now();
  int _selectedTabIndex = 0;
  int _currentIndex = 1; // “bar_chart 아이콘” 선택 시 이 화면

  @override
  void initState() {
    super.initState();
    _fetchAllTargets();
  }

  /// 대상자 이름 목록과, 대상자 풀정보(CareTarget)를 동시에 가져오기
  Future<void> _fetchAllTargets() async {
    try {
      // 1) 이름 목록
      final names = await _targetService.fetchTargetNames(widget.memberId);
      // 2) 풀정보(CareTarget)
      final fullList = await _careService.fetchTargets(widget.memberId);

      if (!mounted) return;
      setState(() {
        _targets = names;
        _fullTargets = fullList;

        // “첫 번째”가 있으면 자동 선택
        if (_targets.isNotEmpty) {
          _selectedTargetName = _targets.first;

          // CareTargetName.userId에 해당하는 CareTarget을 찾아서 저장
          _selectedCareTarget = _fullTargets.firstWhere(
            (ct) => ct.userId == _selectedTargetName!.userId,
            orElse: () => _fullTargets[0],
          );
        }
      });
    } catch (e) {
      // 여기서 간단히 Print 혹은 SnackBar 처리
      debugPrint('대상자 조회 중 오류: $e');
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ko'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 48, 81, 120),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onTapNavBar(int idx) {
    if (idx == 0) {
      // “🏠” → 관리자 홈(대상자 목록)으로 돌아가기
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CenterHomeScreen(
            memberId: widget.memberId,
            counselorName: widget.counselorName,
          ),
        ),
      );
      return;
    }
    if (idx == 1) {
      // 이미 “분석 레포트” 화면이므로 인덱스만 변경
      setState(() => _currentIndex = 1);
      return;
    }
    if (idx == 2) {
      // “🤚” → 돌봄 관리 화면으로
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CareManageScreen(
            memberId: widget.memberId,
            counselorName: widget.counselorName,
          ),
        ),
      );
      return;
    }
    if (idx == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CenterMyPageScreen(
            memberId: widget.memberId,
            counselorName: widget.counselorName,
          ),
        ),
      );
      return;
    }
    setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '분석 레포트',
      showLogoutButton: true,
      currentIndex: _currentIndex,
      onTap: _onTapNavBar,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ───────────────────────────────────────────
            // 1) “대상자 카드” (선택된 노인 정보가 있으면 보여줌)
            if (_selectedCareTarget != null) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TargetCard(
                  name: _selectedCareTarget!.name,
                  address: _selectedCareTarget!.address,
                  center: _selectedCareTarget!.welfareCenterName,
                  contact: _selectedCareTarget!.phoneNumber,
                  isDanger: _selectedCareTarget!.isDanger,
                  isAbsent: false,
                ),
              ),
            ],

            // ───────────────────────────────────────────
            // 2) “분석 대상자 선택” 드롭다운
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<CareTargetName>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: '분석 대상자 선택',
                ),
                items: _targets.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.name),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _selectedTargetName = val;
                    // 선택된 userId와 일치하는 풀정보(CareTarget)를 찾아서 갱신
                    _selectedCareTarget = _fullTargets.firstWhere(
                      (ct) => ct.userId == val.userId,
                      orElse: () => _fullTargets.first,
                    );
                  });
                },
                value: _selectedTargetName,
              ),
            ),

            // ───────────────────────────────────────────
            // 3) “날짜 선택” 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: InkWell(
                onTap: _pickDate,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 25),
                    const SizedBox(width: 8),
                    Text(
                      '선택된 날짜: ${DateFormat('yyyy년 MM월 dd일').format(_selectedDate)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ───────────────────────────────────────────
            // 4) 탭 선택 (주간 / 수면 / 외출)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton('주간 분석 레포트', 0),
                _buildTabButton('수면 분석', 1),
                _buildTabButton('외출 분석', 2),
              ],
            ),
            const SizedBox(height: 16),

            // ───────────────────────────────────────────
            // 5) 탭별 콘텐츠
            if (_selectedCareTarget == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('대상자를 먼저 선택해주세요.'),
              )
            else
              _buildSelectedContent(),
          ],
        ),
      ),
    );
  }

  /// 탭 버튼 (밑줄 스타일) 위젯
  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.only(bottom: 4),
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
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  /// 선택된 대상자 ID를 넘겨서 각 차트 위젯을 반환
  Widget _buildSelectedContent() {
    final userId = _selectedTargetName!.userId;

    switch (_selectedTabIndex) {
      case 0:
        return WeeklyAnalysisChart(
          userId: userId,
          selectedDate: _selectedDate,
        );
      case 1:
        return SleepAnalysisGraph(
          userId: userId,
          selectedDate: _selectedDate,
        );
      case 2:
        return GoOutAnalysisGraph(
          userId: userId,
          selectedDate: _selectedDate,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
