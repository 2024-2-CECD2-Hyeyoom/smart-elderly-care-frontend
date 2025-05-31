// lib/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  /// 토큰 저장
  static Future<void> writeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// 토큰 읽기
  static Future<String?> readToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// 토큰 삭제
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
