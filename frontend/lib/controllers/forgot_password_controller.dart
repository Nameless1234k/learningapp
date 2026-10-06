import '../services/auth_service.dart';

class ForgotPasswordController {
  final AuthService _authService = AuthService();

  Future<String?> sendOtp(String email) async {
    if (email.isEmpty) {
      return "Vui lòng nhập email";
    }

    try {
      await _authService.forgotPassword(email);
      return null;
    } catch (e) {
      String errorMessage = "Đã xảy ra lỗi không xác định";
      String rawError = e.toString();

      if (rawError.startsWith("Exception: ")) {
        errorMessage = rawError.replaceAll("Exception: ", "");
      } else {
        errorMessage = rawError;
      }

      if (rawError.contains("SocketException") ||
          rawError.contains("Failed host lookup")) {
        errorMessage =
            "Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng!";
      } else if (rawError.contains("FormatException") ||
          rawError.contains("Unexpected character")) {
        errorMessage = "Hệ thống đang bảo trì hoặc server bị lỗi.";
      }

      return errorMessage;
    }
  }
}
