import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

const _storage = FlutterSecureStorage();
const _tokenKey = 'auth_token';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (error, handler) {
      // 401 will be handled by individual services
      return handler.next(error);
    },
  ));

  return dio;
});

// Token management
Future<void> saveToken(String token) async {
  await _storage.write(key: _tokenKey, value: token);
}

Future<String?> getStoredToken() async {
  return await _storage.read(key: _tokenKey);
}

Future<void> clearToken() async {
  await _storage.delete(key: _tokenKey);
}
