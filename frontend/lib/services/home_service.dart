import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_endpoints.dart';
import '../models/home_dashboard_model.dart';
import 'user_session.dart';

// =========================================================================================
// [TÊN FILE: home_service.dart]
// [VỊ TRÍ]: lib/services/home_service.dart
// [MỤC ĐÍCH]: Tầng Service (Pattern MVC) gọi HTTP API Backend lấy dữ liệu Trang chủ
// - Tự động đính kèm Bearer JWT Token để xác thực với Backend.
// - Tự động xóa phiên (UserSession.clear()) nếu nhận mã 401 (token hết hạn hoặc máy chủ restart).
// =========================================================================================

class HomeService {
  /// Lấy thông tin Trang chủ và Phiên học hôm nay theo userId
  Future<HomeDashboardModel> getDashboard(String userId) async {
    final url = '${ApiEndpoints.homeDashboardAPI}?userId=$userId';

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (UserSession.currentToken != null && UserSession.currentToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${UserSession.currentToken}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return HomeDashboardModel.fromJson(data);
    } else if (response.statusCode == 401) {
      await UserSession.clear();
      throw Exception('Phiên đăng nhập đã hết hạn hoặc máy chủ đã khởi động lại.');
    } else {
      throw Exception('Không thể tải dữ liệu trang chủ (Mã lỗi: ${response.statusCode})');
    }
  }
}
