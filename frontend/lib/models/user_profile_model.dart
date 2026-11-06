// =========================================================================================
// [TÊN FILE: user_profile_model.dart]
// [VỊ TRÍ]: lib/models/user_profile_model.dart
// [MỤC ĐÍCH]: Mô hình dữ liệu cho Thông tin cá nhân và Thống kê trắc nghiệm
// =========================================================================================

class UserProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? phone;
  final String role;

  UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'USER',
    );
  }
}

class UserStatisticsModel {
  final bool hasData;
  final int totalQuestions;
  final String message;
  final String description;
  final List<SubjectScoreModel> subjectScores;

  UserStatisticsModel({
    required this.hasData,
    required this.totalQuestions,
    required this.message,
    required this.description,
    required this.subjectScores,
  });

  factory UserStatisticsModel.fromJson(Map<String, dynamic> json) {
    var list = json['subjectScores'] as List? ?? [];
    List<SubjectScoreModel> scores = list.map((e) => SubjectScoreModel.fromJson(e)).toList();

    return UserStatisticsModel(
      hasData: json['hasData'] == true,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? 'Chưa có thống kê',
      description: json['description']?.toString() ??
          'Bạn chưa hoàn thành câu hỏi trắc nghiệm nào. Hãy làm bài luyện tập để theo dõi điểm số tại đây nhé!',
      subjectScores: scores,
    );
  }
}

class SubjectScoreModel {
  final String subjectCode;
  final String subjectName;
  final double score;

  SubjectScoreModel({
    required this.subjectCode,
    required this.subjectName,
    required this.score,
  });

  factory SubjectScoreModel.fromJson(Map<String, dynamic> json) {
    return SubjectScoreModel(
      subjectCode: json['subjectCode']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
