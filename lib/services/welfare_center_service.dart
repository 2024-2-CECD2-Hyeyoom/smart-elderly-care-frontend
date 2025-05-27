// lib/services/welfare_center_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/welfare_centers_response.dart';
import 'package:frontend/models/welfare_center.dart';

class WelfareCenterService {
  static const _baseUrl = 'http://localhost:8080';

  /// 전체 복지센터 조회
  Future<List<WelfareCenter>> fetchAll() async {
    final uri = Uri.parse('$_baseUrl/member/welfare_centers');
    final res =
        await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Failed to load welfare centers: ${res.statusCode}');
    }
    final dto = WelfareCentersResponse.fromJson(jsonDecode(res.body));
    if (!dto.isSuccess) {
      throw Exception('API error: ${dto.message}');
    }
    return dto.result;
  }

  /// 시·도 기준 조회
  Future<List<WelfareCenter>> fetchBySido(String sido) async {
    final uri = Uri.parse('$_baseUrl/member/welfare_centers/sido')
        .replace(queryParameters: {'sido': sido});
    final res =
        await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Failed to load by sido');
    }
    final dto = WelfareCentersResponse.fromJson(jsonDecode(res.body));
    if (!dto.isSuccess) {
      throw Exception('API error: ${dto.message}');
    }
    return dto.result;
  }

  /// 시·도 + 시·군구 기준 조회
  Future<List<WelfareCenter>> fetchBySidoSigungu(
      String sido, String sigungu) async {
    final uri = Uri.parse('$_baseUrl/member/welfare_centers/sido-sigungu')
        .replace(queryParameters: {'sido': sido, 'sigungu': sigungu});
    final res =
        await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Failed to load by sido-sigungu');
    }
    final dto = WelfareCentersResponse.fromJson(jsonDecode(res.body));
    if (!dto.isSuccess) {
      throw Exception('API error: ${dto.message}');
    }
    return dto.result;
  }
}
