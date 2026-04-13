import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../config/api_config.dart';
import '../../utils/icon_helper.dart';
import '../../config/theme.dart';
import '../../models/notification_model.dart';
import '../../providers/report_provider.dart';
import '../../services/dio_client.dart';
import '../../services/report_service.dart';

class NewReportScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const NewReportScreen({super.key, this.initialCategory});

  @override
  ConsumerState<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends ConsumerState<NewReportScreen> {
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _contactController = TextEditingController();
  final _mapController = MapController();

  LatLng _fireLocation = const LatLng(-2.9845, 104.7794);
  LatLng? _reporterLocation;
  File? _selectedImage;

  List<DisasterCategory> _categories = const [];
  List<Kelurahan> _kelurahanList = const [];
  int? _categoryId;
  int? _kelurahanId;

  bool _isLoading = false;
  bool _isLocating = false;
  bool _isMetaLoading = true;

  String? _error;
  String? _metaError;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setFireLocationFromDevice();
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterData() async {
    setState(() {
      _isMetaLoading = true;
      _metaError = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final responses = await Future.wait([
        dio.get(ApiConfig.disasterCategories),
        dio.get(ApiConfig.kelurahan),
      ]);

      final categories = _parseCategories(responses[0].data);
      final kelurahan = _parseKelurahan(responses[1].data);

      int? categoryId = _categoryId;
      if (categories.isNotEmpty) {
        final hasCurrent =
            categoryId != null && categories.any((c) => c.id == categoryId);
        if (!hasCurrent) {
          if (widget.initialCategory != null) {
            final initialMatchIndex = categories.indexWhere(
              (c) => c.name.toLowerCase().contains(
                widget.initialCategory!.toLowerCase(),
              ),
            );
            if (initialMatchIndex >= 0) {
              categoryId = categories[initialMatchIndex].id;
            }
          }

          if (categoryId == null) {
            final kebakaranIndex = categories.indexWhere(
              (c) => c.id == 1 || c.name.toLowerCase().contains('kebakaran'),
            );
            categoryId = kebakaranIndex >= 0
                ? categories[kebakaranIndex].id
                : categories.first.id;
          }
        }
      }

      int? kelurahanId = _kelurahanId;
      if (kelurahan.isNotEmpty) {
        final hasCurrent =
            kelurahanId != null && kelurahan.any((k) => k.id == kelurahanId);
        if (!hasCurrent) {
          final plajuDaratIndex = kelurahan.indexWhere(
            (k) => k.name.toLowerCase().contains('plaju darat'),
          );
          kelurahanId = plajuDaratIndex >= 0
              ? kelurahan[plajuDaratIndex].id
              : kelurahan.first.id;
        }
      }

      setState(() {
        _categories = categories;
        _kelurahanList = kelurahan;
        _categoryId = categoryId;
        _kelurahanId = kelurahanId;
        _isMetaLoading = false;
      });
    } catch (_) {
      setState(() {
        _isMetaLoading = false;
        _metaError = 'Gagal memuat kategori dan kelurahan.';
      });
    }
  }

  List<DisasterCategory> _parseCategories(dynamic data) {
    if (data is Map && data['success'] == true && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .whereType<Map>()
          .map((e) => DisasterCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  List<Kelurahan> _parseKelurahan(dynamic data) {
    if (data is Map && data['success'] == true && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .whereType<Map>()
          .map((e) => Kelurahan.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  Future<LatLng?> _getDeviceLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _setFireLocationFromDevice() async {
    setState(() => _isLocating = true);
    try {
      final deviceLocation = await _getDeviceLocation();
      if (deviceLocation == null) return;

      setState(() {
        _fireLocation = deviceLocation;
        _reporterLocation ??= deviceLocation;
      });

      _mapController.move(deviceLocation, 16);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _setReporterLocationFromDevice() async {
    setState(() => _isLocating = true);
    try {
      final deviceLocation = await _getDeviceLocation();
      if (deviceLocation == null) return;

      setState(() => _reporterLocation = deviceLocation);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1280,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_categoryId == null) {
      setState(() => _error = 'Kategori bencana wajib dipilih.');
      return;
    }

    if (_kelurahanId == null) {
      setState(() => _error = 'Kelurahan wajib dipilih.');
      return;
    }

    if (_descController.text.trim().isEmpty) {
      setState(() => _error = 'Deskripsi kejadian wajib diisi.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reportService = ref.read(reportServiceProvider);
      await reportService.createReport(
        fireLatitude: _fireLocation.latitude,
        fireLongitude: _fireLocation.longitude,
        reporterLatitude: _reporterLocation?.latitude,
        reporterLongitude: _reporterLocation?.longitude,
        description: _descController.text.trim(),
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        contact: _contactController.text.trim().isNotEmpty
            ? _contactController.text.trim()
            : null,
        categoryId: _categoryId,
        kelurahanId: _kelurahanId,
        mediaFile: _selectedImage,
      );

      ref.read(myReportsProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dikirim!'),
            backgroundColor: FGColors.completed,
          ),
        );
        context.go('/dashboard');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        setState(() => _error = data['message'].toString());
      } else {
        setState(() => _error = 'Gagal mengirim laporan. Coba lagi.');
      }
    } catch (_) {
      setState(() => _error = 'Gagal mengirim laporan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _customInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: FGColors.textTertiary, fontSize: 14),
      prefixIcon: Icon(icon, color: FGColors.primary, size: 22),
      filled: true,
      fillColor: const Color(0xFFF8FAFC), // Sangat soft light gray
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: FGColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: FGColors.bg,
                expandedHeight: mapHeight,
                pinned: true,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: FGColors.textPrimary,
                      ),
                      onPressed: () => context.go('/dashboard'),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _fireLocation,
                          initialZoom: 15,
                          onTap: (_, latlng) =>
                              setState(() => _fireLocation = latlng),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                                point: _fireLocation,
                                width: 48,
                                height: 48,
                                child: const Icon(
                                  Icons.local_fire_department,
                                  color: FGColors.primary,
                                  size: 38,
                                ),
                              ),
                              if (_reporterLocation != null)
                                Marker(
                                  point: _reporterLocation!,
                                  width: 44,
                                  height: 44,
                                  child: const Icon(
                                    Icons.person_pin_circle,
                                    color: Colors.blue,
                                    size: 34,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 40,
                        right: 16,
                        child: FloatingActionButton(
                          mini: true,
                          heroTag: 'my_location_fab',
                          backgroundColor: Colors.white,
                          onPressed: _setFireLocationFromDevice,
                          child: _isLocating
                              ? const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: FGColors.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location,
                                  color: FGColors.primary,
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
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  transform: Matrix4.translationValues(0, -30, 0),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const Text(
                        'Laporkan Kejadian',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: FGColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Isi data laporan sesuai form website.',
                        style: TextStyle(
                          fontSize: 13,
                          color: FGColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _setFireLocationFromDevice,
                              icon: const Icon(
                                Icons.local_fire_department,
                                color: FGColors.primary,
                              ),
                              label: const Text(
                                'Lokasi Kejadian',
                                style: TextStyle(
                                  color: FGColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FGColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: FGColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _setReporterLocationFromDevice,
                              icon: const Icon(
                                Icons.person_pin_circle,
                                color: Colors.blue,
                              ),
                              label: const Text(
                                'Lokasi Saya',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.withValues(
                                  alpha: 0.1,
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Colors.blue.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (_metaError != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _metaError!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: FGColors.textPrimary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _loadMasterData,
                                child: const Text('Muat Ulang'),
                              ),
                            ],
                          ),
                        ),
                      if (_isMetaLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: FGColors.primary,
                            ),
                          ),
                        )
                      else ...[
                        const Text(
                          'Kategori Bencana',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: FGColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: _categoryId,
                          items: _categories
                              .map(
                                (c) => DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Row(
                                    children: [
                                      Icon(
                                        getAmiconFromEmoji(c.icon),
                                        size: 20,
                                        color: FGColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          c.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _categoryId = value),
                          decoration: _customInputDecoration(
                            'Pilih kategori bencana',
                            Icons.category_outlined,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: FGColors.primary,
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Kelurahan Lokasi Kejadian',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: FGColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: _kelurahanId,
                          items: _kelurahanList
                              .map(
                                (k) => DropdownMenuItem<int>(
                                  value: k.id,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_city_rounded,
                                        size: 20,
                                        color: FGColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          k.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _kelurahanId = value),
                          decoration: _customInputDecoration(
                            'Pilih kelurahan kejadian',
                            Icons.map_outlined,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: FGColors.primary,
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        const SizedBox(height: 24),
                      ],
                      const Text(
                        'Deskripsi Detail',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: FGColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descController,
                        maxLines: 4,
                        decoration:
                            _customInputDecoration(
                              'Contoh: Kebakaran rumah warga, api sudah membesar dan menyambar kabel...',
                              Icons.description_outlined,
                            ).copyWith(
                              alignLabelWithHint: true,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 60),
                                child: Icon(
                                  Icons.description_outlined,
                                  color: FGColors.primary,
                                  size: 22,
                                ),
                              ),
                            ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Alamat Persis / Patokan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: FGColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _addressController,
                        decoration: _customInputDecoration(
                          'Jl. Merdeka No. 10, sebelah warung makan',
                          Icons.location_city_outlined,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Bukti Foto Kejadian',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: FGColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedImage != null)
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _selectedImage!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _pickImage(ImageSource.camera),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: FGColors.bg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: FGColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: FGColors.primary,
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Ambil Kamera',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: FGColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => _pickImage(ImageSource.gallery),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: FGColors.bg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: FGColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        color: Colors.blue,
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Pilih Galeri',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: FGColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      const Text(
                        'Informasi Tambahan / Kontak',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: FGColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration:
                            _customInputDecoration(
                              'Catatan (opsional): Ada warga terjebak...',
                              Icons.note_alt_outlined,
                            ).copyWith(
                              alignLabelWithHint: true,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 24),
                                child: Icon(
                                  Icons.note_alt_outlined,
                                  color: FGColors.primary,
                                  size: 22,
                                ),
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        decoration: _customInputDecoration(
                          'Nomor HP Darurat (opsional)',
                          Icons.phone_outlined,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: FGColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: FGColors.primary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: FGTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: (_isLoading || _isMetaLoading) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Kirim Laporan',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
