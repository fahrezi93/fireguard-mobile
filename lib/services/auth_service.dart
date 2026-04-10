import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'dio_client.dart';

/// Extract human-readable error message from Dio or generic exceptions.
String extractDioError(dynamic e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.response?.statusCode != null) {
      return 'Server error (${e.response!.statusCode}). Coba lagi.';
    }
    return 'Tidak dapat terhubung ke server. Pastikan internet aktif.';
  }
  return e.toString().replaceFirst('Exception: ', '');
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioProvider));
});

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Login with email + password
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(ApiConfig.login, data: {
      'email': email,
      'password': password,
    });
    final data = response.data;

    // Save token from response body (Flutter mode)
    if (data['token'] != null) {
      await saveToken(data['token']);
    }

    return data;
  }



  /// Register new user
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await _dio.post(ApiConfig.register, data: {
      'name': name,
      'email': email,
      'password': password,
    });
    return response.data;
  }

  /// Verify registration OTP
  Future<Map<String, dynamic>> verifyRegisterOtp(
      String email, String otp, {String? name, String? password}) async {
    final response = await _dio.post(ApiConfig.registerVerify, data: {
      'email': email,
      'otp': otp,
      ...?name != null ? {'name': name} : null,
      ...?password != null ? {'password': password} : null,
    });
    final data = response.data;

    if (data['token'] != null) {
      await saveToken(data['token']);
    }

    return data;
  }

  /// Request Password Reset OTP
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _dio.post(ApiConfig.passwordReset, data: {
      'email': email,
    });
    return response.data;
  }

  /// Reset Password with OTP
  Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    final response = await _dio.put(ApiConfig.passwordReset, data: {
      'email': email,
      'otp': otp,
      'password': newPassword,
    });
    return response.data;
  }

  /// Get current user from server
  Future<User> getCurrentUser() async {
    final response = await _dio.get(ApiConfig.authMe);
    // /me returns JWT payload directly: {id, name, email, phone, isOperator}
    // Map 'phone' field -> 'phone_number' so User.fromJson works correctly
    final data = Map<String, dynamic>.from(response.data as Map);
    if (data['phone'] != null && data['phone_number'] == null) {
      data['phone_number'] = data['phone'];
    }
    return User.fromJson(data);
  }

  /// Logout - clear stored token
  Future<void> logout() async {
    try {
      await _dio.post(ApiConfig.logout);
    } catch (_) {}
    await clearToken();
  }

  /// Check if user has stored token
  Future<bool> hasToken() async {
    final token = await getStoredToken();
    return token != null;
  }
}
