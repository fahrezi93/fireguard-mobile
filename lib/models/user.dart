class User {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final bool isVerified;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.isVerified = false,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String? ?? json['phone'] as String?,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
      };
}
