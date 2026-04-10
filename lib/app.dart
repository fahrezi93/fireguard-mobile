import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/main_shell.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/report/new_report_screen.dart';
import 'screens/notification/notification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/report/report_detail_screen.dart';
import 'screens/profile/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, _) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/report/new',
            builder: (context, state) => NewReportScreen(
              initialCategory: state.uri.queryParameters['category'],
            ),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, _) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, _) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/report/:id',
        builder: (context, state) => ReportDetailScreen(
          reportId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, _) => const SettingsScreen(),
      ),
    ],
  );
});

class FireGuardApp extends ConsumerWidget {
  const FireGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FireGuard',
      theme: FGTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
