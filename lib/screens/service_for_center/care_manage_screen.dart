// lib/screens/service_for_center/care_manage_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/models/target_history.dart';
import 'package:frontend/services/target_history_service.dart';
import 'package:frontend/widgets/custom_layout.dart';
import 'package:frontend/widgets/target_history_card.dart';
import 'package:frontend/screens/service_for_center/home_screen.dart';
import 'package:frontend/screens/service_for_center/add_care_history_screen.dart';

class CareManageScreen extends StatefulWidget {
  final int memberId; // 로그인된 돌봄 담당자 ID
  final String counselorName; // 로그인된 돌봄 담당자 이름

  const CareManageScreen({
    super.key,
    required this.memberId,
    required this.counselorName,
  });

  @override
  _CareManageScreenState createState() => _CareManageScreenState();
}

class _CareManageScreenState extends State<CareManageScreen> {
  final TargetHistoryService _historyService = TargetHistoryService.instance;

  List<TargetHistory> _histories = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  int _currentIndex = 2; // 이 화면의 탭 인덱스(“🤚”) 고정

  @override
  void initState() {
    super.initState();
    _fetchHistories();
  }

  Future<void> _fetchHistories() async {
    try {
      final List<TargetHistory> list =
          await _historyService.fetchTargetHistories(widget.memberId);
      if (!mounted) return;
      setState(() {
        _histories = list;
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

  /// 하단바 탭 클릭 처리
  void _onTapNavBar(int idx) {
    if (idx == 0) {
      // “🏠” → 담당자 홈(목록) 화면으로 돌아간다
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
    if (idx == 2) {
      // 이미 돌봄 관리 화면이므로 인덱스만 변경
      setState(() => _currentIndex = 2);
      return;
    }
    setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return CustomLayout(
      title: '돌봄 관리',
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

    // 검색어 필터링
    final filtered = _histories.where((h) {
      return h.userName.contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        // ── 1) 상단 검색창 ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요.',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (tx) {
              setState(() {
                _searchQuery = tx.trim();
              });
            },
          ),
        ),

        // ── 2) 기록이 없을 때 ──
        if (filtered.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                '조회된 돌봄 이력이 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          // ── 3) 기록이 있을 때: 스크롤 리스트 ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final history = filtered[idx];
                return TargetHistoryCard(
                  history: history,
                  memberId: widget.memberId,
                  counselorName: widget.counselorName,
                );
              },
            ),
          ),

        // ── 4) 맨 아래 “돌봄 이력 추가” 버튼 ──
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ElevatedButton.icon(
            onPressed: () async {
              // “돌봄 이력 추가” 화면으로 이동
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddCareHistoryScreen(
                    memberId: widget.memberId,
                    counselorName: widget.counselorName,
                  ),
                ),
              );
              // '돌봄 이력 추가' 화면에서 돌아온 직 후 목록을 다시 불러옴
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              await _fetchHistories();
            },
            icon: const Icon(Icons.add),
            label: const Text('돌봄 이력 추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF305178),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
