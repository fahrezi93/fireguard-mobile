import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/weather_provider.dart';
import '../../models/report.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final reportsAsync = ref.watch(myReportsProvider);
    final stats = ref.watch(reportStatsProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: FGColors.primary,
        onRefresh: () async {
          ref.invalidate(myReportsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Gojek-like Header with floating info card
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Red Gradient Background curved at bottom
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: FGTheme.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 2),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: FGColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  userAsync.when(
                                    data: (user) => Text(
                                      'Halo, ${user?.name ?? "Warga"}!',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    loading: () => Container(
                                      height: 18,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    error: (e, stack) => const Text(
                                      'Halo, Warga!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on, color: Colors.white, size: 12),
                                        SizedBox(width: 4),
                                        Text(
                                          'Plaju Darat, Palembang',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating Stats Card (Like GrabPay/OVO bar)
                  Positioned(
                    top: 140,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: FGTheme.cardShadow,
                      ),
                      child: Row(
                        children: [
                          _StatColumn(
                            label: 'Laporan Anda',
                            value: '${stats['total']}',
                            icon: Icons.assignment_outlined,
                            baseColor: FGColors.primary,
                          ),
                          Container(width: 1, height: 40, color: FGColors.border),
                          _StatColumn(
                            label: 'Aktif',
                            value: '${stats['active']}',
                            icon: Icons.local_fire_department_outlined,
                            baseColor: FGColors.orange,
                          ),
                          Container(width: 1, height: 40, color: FGColors.border),
                          _StatColumn(
                            label: 'Selesai',
                            value: '${stats['completed']}',
                            icon: Icons.check_circle_outline,
                            baseColor: FGColors.completed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 50)), // Space for floating card

            // Quick Actions Grid (Gojek-like menus)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu Cepat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: FGColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _QuickActionIcon(
                          iconPath: '🔥',
                          label: 'Kebakaran',
                          color: FGColors.primary,
                          onTap: () => context.go('/report/new?category=Kebakaran'),
                        ),
                        _QuickActionIcon(
                          iconPath: '🌊',
                          label: 'Banjir',
                          color: Colors.blue,
                          onTap: () => context.go('/report/new?category=Banjir'),
                        ),
                        _QuickActionIcon(
                          iconPath: '🏚️',
                          label: 'Gempa',
                          color: Colors.brown.shade700,
                          onTap: () => context.go('/report/new?category=Gempa'),
                        ),
                        _QuickActionIcon(
                          iconPath: '🌪️',
                          label: 'Puting Beliung',
                          color: Colors.grey.shade700,
                          onTap: () => context.go('/report/new?category=Angin'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Divider
            SliverToBoxAdapter(
              child: Container(
                height: 8,
                color: FGColors.border.withValues(alpha: 0.5),
              ),
            ),

            // Recent reports header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  'Laporan Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: FGColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Reports list
            reportsAsync.when(
              data: (reports) {
                if (reports.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: _EmptyState(),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= reports.length) return null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: _ReportCard(report: reports[index]),
                      );
                    },
                    childCount: reports.length.clamp(0, 5),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: FGColors.primary),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Gagal memuat laporan',
                      style: TextStyle(color: FGColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Divider
            SliverToBoxAdapter(
              child: Container(
                height: 8,
                color: FGColors.border.withValues(alpha: 0.5),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            const SliverToBoxAdapter(
              child: _WeatherSection(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            const SliverToBoxAdapter(
              child: _EmergencyContacts(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            const SliverToBoxAdapter(
              child: _SafetyTips(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color baseColor;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: baseColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: FGColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: FGColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActionIcon extends StatelessWidget {
  final String iconPath; // using emoji as placeholder for rich icons
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionIcon({
    required this.iconPath,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  iconPath,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: FGColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  final Report report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        // Push ke halaman detail laporan
        await context.push('/report/${report.id}');
        
        // Refresh laporan di beranda setelah kembali
        ref.read(myReportsProvider.notifier).refresh();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: FGTheme.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: FGColors.bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  report.categoryIcon ?? '🔥',
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          report.categoryName ?? 'Laporan Baru',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: FGColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: FGColors.statusColor(report.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          FGColors.statusLabel(report.status),
                          style: TextStyle(
                            color: FGColors.statusColor(report.status),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.description ?? 'Tidak ada deskripsi',
                    style: const TextStyle(
                      fontSize: 13,
                      color: FGColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: FGColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(report.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: FGColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
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
      // Pastikan string zona waktu terbaca sebagai UTC jika API tidak memberikan format Z
      String utcTime = dt.endsWith('Z') ? dt : '${dt}Z';
      final date = DateTime.parse(utcTime).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {
      return dt;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: FGColors.bg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_outlined,
                size: 40, color: FGColors.textTertiary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada laporan',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: FGColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Buat laporan pertamamu sekarang',
            style: TextStyle(fontSize: 13, color: FGColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _WeatherSection extends ConsumerWidget {
  const _WeatherSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Kondisi Cuaca Saat Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: FGColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        weatherAsync.when(
          data: (weather) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildWeatherCard(weather),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Gagal mengambil data cuaca.', style: TextStyle(color: Colors.red)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(WeatherData weather) {
    // Kapitalisasi huruf pertama setiap kata dari 'description'
    final conditionParts = weather.condition.split(' ');
    final condition = conditionParts
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');
    
    // URL Ikon Cuaca resmi dari OpenWeatherMap
    final iconUrl = 'https://openweathermap.org/img/wn/${weather.icon}@2x.png';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.blue.shade600),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            weather.cityName,
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${weather.temp.round()}°C',
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                        height: 1.0,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      condition,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: Image.network(
                  iconUrl,
                  errorBuilder: (c, e, s) => Icon(Icons.cloud, size: 50, color: Colors.blue.shade300),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Sub-informasi (Angin & Kelembaban)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _WeatherDetailItem(icon: Icons.water_drop, label: 'Lembab', value: '${weather.humidity}%')),
                Container(width: 1, height: 30, color: Colors.blue.withValues(alpha: 0.2)),
                const SizedBox(width: 8),
                Expanded(child: _WeatherDetailItem(icon: Icons.air, label: 'Angin', value: '${weather.windSpeed}m/s')),
                Container(width: 1, height: 30, color: Colors.blue.withValues(alpha: 0.2)),
                const SizedBox(width: 8),
                Expanded(child: _WeatherDetailItem(icon: Icons.visibility, label: 'Terasa', value: '${(weather.temp + 1).round()}°C')),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade500),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmergencyContacts extends StatelessWidget {
  const _EmergencyContacts();

  Future<void> _launchCaller(BuildContext context, String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (!await launchUrl(url)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat melakukan panggilan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Nomor Darurat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: FGColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _EmergencyCard(
                title: 'Pemadam\nKebakaran',
                number: '113',
                icon: Icons.local_fire_department,
                color: FGColors.primary,
                onTap: () => _launchCaller(context, '113'),
              ),
              _EmergencyCard(
                title: 'Ambulans\nGawat Darurat',
                number: '119',
                icon: Icons.medical_services,
                color: Colors.green.shade600,
                onTap: () => _launchCaller(context, '119'),
              ),
              _EmergencyCard(
                title: 'Kepolisian\nRepublik',
                number: '110',
                icon: Icons.local_police,
                color: Colors.blue.shade700,
                onTap: () => _launchCaller(context, '110'),
              ),
              _EmergencyCard(
                title: 'SAR /\nBasarnas',
                number: '115',
                icon: Icons.support,
                color: Colors.orange.shade700,
                onTap: () => _launchCaller(context, '115'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final String title;
  final String number;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyCard({
    required this.title,
    required this.number,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: color, size: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color.withOpacity(0.9),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SafetyTips extends StatelessWidget {
  const _SafetyTips();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Edukasi & Keselamatan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: FGColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: const [
              _TipCard(
                title: 'Tas Siaga Bencana',
                subtitle: 'Persiapkan tas berisi dokumen penting & obat-obatan',
                icon: '🎒',
                color: Color(0xFFFDE68A),
              ),
              _TipCard(
                title: 'Ketika Gempa Terjadi',
                subtitle: 'Jangan panik, berlindung di bawah meja yang kuat',
                icon: '🏚️',
                color: Color(0xFFFED7AA),
              ),
              _TipCard(
                title: 'Mencegah Korsleting',
                subtitle: 'Pastikan kabel di rumah tidak ada yang terkelupas',
                icon: '⚡',
                color: Color(0xFFFECACA),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;

  const _TipCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -15,
            child: Text(
              icon,
              style: TextStyle(fontSize: 90, color: Colors.black.withValues(alpha: 0.08)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: FGColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: FGColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
