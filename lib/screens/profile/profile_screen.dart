import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final stats = ref.watch(reportStatsProvider);

    return Scaffold(
      backgroundColor: FGColors.bg,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          // Header Profile Info
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                   Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: FGColors.bg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FGColors.border,
                        width: 1,
                      ),
                    ),
                    child: userAsync.when(
                      data: (user) => Center(
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(
                            color: FGColors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      loading: () => const Icon(Icons.person,
                          color: FGColors.textTertiary, size: 28),
                      error: (e, stack) => const Icon(Icons.person,
                          color: FGColors.textTertiary, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: userAsync.when(
                      data: (user) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Loading...',
                            style: const TextStyle(
                              color: FGColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              color: FGColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      loading: () => const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Loading...', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      error: (e, stack) => const SizedBox(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: FGColors.primary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur ubah profil akan segera hadir!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Stats Widget
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: FGTheme.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProfileStat(
                      label: 'Laporan Anda', 
                      value: '${stats['total']}',
                      icon: Icons.history,
                  ),
                  Container(width: 1, height: 40, color: FGColors.border),
                  _ProfileStat(
                      label: 'Dalam Proses', 
                      value: '${stats['active']}',
                      icon: Icons.autorenew,
                  ),
                  Container(width: 1, height: 40, color: FGColors.border),
                  _ProfileStat(
                      label: 'Selesai',
                      value: '${stats['completed']}',
                      icon: Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          ),

          // Menu Sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Akun',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: FGColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Group 1
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: FGTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          iconColor: Colors.blue.shade600,
                          label: 'Pengaturan',
                          onTap: () => context.push('/settings'),
                        ),
                        _buildDivider(),
                        _MenuItem(
                          icon: Icons.lock_outline,
                          iconColor: Colors.orange.shade600,
                          label: 'Keamanan & Sandi',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fitur keamanan & sandi sedang dalam pengembangan!')),
                            );
                          },
                        ),
                        _buildDivider(),
                        _MenuItem(
                          icon: Icons.notifications_active_outlined,
                          iconColor: Colors.indigo.shade500,
                          label: 'Notifikasi',
                          onTap: () => context.push('/notifications'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  const Text(
                    'Bantuan & Info',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: FGColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Group 2
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: FGTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        _MenuItem(
                          icon: Icons.help_outline,
                          iconColor: Colors.teal.shade500,
                          label: 'Pusat Bantuan',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Menghubungi layanan pelanggan pusat bantuan...')),
                            );
                          },
                        ),
                        _buildDivider(),
                        _MenuItem(
                          icon: Icons.info_outline,
                          iconColor: Colors.green.shade600,
                          label: 'Tentang Aplikasi',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'FireGuard',
                              applicationVersion: '1.0.0',
                              applicationIcon: const Icon(Icons.local_fire_department, size: 40, color: FGColors.primary),
                              applicationLegalese:
                                  '© 2026 FireGuard. Semua Hak Cipta Dilindungi.',
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleLogout(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        foregroundColor: FGColors.primary,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: const Text('Keluar'),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: FGColors.border,
      indent: 60,
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Keluar dari Akun?'),
        content: const Text('Sesi kamu akan diakhiri dan harus login kembali untuk masuk.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(foregroundColor: FGColors.textSecondary),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(userProvider.notifier).logout();
              if (context.mounted) context.go('/welcome');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FGColors.primary,
            ),
            child: const Text('Ya, Keluar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: FGColors.textSecondary, size: 20),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: FGColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: FGColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500, color: FGColors.textPrimary)),
            ),
            const Icon(Icons.chevron_right,
                color: FGColors.textTertiary, size: 24),
          ],
        ),
      ),
    );
  }
}
