import '../services/auth_service.dart';

// =========================================================================================
// [TÊN FILE: register_controller.dart]
// [VỊ TRÍ]: lib/controllers/register_controller.dart
// [KẾT NỐI]: Screen (Giao diện) sẽ gọi hàm trong file này. File này lại gọi Service để lấy data.
// [MỤC ĐÍCH]: Chỉ chứa LOGIC XỬ LÝ (như kiểm tra dữ liệu, gọi API). 
// TUYỆT ĐỐI KHÔNG chứa code giao diện UI (như BuildContext, SnackBar, hay Dialog) ở đây.
// =========================================================================================

class RegisterController {
  final AuthService _authService = AuthService();

  // Biểu thức chính quy (Regex) kiểm tra định dạng email chuẩn:
  // - Phần tên trước @: các chữ cái, số, dấu chấm, gạch dưới, %, +, -
  // - Ký tự bắt buộc: @
  // - Phần tên miền: tên miền cấp 2 (ví dụ: gmail, yahoo)
  // - Phần mở rộng: .com, .vn, .edu... (phải có dấu chấm và ít nhất 2 ký tự chữ cái)
  // Chặn hoàn toàn các lỗi sai như: @gmailcom, @mail.com, user@gmailcom, user@, user...
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
  );

  // Hàm register không nhận BuildContext nữa. 
  // Nó sẽ trả về chuỗi String (nếu bị lỗi) hoặc null (nếu đăng ký thành công).
  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    String? phone, // Số điện thoại có thể null (không bắt buộc)
    required String password,
    required String confirmPassword,
  }) async {
    // 1. Kiểm tra dữ liệu đầu vào (Validation)
    // 1.1 Kiểm tra không được để trống bất kỳ trường bắt buộc nào
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return "Vui lòng nhập đầy đủ thông tin";
    }

    // 1.2 Kiểm tra định dạng email (bắt các lỗi như: @gmailcom, @mail.com, user@gmailcom)
    final trimmedEmail = email.trim();
    if (!_emailRegex.hasMatch(trimmedEmail)) {
      return "Email không đúng định dạng";
    }

    // 1.3 Kiểm tra độ dài mật khẩu tối thiểu 8 ký tự
    if (password.length < 8) {
      return "Mật khẩu phải dài ít nhất 8 ký tự";
    }

    // 1.4 Kiểm tra mật khẩu xác nhận phải trùng khớp
    if (password != confirmPassword) {
      return "Mật khẩu xác nhận không khớp";
    }

    // 2. Xử lý gọi API
    try {
      // Gọi qua AuthService để bắn data lên Backend
      await _authService.register(firstName, lastName, trimmedEmail, phone, password);
      
      return null; // Trả về null -> Không có lỗi -> Đăng ký THÀNH CÔNG!
      
    } catch (e) {
      // 3. Xử lý Lỗi ngoại lệ
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

      // Thay vì tự hiển thị thông báo lỗi, Controller ném lỗi đó về lại cho Screen hiển thị
      return errorMessage; 
    }
  }
}
