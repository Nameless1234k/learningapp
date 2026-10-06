import '../services/auth_service.dart';

// [TÊN FILE: login_controller.dart]
// [VỊ TRÍ]: lib/controllers/login_controller.dart
// [KẾT NỐI]: Màn hình Login (Screen) sẽ gọi hàm login() ở đây. File này lại giao tiếp tiếp với AuthService.
// [MỤC ĐÍCH]: File này CHỈ CHỨA LOGIC XỬ LÝ (kiểm tra đầu vào, gọi mạng, trả về kết quả). 
// Hoàn toàn không dính dáng đến UI (không BuildContext, không báo lỗi SnackBar, không chuyển trang).

class LoginController {
  final AuthService _authService = AuthService();

  // Hàm trả về String nếu gặp lỗi. Trả về null nếu thành công.
  Future<String?> login({required String email, required String password}) async {
    // 1. Kiểm tra dữ liệu (Validation)
    if (email.isEmpty || password.isEmpty) {
      return "Vui lòng nhập đầy đủ thông tin";
    }

    // 2. Logic gọi API
    try {
      await _authService.login(email, password);
      // Nếu không văng lỗi (catch) nghĩa là API chạy thành công
      return null;
      
    } catch (e) {
      // 3. Logic xử lý lỗi thông minh
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

      return errorMessage; // Trả lỗi về cho Screen để vẽ ra màn hình
    }
  }
}

