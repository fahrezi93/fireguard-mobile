import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../models/notification_model.dart';
import '../../services/dio_client.dart';

/// Provider for notifications
final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(ApiConfig.notifications);
  final data = response.data;
  final List list = data['data'] ?? [];
  return list.map((n) => NotificationModel.fromJson(n)).toList();
});

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: FGColors.bg,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => _markAllRead(ref),
            style: TextButton.styleFrom(
              foregroundColor: FGColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Tandai Dibaca',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: FGColors.primary,
        onRefresh: () async => ref.invalidate(notificationsProvider),
        child: notifAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_off_outlined,
                              size: 40, color: FGColors.textTertiary),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum Ada Notifikasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: FGColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pesan dan peringatan baru akan muncul di sini',
                          style: TextStyle(fontSize: 13, color: FGColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (context, i) => Container(
                height: 1,
                color: FGColors.border.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, i) {
                final notif = notifications[i];
                return _NotificationTile(
                  notification: notif,
                  onTap: () {
                    _markAsRead(ref, notif.id);
                    if (notif.reportId != null) {
                      context.push('/report/${notif.reportId}');
                    }
                  },
                );
              },
            );
          },
          loading: () => const Center(
              child: CircularProgressIndicator(color: FGColors.primary)),
          error: (e, _) => const Center(
            child: Text('Gagal memuat notifikasi\nTarik ke bawah untuk muat ulang',
                textAlign: TextAlign.center,
                style: TextStyle(color: FGColors.textSecondary)),
          ),
        ),
      ),
    );
  }

  void _markAsRead(WidgetRef ref, int notifId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post(ApiConfig.notifications, data: {
        'action': 'mark_read',
        'notificationId': notifId,
      });
      ref.invalidate(notificationsProvider);
    } catch (_) {}
  }

  void _markAllRead(WidgetRef ref) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post(ApiConfig.notifications, data: {
        'action': 'mark_all_read',
      });
      ref.invalidate(notificationsProvider);
    } catch (_) {}
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  IconData _typeIcon(String type) {
    switch (type) {
      case 'status_update':
        return Icons.rocket_launch_outlined;
      case 'report':
        return Icons.assignment_outlined;
      case 'alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'status_update':
        return FGColors.verified;
      case 'report':
        return FGColors.orange;
      case 'alert':
        return FGColors.primary;
      default:
        return FGColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(notification.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.white
            : color.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notification.isRead ? Colors.grey.shade100 : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_typeIcon(notification.type), color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: FGColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13, 
                      color: notification.isRead ? FGColors.textSecondary : FGColors.textPrimary.withValues(alpha: 0.8)
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: const TextStyle(
                        fontSize: 11, color: FGColors.textTertiary),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? dt) {
    if (dt == null) return '';
    try {
      String utcTime = dt.endsWith('Z') ? dt : '${dt}Z';
      final d = DateTime.parse(utcTime).toLocal();
      
      // If today, just show time, else date.
      final now = DateTime.now();
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        return 'Hari ini, ${DateFormat('HH:mm').format(d)}';
      }
      
      return DateFormat('dd MMM, HH:mm').format(d);
    } catch (_) {
      return dt;
    }
  }
}
