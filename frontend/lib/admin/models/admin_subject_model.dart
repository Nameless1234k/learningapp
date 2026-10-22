class AdminSubjectModel {
  final String id;
  final String code;
  final String name;
  final int displayOrder;
  final String? createdAt;

  AdminSubjectModel({
    required this.id,
    required this.code,
    required this.name,
    required this.displayOrder,
    this.createdAt,
  });

  factory AdminSubjectModel.fromJson(Map<String, dynamic> json) {
    return AdminSubjectModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      displayOrder: json['displayOrder'] is int ? json['displayOrder'] : int.tryParse(json['displayOrder']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
