class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final int? reportId;
  final bool isRead;
  final String? createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'info',
    this.reportId,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'info',
      reportId: json['report_id'] as int?,
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at']?.toString(),
    );
  }
}

class DisasterCategory {
  final int id;
  final String name;
  final String icon;
  final String color;
  final String? description;

  DisasterCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.description,
  });

  factory DisasterCategory.fromJson(Map<String, dynamic> json) {
    return DisasterCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      description: json['description'] as String?,
    );
  }
}

class Kelurahan {
  final int id;
  final String name;
  final String kodePos;
  final String kecamatan;
  final String? description;

  Kelurahan({
    required this.id,
    required this.name,
    required this.kodePos,
    required this.kecamatan,
    this.description,
  });

  factory Kelurahan.fromJson(Map<String, dynamic> json) {
    return Kelurahan(
      id: json['id'] as int,
      name: json['name'] as String,
      kodePos: json['kode_pos'] as String,
      kecamatan: json['kecamatan'] as String,
      description: json['description'] as String?,
    );
  }
}
