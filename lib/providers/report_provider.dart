import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../services/report_service.dart';

/// Provider for user's reports list
final myReportsProvider =
    AsyncNotifierProvider<MyReportsNotifier, List<Report>>(
        MyReportsNotifier.new);

class MyReportsNotifier extends AsyncNotifier<List<Report>> {
  @override
  Future<List<Report>> build() async {
    final reportService = ref.read(reportServiceProvider);
    return await reportService.getMyReports();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final reportService = ref.read(reportServiceProvider);
      return await reportService.getMyReports();
    });
  }
}

/// Provider for report stats
final reportStatsProvider = Provider<Map<String, int>>((ref) {
  final reportsAsync = ref.watch(myReportsProvider);
  return reportsAsync.whenData((reports) {
    return {
      'total': reports.length,
      'pending': reports.where((r) => r.status == 'pending').length,
      'completed': reports.where((r) => r.status == 'completed').length,
      'active': reports
          .where((r) => !['completed', 'false_report'].contains(r.status))
          .length,
    };
  }).value ?? {'total': 0, 'pending': 0, 'completed': 0, 'active': 0};
});
