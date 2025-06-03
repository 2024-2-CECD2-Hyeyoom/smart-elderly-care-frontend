// lib/screens/service_for_carer/add_care_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/care_target_name.dart';
import 'package:frontend/services/target_service.dart';
import 'package:frontend/services/target_history_service.dart';
import 'package:frontend/screens/service_for_carer/home_screen.dart';
import 'package:frontend/widgets/custom_layout.dart';

class AddCareHistoryScreen extends StatefulWidget {
  final int memberId; // 로그인 후 전달받은 관리자(상담자) ID
  final String counselorName;

  const AddCareHistoryScreen({
    super.key,
    required this.memberId,
    required this.counselorName,
  });

  @override
  _AddCareHistoryScreenState createState() => _AddCareHistoryScreenState();
}

class _AddCareHistoryScreenState extends State<AddCareHistoryScreen> {
  // Services
  final TargetService _targetService = TargetService.instance;
  final TargetHistoryService _historyService = TargetHistoryService.instance;

  // Form state
  List<CareTargetName> _targetNames = [];
  CareTargetName? _selectedTarget;
  DateTime? _selectedDate;
  final _purposeController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  bool _saving = false;
  int _currentIndex = 2; // “돌봄 관리 추가” 화면은 idx = 2

  @override
  void initState() {
    super.initState();
    _fetchTargetNames();
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _fetchTargetNames() async {
    try {
      final names = await _targetService.fetchTargetNames(widget.memberId);
      if (!mounted) return;
      setState(() {
        _targetNames = names;
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveHistory() async {
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
      await _historyService.addHistory(
        userId: _selectedTarget!.userId,
        visitDate: _selectedDate!,
        purpose: _purposeController.text.trim(),
        content: _contentController.text.trim(),
        counselorId: widget.memberId,
      );
      if (!mounted) return;

      // 저장 성공 시 이전 화면으로 돌아가면서 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('돌봄 이력이 저장되었습니다.')),
      );
      Navigator.of(context).pop(); // CareManageScreen으로 돌아감
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// 하단바 클릭 처리
  void _onTapNavBar(int idx) {
    // idx == 0: 홈으로 돌아가기
    if (idx == 0) {
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
    // idx == 2: 이미 이 화면이므로 인덱스만 유지
    if (idx == 2) {
      setState(() => _currentIndex = 2);
      return;
    }
    // 그 외 idx (1,3) 인덱스만 변경
    setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '돌봄 이력 추가',
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
          // ───────── 1) 돌봄 대상자 선택 드롭다운 ─────────
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
          // ───────── 2) 방문일자 선택 ─────────
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
          // ───────── 3) 돌봄 목적 입력 ─────────
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
          // ───────── 4) 돌봄 내용 입력 ─────────
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
          // ───────── 5) 저장 버튼 ─────────
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveHistory,
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
