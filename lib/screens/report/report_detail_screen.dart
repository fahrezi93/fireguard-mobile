import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';

class ReportDetailScreen extends ConsumerWidget {
  final int reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: FGColors.bg,
      body: FutureBuilder<Report>(
        future: ref.read(reportServiceProvider).getReportDetail(reportId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: FGColors.primary));
          }
          if (snapshot.hasError) {
            return _buildErrorState(context);
          }

          final report = snapshot.data!;
          final mapHeight = MediaQuery.of(context).size.height * 0.35;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                expandedHeight: mapHeight,
                pinned: true,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: FGColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(report.fireLatitude, report.fireLongitude),
                          initialZoom: 16,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.fireguard.fireguard_app',
                            tileProvider: NetworkTileProvider(
                              headers: {
                                'User-Agent': 'FireGuardApp/1.0 (Mobile App)',
                              },
                            ),
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(report.fireLatitude, report.fireLongitude),
                                width: 48,
                                height: 48,
                                child: const Icon(
                                  Icons.local_fire_department,
                                  color: FGColors.primary,
                                  size: 38,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Gradient overlay to make back button visible
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: FGColors.bg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // General Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Drag handle
                            Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: FGColors.statusColor(report.status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, size: 8, color: FGColors.statusColor(report.status)),
                                      const SizedBox(width: 8),
                                      Text(
                                        FGColors.statusLabel(report.status),
                                        style: TextStyle(
                                          color: FGColors.statusColor(report.status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 14, color: FGColors.textTertiary),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTime(report.createdAt),
                                      style: const TextStyle(fontSize: 12, color: FGColors.textSecondary, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              report.description ?? 'Tidak ada deskripsi',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: FGColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: FGColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    report.categoryIcon ?? '🔥',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Kategori', style: TextStyle(fontSize: 11, color: FGColors.textSecondary)),
                                    Text(
                                      report.categoryName ?? 'Kebakaran',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: FGColors.textPrimary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Location Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi Kejadian',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: FGColors.textPrimary),
                            ),
                            const SizedBox(height: 16),
                            if (report.address != null) ...[
                              _DetailRow(icon: Icons.location_on_outlined, label: 'Alamat / Patokan', value: report.address!),
                              const SizedBox(height: 16),
                              Divider(color: Colors.grey.shade200),
                              const SizedBox(height: 16),
                            ],
                            _DetailRow(
                              icon: Icons.map_outlined,
                              label: 'Kelurahan / Kecamatan',
                              value: '${report.kelurahanName ?? "-"}, ${report.kecamatan ?? "-"}',
                            ),
                          ],
                        ),
                      ),

                      // Additional details Card
                      if ((report.notes != null && report.notes!.isNotEmpty) || (report.contact != null && report.contact!.isNotEmpty)) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informasi Tambahan',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: FGColors.textPrimary),
                              ),
                              const SizedBox(height: 16),
                              if (report.notes != null && report.notes!.isNotEmpty) ...[
                                _DetailRow(icon: Icons.note_alt_outlined, label: 'Catatan Pelapor', value: report.notes!),
                                const SizedBox(height: 16),
                              ],
                              if (report.contact != null && report.contact!.isNotEmpty) ...[
                                if (report.notes != null && report.notes!.isNotEmpty) ...[
                                  Divider(color: Colors.grey.shade200),
                                  const SizedBox(height: 16),
                                ],
                                _DetailRow(icon: Icons.phone_outlined, label: 'Kontak Darurat', value: report.contact!),
                              ],
                            ],
                          ),
                        ),
                      ],

                      // Admin Notes
                      if (report.adminNotes != null && report.adminNotes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFED7AA)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info_outline, size: 18, color: Color(0xFFEA580C)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Catatan Operator/Staff',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEA580C), fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                report.adminNotes!,
                                style: const TextStyle(fontSize: 14, color: FGColors.textPrimary, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: FGColors.textTertiary),
            const SizedBox(height: 12),
            const Text('Gagal memuat laporan', style: TextStyle(color: FGColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? dt) {
    if (dt == null) return '';
    try {
      // Sama seperti di beranda, konversi timezone dari UTC ke local
      String utcTime = dt.endsWith('Z') ? dt : '${dt}Z';
      final d = DateTime.parse(utcTime).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(d);
    } catch (_) {
      return dt;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: FGColors.bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: FGColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: FGColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, color: FGColors.textPrimary, fontWeight: FontWeight.w500, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
