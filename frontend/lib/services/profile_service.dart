import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_endpoints.dart';
import '../models/user_profile_model.dart';
import 'user_session.dart';

// =========================================================================================
// [TÊN FILE: profile_service.dart]
// [VỊ TRÍ]: lib/services/profile_service.dart
// [MỤC ĐÍCH]: Tầng Service gọi HTTP API Backend cho phân hệ Cá nhân (Profile, Settings, Stats)
// =========================================================================================

class ProfileService {
  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (UserSession.currentToken != null && UserSession.currentToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${UserSession.currentToken}';
    }
    return headers;
  }

  /// Lấy thông tin cá nhân của người dùng
  Future<UserProfileModel> getProfile() async {
    final userId = UserSession.currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }

    final url = '${ApiEndpoints.userProfileAPI}?userId=$userId';
    final response = await http.get(Uri.parse(url), headers: _buildHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return UserProfileModel.fromJson(data);
    } else {
      throw Exception('Không thể tải thông tin cá nhân: ${response.body}');
    }
  }

  /// Cập nhật thông tin cá nhân (Họ, Tên, Số điện thoại)
  Future<UserProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final userId = UserSession.currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }

    final url = '${ApiEndpoints.userProfileAPI}?userId=$userId';
    final body = jsonEncode({
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'phone': phone?.trim(),
    });

    final response = await http.put(
      Uri.parse(url),
      headers: _buildHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final profile = UserProfileModel.fromJson(data);

      // Cập nhật lại thông tin trong UserSession để các màn hình khác (Home, Drawer) tự đổi tên
      await UserSession.saveSession(
        userId: profile.id,
        token: UserSession.currentToken ?? '',
        email: profile.email,
        fullName: profile.fullName,
        role: profile.role,
      );

      return profile;
    } else {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(data['message'] ?? 'Lỗi cập nhật thông tin cá nhân');
    }
  }

  /// Đổi mật khẩu
  Future<String> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final userId = UserSession.currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }

    final url = '${ApiEndpoints.changePasswordAPI}?userId=$userId';
    final body = jsonEncode({
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });

    final response = await http.put(
      Uri.parse(url),
      headers: _buildHeaders(),
      body: body,
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && data['success'] == true) {
      return data['message'] ?? 'Đổi mật khẩu thành công!';
    } else {
      throw Exception(data['message'] ?? 'Đổi mật khẩu thất bại!');
    }
  }

  /// Lấy thống kê trắc nghiệm theo Screen 22
  Future<UserStatisticsModel> getStatistics() async {
    final userId = UserSession.currentUserId;
    if (userId == null || userId.isEmpty) {
      return UserStatisticsModel(
        hasData: false,
        totalQuestions: 0,
        message: 'Chưa có thống kê',
        description:
            'Bạn chưa hoàn thành câu hỏi trắc nghiệm nào. Hãy làm bài luyện tập để theo dõi điểm số tại đây nhé!',
        subjectScores: [],
      );
    }

    try {
      final url = '${ApiEndpoints.userStatisticsAPI}?userId=$userId';
      final response = await http.get(Uri.parse(url), headers: _buildHeaders()).timeout(
            const Duration(seconds: 4),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return UserStatisticsModel.fromJson(data);
      }
    } catch (_) {}

    // Fallback mặc định khi chưa có dữ liệu hoặc offline
    return UserStatisticsModel(
      hasData: false,
      totalQuestions: 0,
      message: 'Chưa có thống kê',
      description:
          'Bạn chưa hoàn thành câu hỏi trắc nghiệm nào. Hãy làm bài luyện tập để theo dõi điểm số tại đây nhé!',
      subjectScores: [],
    );
  }
}
