// lib/screens/service_for_center/edit_care_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/care_target_name.dart';
import 'package:frontend/models/target_history.dart';
import 'package:frontend/services/target_service.dart';
import 'package:frontend/services/target_history_service.dart';
import 'package:frontend/screens/service_for_carer/home_screen.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/screens/service_for_center/analysis_screen.dart';
import 'package:frontend/screens/service_for_center/my_page.dart';

class EditCareHistoryScreen extends StatefulWidget {
  final int memberId; // 로그인된 돌봄 담당자(ID)
  final String counselorName; // 로그인된 돌봄 담당자 이름
  final TargetHistory history; // 수정할 이력 객체 (서버에서 가져온 것)

  const EditCareHistoryScreen({
    super.key,
    required this.memberId,
    required this.counselorName,
    required this.history,
  });

  @override
  _EditCareHistoryScreenState createState() => _EditCareHistoryScreenState();
}

class _EditCareHistoryScreenState extends State<EditCareHistoryScreen> {
  // Service 인스턴스
  final TargetService _targetService = TargetService.instance;
  final TargetHistoryService _historyService = TargetHistoryService.instance;

  // 폼 상태
  List<CareTargetName> _targetNames = [];
  CareTargetName? _selectedTarget;
  DateTime? _selectedDate;
  late TextEditingController _purposeController;
  late TextEditingController _contentController;

  bool _isLoading = true;
  String? _errorMessage;
  bool _saving = false;
  int _currentIndex = 2; // 이 화면의 하단바 인덱스(“🤚”)

  @override
  void initState() {
    super.initState();
    _purposeController = TextEditingController(text: widget.history.purpose);
    _contentController = TextEditingController(text: widget.history.content);
    _selectedDate = widget.history.visitDate;
    _fetchTargetNamesAndInit();
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 대상자 목록을 가져온 뒤, widget.history.userId에 해당하는 요소를 미리 선택 상태로 둡니다.
  Future<void> _fetchTargetNamesAndInit() async {
    try {
      final names = await _targetService.fetchTargetNames(widget.memberId);
      if (!mounted) return;

      // 수정하려는 이력(history.userId)에 해당하는 CareTargetName을 찾아서 _selectedTarget으로 설정
      CareTargetName? preselect;
      for (var t in names) {
        if (t.userId == widget.history.userId) {
          preselect = t;
          break;
        }
      }

      setState(() {
        _targetNames = names;
        _selectedTarget = preselect;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 날짜 선택 다이얼로그
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 저장(수정) 버튼 클릭 시 호출
  Future<void> _saveEditedHistory() async {
    // 유효성 검사
    if (_selectedTarget == null ||
        _selectedDate == null ||
        _purposeController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 정보를 입력해주세요.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _historyService.updateHistory(
        careHistoryId: widget.history.careHistoryId,
        userId: _selectedTarget!.userId,
        visitDate: _selectedDate!,
        purpose: _purposeController.text.trim(),
        content: _contentController.text.trim(),
        counselorId: widget.memberId,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('돌봄 이력이 수정되었습니다.')),
      );
      Navigator.of(context).pop(); // CareManageScreen으로 돌아감
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정 실패: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// 하단바 탭 클릭 처리
  void _onTapNavBar(int idx) {
    if (idx == 0) {
      // “🏠” → CarerHomeScreen으로 돌아가기
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
      // 분석 화면으로 돌아간다
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CenterAnalysisScreen(
            memberId: widget.memberId,
            counselorName: widget.counselorName,
          ),
        ),
      );
      return;
    }
    if (idx == 2) {
      // 이미 이 화면이므로 인덱스만 유지
      setState(() => _currentIndex = 2);
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
      title: '돌봄 이력 수정',
      showLogoutButton: true,
      currentIndex: _currentIndex,
      onTap: _onTapNavBar,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1) 돌봄 대상자 선택 드롭다운 (수정 전 기존 값 미리 선택) ──
          const Text(
            '돌봄 대상자 선택',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CareTargetName>(
                isExpanded: true,
                hint: const Text('선택해주세요'),
                value: _selectedTarget,
                items: _targetNames.map((t) {
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
              ),
            ),
          ),

          const SizedBox(height: 16),
          // ── 2) 방문일자 선택 (기존 날짜 미리 표시) ──
          const Text(
            '방문일자',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _selectedDate == null
                        ? '방문일을 선택하세요'
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate == null
                          ? Colors.grey.shade600
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          // ── 3) 돌봄 목적 입력 (기존 목적 미리 채워짐) ──
          const Text(
            '돌봄 목적',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _purposeController,
            decoration: InputDecoration(
              hintText: '돌봄 목적을 입력하세요.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 16),
          // ── 4) 돌봄 내용 입력 (기존 내용 미리 채워짐) ──
          const Text(
            '돌봄 내용',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '돌봄 내용을 입력하세요.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 24),
          // ── 5) 저장(수정) 버튼 ──
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveEditedHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF305178),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _saving
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  '저장',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}