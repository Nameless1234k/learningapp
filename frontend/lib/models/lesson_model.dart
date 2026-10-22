// =========================================================================================
// [TÊN FILE]: lesson_model.dart
// [VỊ TRÍ]: lib/models/lesson_model.dart
// [MỤC ĐÍCH]: Định nghĩa cấu trúc dữ liệu cho Bài học (LessonItem) và Chi tiết môn học (SubjectDetailModel).
//
// [CHỨC NĂNG CHÍNH]:
// - Nhận chuỗi dữ liệu JSON từ API Backend và chuyển đổi (deserialize) thành các đối tượng Dart
//   để các màn hình giao diện (như SubjectDetailScreen) hiển thị.
// - Chứa trường 'pdfUrl': Đường dẫn tài liệu PDF động từ cơ sở dữ liệu (Database),
//   giúp ứng dụng KHÔNG CÒN GẮN CỨNG tên file PDF trong mã nguồn!
// - Đã loại bỏ thuộc tính 'description' theo yêu cầu tinh gọn cấu trúc dữ liệu.
//
// [LIÊN KẾT VỚI]:
// - SubjectService: Sử dụng Model này để đóng gói dữ liệu trả về từ HTTP Response.
// - SubjectController: Cung cấp Model này cho SubjectDetailScreen (Screen 14).
// - SubjectDetailScreen: Đọc dữ liệu từ Model để hiển thị danh sách và mở file PDF.
// =========================================================================================

class LessonItem {
  final String id; // Mã UUID định danh của bài học
  final int lessonNo; // Số thứ tự bài học (vd: 1, 2, 3...)
  final String title; // Tiêu đề/chủ đề bài học (lấy trực tiếp từ database)
  final int estimatedMinutes; // Thời lượng đọc/học ước tính tính bằng phút (vd: 18 phút)
  final String status; // Trạng thái học: 'NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'
  final bool isRead; // Đã đọc bài này hay chưa (true: đã đọc, false: chưa đọc)
  final String? pdfUrl; // Đường dẫn file PDF động từ Database (null nếu bài chưa có tài liệu)
  final int readingMinutes; // Thời gian thực tế đã đọc tính bằng phút (từ database user_lesson_progress)
  final int readingSeconds; // Tổng số giây thực tế đã đọc tích lũy
  final int lastPosition;   // Trang tài liệu lớn nhất đã đọc

  LessonItem({
    required this.id,
    required this.lessonNo,
    required this.title,
    required this.estimatedMinutes,
    required this.status,
    required this.isRead,
    this.pdfUrl,
    this.readingMinutes = 0,
    this.readingSeconds = 0,
    this.lastPosition = 1,
  });

  // Factory constructor: chuyển đổi từng item bài học từ Map JSON do Backend trả về
  factory LessonItem.fromJson(Map<String, dynamic> json) {
    return LessonItem(
      id: json['id'] as String? ?? '',
      lessonNo: (json['lessonNo'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'NOT_STARTED',
      isRead: json['isRead'] as bool? ?? false,
      pdfUrl: json['pdfUrl'] as String?, // Nhận đường dẫn động từ DB
      readingMinutes: (json['readingMinutes'] as num?)?.toInt() ?? 0,
      readingSeconds: (json['readingSeconds'] as num?)?.toInt() ?? 0,
      lastPosition: (json['lastPosition'] as num?)?.toInt() ?? 1,
    );
  }
}

// Đối tượng chứa toàn bộ thông tin chi tiết của môn học và danh sách bài học (Screen 14)
class SubjectDetailModel {
  final String subjectId; // Mã UUID môn học
  final String subjectName; // Tên môn học (vd: Triết học Mác – Lênin)
  final int totalLessons; // Tổng số bài học của môn (vd: 8 bài)
  final double progressPercent; // Tiến độ hoàn thành môn học tính bằng % (vd: 50.0%)
  final List<LessonItem> lessons; // Danh sách các bài học thuộc môn

  SubjectDetailModel({
    required this.subjectId,
    required this.subjectName,
    required this.totalLessons,
    required this.progressPercent,
    required this.lessons,
  });

  // Factory constructor: bóc tách JSON chi tiết môn học từ API
  factory SubjectDetailModel.fromJson(Map<String, dynamic> json) {
    var list = json['lessons'] as List? ?? [];
    List<LessonItem> lessonItems = list
        .map((item) => LessonItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return SubjectDetailModel(
      subjectId: json['subjectId'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
      lessons: lessonItems,
    );
  }
}
