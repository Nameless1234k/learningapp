import 'dart:io';
import '../models/subject_model.dart';
import '../models/lesson_model.dart';
import '../services/subject_service.dart';
import '../services/user_session.dart';
import '../utils/url_helper.dart';

// =========================================================================================
// [TÊN FILE: subject_controller.dart]
// [VỊ TRÍ]: lib/controllers/subject_controller.dart
// [MỤC ĐÍCH]: Controller trong mô hình MVC cho phần Môn học và Tài liệu.
// - Tiếp nhận yêu cầu từ Screen (Giao diện)
// - Gọi tầng Service để lấy dữ liệu từ Backend
// - Tự động lấy UserSession.currentUserId nếu không truyền vào
// - Bắt và chuẩn hóa các thông báo lỗi để Screen hiển thị.
// =========================================================================================

class SubjectController {
  // Khởi tạo instance của tầng Service
  final SubjectService _subjectService = SubjectService();

  /// HÀM 1: Lấy danh sách môn học cho Screen 9
  /// - Trả về: SubjectListModel nếu thành công
  Future<SubjectListModel> loadSubjects({String? userId}) async {
    final effectiveUserId = userId ?? UserSession.currentUserId;
    try {
      return await _subjectService.getSubjects(userId: effectiveUserId);
    } on SocketException {
      throw 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng WiFi/3G!';
    } catch (e) {
      String rawError = e.toString();
      if (rawError.startsWith('Exception: ')) {
        throw rawError.replaceAll('Exception: ', '');
      }
      throw 'Đã xảy ra lỗi khi tải danh sách môn học: $rawError';
    }
  }

  /// HÀM 2: Lấy chi tiết bài học của môn cho Screen 14
  /// - Trả về: SubjectDetailModel nếu thành công
  Future<SubjectDetailModel> loadSubjectLessons(String subjectId, {String? userId}) async {
    final effectiveUserId = userId ?? UserSession.currentUserId;
    try {
      return await _subjectService.getSubjectLessons(subjectId, userId: effectiveUserId);
    } on SocketException {
      throw 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại kết nối mạng!';
    } catch (e) {
      String rawError = e.toString();
      if (rawError.startsWith('Exception: ')) {
        throw rawError.replaceAll('Exception: ', '');
      }
      throw 'Đã xảy ra lỗi khi tải danh sách bài học: $rawError';
    }
  }

  /// HÀM 3: Tự động đồng bộ tiến độ đọc bài học (Zero-click)
  /// - Được gọi ngầm từ PdfViewerScreen (khi đạt 30s hoặc khi thoát)
  Future<Map<String, dynamic>?> syncLessonProgress({
    required String lessonId,
    String? userId,
    int pageNumber = 1,
    int totalPages = 1,
    int secondsSpent = 0,
  }) async {
    final effectiveUserId = userId ?? UserSession.currentUserId;
    if (effectiveUserId == null || effectiveUserId.isEmpty) {
      return null;
    }

    try {
      return await _subjectService.updateLessonProgress(
        lessonId: lessonId,
        userId: effectiveUserId,
        pageNumber: pageNumber,
        totalPages: totalPages,
        secondsSpent: secondsSpent,
      );
    } catch (_) {
      // Đồng bộ ngầm, không làm gián đoạn trải nghiệm người dùng
      return null;
    }
  }

  /// HÀM 4: Kiểm tra bài học đã có tài liệu PDF đính kèm hay chưa
  bool hasPdfDocument(String? pdfUrl) {
    return pdfUrl != null && pdfUrl.trim().isNotEmpty;
  }

  /// HÀM 5: Chuẩn hóa đường dẫn tài liệu thành URL tuyệt đối thông qua UrlHelper
  String resolvePdfUrl(String pdfPath) {
    return UrlHelper.getFullPdfUrl(pdfPath);
  }
}
