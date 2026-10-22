// =========================================================================================
// [TÊN FILE: subject_model.dart]
// [VỊ TRÍ]: lib/models/subject_model.dart
// [MỤC ĐÍCH]: Định nghĩa cấu trúc dữ liệu cho Môn học và Tiến độ học tập của người dùng.
// Dùng để chuyển đổi dữ liệu JSON từ Backend (Spring Boot) sang đối tượng Dart trong Flutter.
// Đã lược bỏ thuộc tính 'description' theo yêu cầu tinh gọn cấu trúc cơ sở dữ liệu.
// =========================================================================================

class SubjectItem {
  final String id; // Mã UUID định danh duy nhất của môn học
  final String code; // Mã môn học (vd: TRIET_HOC, KTCT, CNXHKH...)
  final String name; // Tên môn học hiển thị (vd: Triết học Mác - Lênin)
  final double progressPercent; // Tiến độ học của user theo môn (tính từ 0.0 đến 100.0%)
  final String? nextLesson; // Tiêu đề bài học tiếp theo cần học (vd: "Bài tiếp theo: Bài 3-Hai nguyên lí...")
  final int totalLessons; // Tổng số bài học của môn
  final int completedLessons; // Số bài học mà user đã hoàn thành

  // Constructor khởi tạo đối tượng SubjectItem
  SubjectItem({
    required this.id,
    required this.code,
    required this.name,
    required this.progressPercent,
    this.nextLesson,
    required this.totalLessons,
    required this.completedLessons,
  });

  // Factory constructor: chuyển đổi từ Map (JSON do API trả về) sang đối tượng SubjectItem
  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    return SubjectItem(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
      nextLesson: json['nextLesson'] as String?,
      totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 0,
      completedLessons: (json['completedLessons'] as num?)?.toInt() ?? 0,
    );
  }
}

// Đối tượng chứa thông tin tổng thể danh sách môn học (Dành cho Screen 9)
class SubjectListModel {
  final int totalSubjects; // Tổng số môn học có trong hệ thống (vd: 5 môn)
  final int readSubjects; // Số môn mà người dùng đã bắt đầu đọc (vd: 4 môn)
  final List<SubjectItem> subjects; // Danh sách chi tiết các môn học

  SubjectListModel({
    required this.totalSubjects,
    required this.readSubjects,
    required this.subjects,
  });

  // Factory constructor: bóc tách JSON danh sách môn học từ Backend
  factory SubjectListModel.fromJson(Map<String, dynamic> json) {
    var list = json['subjects'] as List? ?? [];
    List<SubjectItem> subjectItems = list
        .map((item) => SubjectItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return SubjectListModel(
      totalSubjects: (json['totalSubjects'] as num?)?.toInt() ?? 0,
      readSubjects: (json['readSubjects'] as num?)?.toInt() ?? 0,
      subjects: subjectItems,
    );
  }
}
