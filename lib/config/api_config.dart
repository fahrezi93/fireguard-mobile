/// Central API configuration for the FireGuard Flutter app.
/// Update [baseUrl] to point to your backend server (use 10.0.2.2 for Android emulator).
class ApiConfig {
  // Base URL — gunakan IP LAN PC untuk HP fisik, atau 10.0.2.2 untuk emulator.
  static const String baseUrl = 'http://192.168.100.6:3000';

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String loginVerify = '/api/auth/login/verify';
  static const String register = '/api/auth/register';
  static const String registerVerify = '/api/auth/register/verify';
  static const String passwordSetup = '/api/auth/password/setup';
  static const String passwordReset = '/api/auth/password/reset';
  static const String authMe = '/api/auth/me';
  static const String logout = '/api/auth/logout';

  // Profile
  static const String profile = '/api/auth/profile';

  // Reports
  static const String reports = '/api/reports';
  static const String myReports = '/api/reports/my-reports';

  // Notifications
  static const String notifications = '/api/notifications';

  // Master data
  static const String disasterCategories = '/api/disaster-categories';
  static const String kelurahan = '/api/kelurahan';
}
