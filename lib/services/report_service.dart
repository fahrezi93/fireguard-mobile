import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../models/report.dart';
import 'dio_client.dart';

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref.read(dioProvider));
});

class ReportService {
  final Dio _dio;

  ReportService(this._dio);

  /// Get user's reports
  Future<List<Report>> getMyReports() async {
    final response = await _dio.get(ApiConfig.myReports);
    final data = response.data;
    final List reports = data['reports'] ?? [];
    return reports.map((r) => Report.fromJson(r)).toList();
  }

  /// Get single report detail
  Future<Report> getReportDetail(int reportId) async {
    final response = await _dio.get(
      ApiConfig.myReports,
      queryParameters: {'id': reportId},
    );
    return Report.fromJson(response.data['report']);
  }

  /// Create new report with optional media upload
  Future<Map<String, dynamic>> createReport({
    required double fireLatitude,
    required double fireLongitude,
    double? reporterLatitude,
    double? reporterLongitude,
    required String description,
    String? address,
    String? notes,
    String? contact,
    int? categoryId,
    int? kelurahanId,
    File? mediaFile,
  }) async {
    final formData = FormData.fromMap({
      'fire_latitude': fireLatitude.toString(),
      'fire_longitude': fireLongitude.toString(),
      if (reporterLatitude != null)
        'reporter_latitude': reporterLatitude.toString(),
      if (reporterLongitude != null)
        'reporter_longitude': reporterLongitude.toString(),
      'description': description,
      ...?address != null ? {'address': address} : null,
      ...?notes != null ? {'notes': notes} : null,
      ...?contact != null ? {'contact': contact} : null,
      ...?categoryId != null ? {'category_id': categoryId.toString()} : null,
      ...?kelurahanId != null ? {'kelurahan_id': kelurahanId.toString()} : null,
      if (mediaFile != null)
        'media': await MultipartFile.fromFile(
          mediaFile.path,
          filename: mediaFile.path.split('/').last,
        ),
    });

    final response = await _dio.post(
      ApiConfig.reports,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return response.data;
  }
}
