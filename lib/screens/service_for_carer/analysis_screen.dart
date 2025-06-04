// lib/screens/service_for_carer/analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/models/care_target_name.dart';
import 'package:frontend/services/target_service.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/weekly_analysis_graph.dart';
import 'package:frontend/widgets/sleep_analysis_graph.dart';
import 'package:frontend/widgets/go_out_analysis_graph.dart';
import 'package:intl/intl.dart';
import 'package:frontend/screens/service_for_carer/home_screen.dart';
import 'package:frontend/screens/service_for_carer/care_manage_screen.dart'; // ← 돌봄 관리 화면 import

class CarerAnalysisScreen extends StatefulWidget {
  final int memberId;
  final String counselorName;

  const CarerAnalysisScreen({
    super.key,
    required this.memberId,
    required this.counselorName,
  });

  @override
  _CarerAnalysisScreenState createState() => _CarerAnalysisScreenState();
}

class _CarerAnalysisScreenState extends State<CarerAnalysisScreen> {
  final TargetService _targetService = TargetService.instance;

  List<CareTargetName> _targets = [];
  CareTargetName? _selectedTarget;
  DateTime _selectedDate = DateTime.now();
  int _selectedTabIndex = 0;
  int _currentIndex = 1; // “bar_chart 아이콘” 선택 시 이 화면

  @override
  void initState() {
    super.initState();
    _fetchTargetNames();
  }

  Future<void> _fetchTargetNames() async {
    try {
      final names = await _targetService.fetchTargetNames(widget.memberId);
      if (!mounted) return;
      setState(() {
        _targets = names;
      });
    } catch (e) {
      // 에러 처리 (스낵바 등)
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
      // “🏠” → 담당자 홈(목록) 화면으로 돌아간다
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CarerHomeScreen(
            memberId: widget.memberId,
            counselorName: widget.counselorName,
          ),
        ),
      );
      return;
    }
    if (idx == 1) {
      // 이미 분석 관리 화면이므로 인덱스만 변경
      setState(() => _currentIndex = 2);
      return;
    }
    if (idx == 2) {
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
    setState(() {
      _currentIndex = idx;
    });
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
            // ── “대상자 선택” 드롭다운 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  setState(() {
                    _selectedTarget = val;
                  });
                },
                value: _selectedTarget,
              ),
            ),

            // ── “날짜 선택” 영역 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

            // ── 탭 선택 ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton('주간 분석 레포트', 0),
                _buildTabButton('수면 분석', 1),
                _buildTabButton('외출 분석', 2),
              ],
            ),
            const SizedBox(height: 16),

            // ── 탭별 콘텐츠 ──
            if (_selectedTarget == null)
              const Text('대상자를 먼저 선택해주세요.')
            else
              _buildSelectedContent(),
          ],
        ),
      ),
    );
  }

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

  Widget _buildSelectedContent() {
    final userId = _selectedTarget!.userId;
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
