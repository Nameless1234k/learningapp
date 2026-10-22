import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_endpoints.dart';
import '../models/subject_model.dart';
import '../models/lesson_model.dart';

// =========================================================================================
// [TÊN FILE: subject_service.dart]
// [VỊ TRÍ]: lib/services/subject_service.dart
// [MỤC ĐÍCH]: Tầng Service chịu trách nhiệm gửi HTTP Request lên Backend Spring Boot
// để lấy dữ liệu môn học, tiến độ và danh sách bài học theo đúng đặc tả Use case "Xem tài liệu".
// =========================================================================================

class SubjectService {
  
  /// HÀM 1: Lấy danh sách toàn bộ môn học và tiến độ hoàn thành của người dùng (Screen 9)
  /// - Endpoint: GET /api/subjects?userId={userId}
  /// - Trả về: Đối tượng SubjectListModel chứa tổng số môn, số môn đã đọc và list chi tiết
  Future<SubjectListModel> getSubjects({String? userId}) async {
    // 1. Tạo URL truy vấn, gắn kèm tham số userId nếu người dùng đã đăng nhập
    String url = ApiEndpoints.subjectsAPI;
    if (userId != null && userId.isNotEmpty) {
      url += '?userId=$userId';
    }

    // 2. Gửi yêu cầu HTTP GET đến máy chủ
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // 3. Xử lý mã phản hồi từ máy chủ
    if (response.statusCode == 200) {
      // Giải mã JSON UTF-8 để hiển thị đúng dấu tiếng Việt
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Bóc tách JSON thành Model của Flutter
      return SubjectListModel.fromJson(data);
    } else {
      // Ném ra thông báo lỗi nếu API gặp sự cố
      throw Exception('Không thể tải danh sách tài liệu môn học (Mã lỗi: ${response.statusCode})');
    }
  }

  /// HÀM 2: Lấy danh sách các bài học thuộc một môn học cụ thể 
  /// - Endpoint: GET /api/subjects/{subjectId}/lessons?userId={userId}
  /// - Trả về: Đối tượng SubjectDetailModel chứa tên môn, tổng số bài, % tiến độ và danh sách bài
  Future<SubjectDetailModel> getSubjectLessons(String subjectId, {String? userId}) async {
    // 1. Tạo đường dẫn API tương ứng với môn học được chọn
    String url = '${ApiEndpoints.subjectsAPI}/$subjectId/lessons';
    if (userId != null && userId.isNotEmpty) {
      url += '?userId=$userId';
    }

    // 2. Gửi yêu cầu HTTP GET
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // 3. Xử lý kết quả trả về
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return SubjectDetailModel.fromJson(data);
    } else {
      throw Exception('Không thể tải danh sách bài học của môn này (Mã lỗi: ${response.statusCode})');
    }
  }

  /// HÀM 3: Tự động cập nhật tiến độ đọc bài học (Screen 14 / PdfViewer)
  /// - Endpoint: POST /api/subjects/lessons/{lessonId}/progress?userId={userId}
  /// - Gửi thông tin: pageNumber, totalPages, secondsSpent
  /// - Trả về: Map kết quả từ Backend chứa trạng thái mới và subjectProgressPercent
  Future<Map<String, dynamic>> updateLessonProgress({
    required String lessonId,
    required String userId,
    int pageNumber = 1,
    int totalPages = 1,
    int secondsSpent = 0,
  }) async {
    final url = '${ApiEndpoints.lessonsAPI}/$lessonId/progress?userId=$userId';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pageNumber': pageNumber,
        'totalPages': totalPages,
        'secondsSpent': secondsSpent,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      throw Exception('Không thể cập nhật tiến độ bài học (Mã lỗi: ${response.statusCode})');
    }
  }
}

