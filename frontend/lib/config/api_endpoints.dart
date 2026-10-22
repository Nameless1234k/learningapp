import 'package:flutter/foundation.dart';

// =========================================================================================
// [TÊN FILE: api_endpoints.dart]
// [VỊ TRÍ]: lib/config/api_endpoints.dart
// [MỤC ĐÍCH]: Cấu hình tập trung các hằng số endpoint tĩnh (static const) của toàn bộ ứng dụng.
// Tuân thủ nghiêm ngặt mô hình MVC:
// - Chỉ chứa hằng số đường dẫn tĩnh (không chứa logic nghiệp vụ, if-else hay hàm ghép nối URL).
// - Các tham số động (path variables, query parameters) và xử lý link tải được đưa về
//   tầng Service (AdminApiService, SubjectService) và tầng Util (UrlHelper).
// =========================================================================================

class ApiEndpoints {
  // Tự động nhận diện nền tảng: Nếu chạy Web trên máy tính dùng localhost, nếu Mobile thì dùng IP máy
  static const String baseUrl = kIsWeb 
      ? 'http://localhost:8080/api' 
      : 'http://192.168.252.18:8080/api'; 
  
  // 1. Phân hệ Xác thực (Authentication)
  static const String loginAPI = '$baseUrl/auth/login';
  static const String registerAPI = '$baseUrl/auth/register';
  static const String forgotPasswordAPI = '$baseUrl/auth/forgot-password';
  static const String verifyOtpAPI = '$baseUrl/auth/verify-otp';
  static const String resetPasswordAPI = '$baseUrl/auth/reset-password';

  // 2. Phân hệ Dành cho Học viên / Mobile (Subjects & Lessons)
  static const String subjectsAPI = '$baseUrl/subjects';
  static const String lessonsAPI = '$baseUrl/subjects/lessons';

  // 3. Phân hệ Quản trị Web (Admin Management)
  static const String adminUsersAPI = '$baseUrl/admin/users';
  static const String adminUsersBulkStatusAPI = '$baseUrl/admin/users/bulk-status';
  static const String adminUsersBulkDeleteAPI = '$baseUrl/admin/users/bulk-delete';
  static const String adminSubjectsAPI = '$baseUrl/admin/subjects';
  static const String adminLessonsAPI = '$baseUrl/admin/lessons';

  // 4. Phân hệ Tài liệu & Tệp tin (Documents & Files)
  static const String documentsAPI = '$baseUrl/documents';
  static const String documentFilesAPI = '$baseUrl/documents/files';
}
