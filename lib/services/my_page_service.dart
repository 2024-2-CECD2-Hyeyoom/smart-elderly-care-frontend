// lib/services/my_page_service.dart

import 'dart:convert';
import 'package:frontend/models/my_page_data.dart';
import 'package:frontend/services/api_client.dart';

class MyPageService {
  MyPageService._();
  static final MyPageService instance = MyPageService._();

  /// GET /member/mypage/user/{userId}
  Future<MyPageData> fetchMyPage(int userId) async {
    final resp = await ApiClient.instance.get(
      '/member/mypage/user/$userId',
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw Exception('마이페이지 정보 조회 실패 (${resp.statusCode})');
    }
    final Map<String, dynamic> jsonBody = jsonDecode(resp.body);
    if (jsonBody['isSuccess'] != true) {
      throw Exception('API 오류: ${jsonBody['message']}');
    }
    final result = jsonBody['result'] as Map<String, dynamic>;
    return MyPageData.fromJson(result);
  }

  // (추가) 예: “아이디 수정” 같은 PUT/POST 엔드포인트가 있다면 여기에 메서드를 더 정의할 수 있습니다.
}
