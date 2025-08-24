class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String role;
  final String phone;
  final String address;
  final String caregiverName;
  final String caregiverPhone;
  final String createdAt;
  final String updatedAt;
  final int? centerId;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.role,
    required this.phone,
    required this.address,
    required this.caregiverName,
    required this.caregiverPhone,
    required this.createdAt,
    required this.updatedAt,
    this.centerId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      role: json['role'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      caregiverName: json['caregiver_name'] as String,
      caregiverPhone: json['caregiver_phone'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      centerId: json['center_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'role': role,
      'phone': phone,
      'address': address,
      'caregiver_name': caregiverName,
      'caregiver_phone': caregiverPhone,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'center_id': centerId,
    };
  }

  // Helper method to format creation date
  String get formattedCreatedDate {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt;
    }
  }

  // Helper method to get role in Arabic
  String get roleInArabic {
    switch (role.toLowerCase()) {
      case 'patient':
        return 'مريض';
      case 'doctor':
        return 'طبيب';
      case 'nurse':
        return 'ممرض';
      case 'admin':
        return 'مدير';
      default:
        return role;
    }
  }

  // Helper method to check if email is verified
  bool get isEmailVerified => emailVerifiedAt != null;
}
