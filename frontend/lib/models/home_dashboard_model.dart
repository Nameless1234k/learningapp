// =========================================================================================
// [TÊN FILE: home_dashboard_model.dart]
// [VỊ TRÍ]: lib/models/home_dashboard_model.dart
// [MỤC ĐÍCH]: Model dữ liệu (Pattern MVC) đại diện cho thông tin Trang chủ và Phiên học hôm nay
// =========================================================================================

class TodaySessionModel {
  final String lessonId;
  final String subjectId;
  final String subjectName;
  final int lessonNo;
  final String lessonTitle;
  final double progressPercent;
  final int lastPosition;
  final int totalPages;
  final String? pdfUrl;
  final String buttonText;
  final String status;
  final int readingSeconds;

  TodaySessionModel({
    required this.lessonId,
    required this.subjectId,
    required this.subjectName,
    required this.lessonNo,
    required this.lessonTitle,
    required this.progressPercent,
    required this.lastPosition,
    required this.totalPages,
    this.pdfUrl,
    required this.buttonText,
    required this.status,
    this.readingSeconds = 0,
  });

  factory TodaySessionModel.fromJson(Map<String, dynamic> json) {
    return TodaySessionModel(
      lessonId: json['lessonId'] ?? '',
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      lessonNo: json['lessonNo'] ?? 1,
      lessonTitle: json['lessonTitle'] ?? '',
      progressPercent: (json['progressPercent'] is num)
          ? (json['progressPercent'] as num).toDouble()
          : 0.0,
      lastPosition: json['lastPosition'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      pdfUrl: json['pdfUrl'],
      buttonText: json['buttonText'] ?? 'Vào học',
      status: json['status'] ?? 'NOT_STARTED',
      readingSeconds: json['readingSeconds'] ?? 0,
    );
  }
}

class RecentLessonModel {
  final String lessonId;
  final String lessonTitle;
  final String subjectName;
  final double progressPercent;
  final int lastPosition;
  final String? pdfUrl;
  final String? lastReadAt;

  RecentLessonModel({
    required this.lessonId,
    required this.lessonTitle,
    required this.subjectName,
    required this.progressPercent,
    required this.lastPosition,
    this.pdfUrl,
    this.lastReadAt,
  });

  factory RecentLessonModel.fromJson(Map<String, dynamic> json) {
    return RecentLessonModel(
      lessonId: json['lessonId'] ?? '',
      lessonTitle: json['lessonTitle'] ?? '',
      subjectName: json['subjectName'] ?? '',
      progressPercent: (json['progressPercent'] is num)
          ? (json['progressPercent'] as num).toDouble()
          : 0.0,
      lastPosition: json['lastPosition'] ?? 1,
      pdfUrl: json['pdfUrl'],
      lastReadAt: json['lastReadAt'],
    );
  }
}

class HomeDashboardModel {
  final String greeting;
  final String userFullName;
  final String userInitials;
  final bool isNewUser;
  final TodaySessionModel? todaySession;
  final List<RecentLessonModel> recentLessons;

  HomeDashboardModel({
    required this.greeting,
    required this.userFullName,
    required this.userInitials,
    required this.isNewUser,
    this.todaySession,
    required this.recentLessons,
  });

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    return HomeDashboardModel(
      greeting: json['greeting'] ?? 'Chào mừng bạn đến với Learning App',
      userFullName: json['userFullName'] ?? '',
      userInitials: json['userInitials'] ?? 'LH',
      isNewUser: json['isNewUser'] ?? false,
      todaySession: json['todaySession'] != null
          ? TodaySessionModel.fromJson(json['todaySession'])
          : null,
      recentLessons: json['recentLessons'] != null
          ? (json['recentLessons'] as List)
              .map((e) => RecentLessonModel.fromJson(e))
              .toList()
          : [],
    );
  }
}
