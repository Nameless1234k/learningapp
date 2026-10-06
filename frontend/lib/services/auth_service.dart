import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_endpoints.dart';

class AuthService {
  // Thực hiện gọi API đăng nhập. Hàm sẽ gửi email và password lên server.
  // Trả về một đối tượng chứa token và thông tin user nếu thành công.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.loginAPI),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw error['message'] ?? 'Đăng nhập thất bại';
    }
  }

  // Thực hiện đăng ký tài khoản mới.
  Future<Map<String, dynamic>> register(
      String firstName, String lastName, String email, String? phone, String password) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.registerAPI),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw error['message'] ?? 'Đăng ký thất bại';
    }
  }

  // Gửi yêu cầu quên mật khẩu, API sẽ trả về thông báo gửi OTP.
  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.forgotPasswordAPI),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw error['message'] ?? 'Lỗi gửi yêu cầu';
    }
  }

  // Gửi mã OTP lên server để xác thực
  Future<void> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.verifyOtpAPI),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw error['message'] ?? 'Mã OTP không hợp lệ';
    }
  }

  // Cập nhật mật khẩu mới
  Future<void> resetPassword(String email, String newPassword) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.resetPasswordAPI),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw error['message'] ?? 'Lỗi đổi mật khẩu';
    }
  }
}
