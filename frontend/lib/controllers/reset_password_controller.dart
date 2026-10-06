import '../services/auth_service.dart';

class ResetPasswordController {
  final AuthService _authService = AuthService();

  Future<String?> resetPassword(
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (password.isEmpty || confirmPassword.isEmpty) {
      return "Vui lòng nhập đầy đủ thông tin";
    }

    if (password.length < 8) {
      return "Mật khẩu phải dài ít nhất 8 ký tự";
    }

    if (password != confirmPassword) {
      return "Mật khẩu không khớp";
    }

    try {
      await _authService.resetPassword(email, password);
      return null;
    } catch (e) {
      String errorMessage = "Đã xảy ra lỗi không xác định";
      String rawError = e.toString();
      
      if (rawError.startsWith("Exception: ")) {
        errorMessage = rawError.replaceAll("Exception: ", "");
      } else {
        errorMessage = rawError;
      }

      if (rawError.contains("SocketException") || rawError.contains("Failed host lookup")) {
        errorMessage = "Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng!";
      } else if (rawError.contains("FormatException") || rawError.contains("Unexpected character")) {
        errorMessage = "Hệ thống đang bảo trì hoặc server bị lỗi.";
      }

      return errorMessage;
    }
  }
}
