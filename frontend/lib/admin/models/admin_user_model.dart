class AdminUserModel {
  final String id;
  final String lastName;
  final String firstName;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  bool isActive;
  final String createdAt;

  AdminUserModel({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'USER',
      isActive: json['isActive'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
