import '../services/auth_service.dart';
import '../utils/app_validator.dart';

// =========================================================================================
// [TÊN FILE: register_controller.dart]
// [VỊ TRÍ]: lib/controllers/register_controller.dart
// [KẾT NỐI]: Screen (Giao diện) sẽ gọi hàm trong file này. File này lại gọi Service để lấy data.
// [MỤC ĐÍCH]: Chỉ chứa LOGIC XỬ LÝ (như kiểm tra dữ liệu, gọi API). 
// Tối ưu hóa code bằng cách tái sử dụng AppValidator tập trung, gọn gàng và không lặp lại code.
// =========================================================================================

class RegisterController {
  final AuthService _authService = AuthService();

  // Hàm register trả về chuỗi String (nếu bị lỗi) hoặc null (nếu đăng ký thành công).
  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    String? phone, // Số điện thoại có thể null (không bắt buộc)
    required String password,
    required String confirmPassword,
  }) async {
    // 1. Kiểm tra dữ liệu đầu vào (Validation) bằng AppValidator dùng chung
    final validationError = AppValidator.validateRequired([firstName, lastName, email, password, confirmPassword]) ??
        AppValidator.validateEmail(email) ??
        AppValidator.validatePassword(password, confirmPassword: confirmPassword, minLength: 8) ??
        AppValidator.validatePhone(phone);

    if (validationError != null) {
      return validationError;
    }

    final trimmedEmail = email.trim();

    // 2. Xử lý gọi API
    try {
      await _authService.register(firstName, lastName, trimmedEmail, phone, password);
      return null; // Không có lỗi -> Đăng ký THÀNH CÔNG!
    } catch (e) {
      // 3. Xử lý Lỗi ngoại lệ bằng AppValidator dùng chung (chỉ 1 dòng)
      return AppValidator.formatException(e);
    }
  }
}
