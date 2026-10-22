import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_endpoints.dart';
import '../../utils/url_helper.dart';
import '../models/admin_user_model.dart';
import '../models/admin_subject_model.dart';
import '../models/admin_lesson_model.dart';

class AdminApiService {
  // =========================================================================
  // 1. QUẢN LÝ TÀI KHOẢN (USER MANAGEMENT)
  // =========================================================================

  Future<List<AdminUserModel>> getUsers({String? keyword}) async {
    final uri = Uri.parse(ApiEndpoints.adminUsersAPI).replace(
      queryParameters: (keyword != null && keyword.trim().isNotEmpty)
          ? {'keyword': keyword.trim()}
          : null,
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => AdminUserModel.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải danh sách tài khoản: ${response.body}');
    }
  }

  Future<AdminUserModel> updateUserStatus(String id, bool isActive) async {
    final response = await http.put(
      Uri.parse('${ApiEndpoints.adminUsersAPI}/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isActive': isActive}),
    );
    if (response.statusCode == 200) {
      return AdminUserModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Lỗi cập nhật trạng thái: ${response.body}');
    }
  }

  Future<void> bulkUpdateStatus(List<String> ids, bool isActive) async {
    final response = await http.put(
      Uri.parse(ApiEndpoints.adminUsersBulkStatusAPI),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ids': ids, 'isActive': isActive}),
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi cập nhật trạng thái hàng loạt: ${response.body}');
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('${ApiEndpoints.adminUsersAPI}/$id'));
    if (response.statusCode != 200) {
      throw Exception('Lỗi xóa tài khoản: ${response.body}');
    }
  }

  Future<void> bulkDeleteUsers(List<String> ids) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.adminUsersBulkDeleteAPI),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ids': ids}),
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi xóa nhiều tài khoản: ${response.body}');
    }
  }

  // =========================================================================
  // 2. QUẢN LÝ MÔN HỌC (SUBJECT MANAGEMENT)
  // =========================================================================

  Future<List<AdminSubjectModel>> getSubjects({String? keyword}) async {
    final uri = Uri.parse(ApiEndpoints.adminSubjectsAPI).replace(
      queryParameters: (keyword != null && keyword.trim().isNotEmpty)
          ? {'keyword': keyword.trim()}
          : null,
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => AdminSubjectModel.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải danh sách môn học: ${response.body}');
    }
  }

  Future<AdminSubjectModel> createSubject(String code, String name, int displayOrder) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.adminSubjectsAPI),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code.trim(),
        'name': name.trim(),
        'displayOrder': displayOrder,
      }),
    );

    if (response.statusCode == 200) {
      return AdminSubjectModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(err['message'] ?? 'Lỗi thêm môn học');
    }
  }

  Future<AdminSubjectModel> updateSubject(String id, String code, String name, int displayOrder) async {
    final response = await http.put(
      Uri.parse('${ApiEndpoints.adminSubjectsAPI}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code.trim(),
        'name': name.trim(),
        'displayOrder': displayOrder,
      }),
    );

    if (response.statusCode == 200) {
      return AdminSubjectModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(err['message'] ?? 'Lỗi cập nhật môn học');
    }
  }

  Future<void> deleteSubject(String id) async {
    final response = await http.delete(Uri.parse('${ApiEndpoints.adminSubjectsAPI}/$id'));
    if (response.statusCode != 200) {
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(err['message'] ?? 'Lỗi xóa môn học');
    }
  }

  // =========================================================================
  // 3. QUẢN TRỊ BÀI HỌC & TÀI LIỆU PDF (LESSON & DOCUMENT MANAGEMENT)
  // =========================================================================

  Future<List<AdminLessonModel>> getLessons({String? subjectId, String? keyword}) async {
    final queryParams = <String, String>{};
    if (subjectId != null && subjectId.trim().isNotEmpty) {
      queryParams['subjectId'] = subjectId.trim();
    }
    if (keyword != null && keyword.trim().isNotEmpty) {
      queryParams['keyword'] = keyword.trim();
    }

    final uri = Uri.parse(ApiEndpoints.adminLessonsAPI).replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => AdminLessonModel.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải danh sách bài học: ${response.body}');
    }
  }

  Future<AdminLessonModel> createLesson({
    required String title,
    required String subjectId,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.adminLessonsAPI));
    request.fields['title'] = title.trim();
    request.fields['subjectId'] = subjectId.trim();

    if (fileBytes != null && fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return AdminLessonModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(err['message'] ?? 'Lỗi thêm bài học');
    }
  }

  Future<AdminLessonModel> updateLesson({
    required String id,
    String? title,
    String? subjectId,
    List<int>? fileBytes,
    String? fileName,
    bool removeFile = false,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse('${ApiEndpoints.adminLessonsAPI}/$id'));
    if (title != null) request.fields['title'] = title.trim();
    if (subjectId != null) request.fields['subjectId'] = subjectId.trim();
    if (removeFile) {
      request.fields['removeFile'] = 'true';
    } else if (fileBytes != null && fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return AdminLessonModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(err['message'] ?? 'Lỗi cập nhật bài học');
    }
  }

  Future<void> deleteLesson(String id) async {
    final response = await http.delete(Uri.parse('${ApiEndpoints.adminLessonsAPI}/$id'));
    if (response.statusCode != 200) {
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(err['message'] ?? 'Lỗi xóa bài học');
    }
  }

  // =========================================================================
  // 4. TIỆN ÍCH PHÂN GIẢI URL TÀI LIỆU (DOCUMENT URL RESOLUTION)
  // =========================================================================

  String getDocumentFileUrl({String? documentId, String? filePath}) {
    if (documentId != null && documentId.isNotEmpty) {
      return '${ApiEndpoints.documentsAPI}/$documentId/file';
    }
    if (filePath != null && filePath.isNotEmpty) {
      return UrlHelper.getFullPdfUrl(filePath);
    }
    return '';
  }
}
