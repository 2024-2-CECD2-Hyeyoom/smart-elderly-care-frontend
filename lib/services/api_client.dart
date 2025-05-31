// lib/services/api_client.dart
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

class ApiClient {
  static const _baseUrl = 'http://localhost:8080';
  final http.Client _inner = http.Client();
  ApiClient._();
  static final instance = ApiClient._();

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final token = await SecureStorageService.readToken();
    final allHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters,
    );
    return _inner.get(uri, headers: allHeaders);
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final token = await SecureStorageService.readToken();
    final allHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters,
    );
    return _inner.post(uri, headers: allHeaders, body: body);
  }
}
