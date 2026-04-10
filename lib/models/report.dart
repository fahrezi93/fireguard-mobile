class Report {
  final int id;
  final double fireLatitude;
  final double fireLongitude;
  final double? reporterLatitude;
  final double? reporterLongitude;
  final String? description;
  final String? address;
  final String status;
  final String? photoUrl;
  final String? adminNotes;
  final String? notes;
  final String? contact;
  final int? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final int? kelurahanId;
  final String? kelurahanName;
  final String? kecamatan;
  final String? createdAt;
  final String? updatedAt;

  Report({
    required this.id,
    required this.fireLatitude,
    required this.fireLongitude,
    this.reporterLatitude,
    this.reporterLongitude,
    this.description,
    this.address,
    required this.status,
    this.photoUrl,
    this.adminNotes,
    this.notes,
    this.contact,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.kelurahanId,
    this.kelurahanName,
    this.kecamatan,
    this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      fireLatitude: _parseDouble(json['fire_latitude']),
      fireLongitude: _parseDouble(json['fire_longitude']),
      reporterLatitude: json['reporter_latitude'] != null
          ? _parseDouble(json['reporter_latitude'])
          : null,
      reporterLongitude: json['reporter_longitude'] != null
          ? _parseDouble(json['reporter_longitude'])
          : null,
      description: json['description'] as String?,
      address: json['address'] as String?,
      status: json['status'] as String? ?? 'pending',
      photoUrl: json['photo_url'] as String? ?? json['media_url'] as String?,
      adminNotes: json['admin_notes'] as String?,
      notes: json['notes'] as String?,
      contact: json['contact'] as String?,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String?,
      categoryIcon: json['category_icon'] as String?,
      kelurahanId: json['kelurahan_id'] as int?,
      kelurahanName: json['kelurahan_name'] as String?,
      kecamatan: json['kecamatan'] as String?,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }
}
