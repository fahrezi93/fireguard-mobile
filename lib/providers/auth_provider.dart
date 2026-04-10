import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/dio_client.dart';

/// Auth state: null = not logged in, User = logged in
final userProvider =
    AsyncNotifierProvider<UserNotifier, User?>(UserNotifier.new);

class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // Check stored token on app launch
    final authService = ref.read(authServiceProvider);
    final hasToken = await authService.hasToken();
    if (!hasToken) return null;

    try {
      return await authService.getCurrentUser();
    } catch (_) {
      await clearToken();
      return null;
    }
  }

  /// Login with password
  Future<Map<String, dynamic>> login(String email, String password) async {
    final authService = ref.read(authServiceProvider);
    final result = await authService.login(email, password);

    // Refresh user state
    final user = await authService.getCurrentUser();
    state = AsyncData(user);

    return result;
  }



  /// Set user after password setup
  Future<void> refreshUser() async {
    final authService = ref.read(authServiceProvider);
    try {
      final user = await authService.getCurrentUser();
      state = AsyncData(user);
    } catch (e) {
      state = AsyncData(null);
    }
  }

  /// Logout
  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = const AsyncData(null);
  }
}

/// Quick check: is user logged in?
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).valueOrNull != null;
});
