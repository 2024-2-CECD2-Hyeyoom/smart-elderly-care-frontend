// lib/services/welfare_center_service.dart

import 'dart:convert';
import 'package:frontend/models/welfare_center.dart';
import 'package:frontend/models/welfare_centers_response.dart';
import 'package:frontend/services/api_client.dart';

class WelfareCenterService {
  /// 전체 복지센터 조회
  Future<List<WelfareCenter>> fetchAll() async {
    final resp = await ApiClient.instance.get('/member/welfare_centers');
    if (resp.statusCode != 200) {
      throw Exception('전체 복지센터 조회 실패(${resp.statusCode})');
    }
    final dto = WelfareCentersResponse.fromJson(jsonDecode(resp.body));
    if (!dto.isSuccess) {
      throw Exception('API 오류: ${dto.message}');
    }
    return dto.result;
  }

  /// 시·도 기준 조회
  Future<List<WelfareCenter>> fetchBySido(String sido) async {
    final resp = await ApiClient.instance.get(
      '/member/welfare_centers/sido',
      queryParameters: {'sido': sido},
    );
    if (resp.statusCode != 200) {
      throw Exception('시도별 조회 실패(${resp.statusCode})');
    }
    final dto = WelfareCentersResponse.fromJson(jsonDecode(resp.body));
    if (!dto.isSuccess) {
      throw Exception('API 오류: ${dto.message}');
    }
    return dto.result;
  }

  /// 시·도 + 시·군구 기준 조회
  Future<List<WelfareCenter>> fetchBySidoSigungu(
      String sido, String sigungu) async {
    final resp = await ApiClient.instance.get(
      '/member/welfare_centers/sido-sigungu',
      queryParameters: {
        'sido': sido,
        'sigungu': sigungu,
      },
    );
    if (resp.statusCode != 200) {
      throw Exception('시군구별 조회 실패(${resp.statusCode})');
    }
    final dto = WelfareCentersResponse.fromJson(jsonDecode(resp.body));
    if (!dto.isSuccess) {
      throw Exception('API 오류: ${dto.message}');
    }
    return dto.result;
  }
}
