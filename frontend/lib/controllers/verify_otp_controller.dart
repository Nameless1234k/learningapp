import '../services/auth_service.dart';

// =========================================================================================
// [TÊN FILE]: verify_otp_controller.dart
// [VỊ TRÍ]: lib/controllers/verify_otp_controller.dart
// [MÔ HÌNH MVC]:
// - Model: Dữ liệu (email, otp)
// - View: VerifyOtpScreen (Màn hình giao diện chỉ lo vẽ nút, ô nhập, SnackBar)
// - Controller: File này (chịu trách nhiệm kiểm tra logic hợp lệ, gọi Service mạng)
// [GHI CHÚ DÀNH CHO NGƯỜI BIẾT JAVA / PYTHON]:
// - Giống như class Controller / Service trong Java / Python, hoàn toàn không dính tới UI.
// - Từ khóa "async / await" giống hệt async / await trong Python hoặc CompletableFuture trong Java.
// - "Future<String?>" nghĩa là hàm bất đồng bộ trả về String (hoặc null nếu thành công).
// =========================================================================================

class VerifyOtpController {
  // Khởi tạo đối tượng AuthService để giao tiếp với Backend API qua giao thức HTTP
  final AuthService _authService = AuthService();

  // Hàm xác thực mã OTP
  // @param email: Địa chỉ email người dùng
  // @param otp: Chuỗi 6 chữ số ghép từ 6 ô nhập liệu
  // @return: String thông báo lỗi (nếu thất bại), hoặc null (nếu xác thực thành công)
  Future<String?> verifyOtp(String email, String otp) async {
    // 1. Kiểm tra dữ liệu đầu vào (Validation nghiệp vụ)
    if (otp.length < 6) {
      return "Vui lòng nhập đủ 6 chữ số";
    }

    // 2. Gọi API Backend để kiểm tra mã OTP
    try {
      await _authService.verifyOtp(email, otp);
      // Nếu không ném ra exception -> Xác thực thành công!
      return null;
    } catch (e) {
      // 3. Bắt các ngoại lệ (Exception) và chuyển hóa thành thông báo dễ hiểu
      return _parseErrorMessage(e);
    }
  }

  // Hàm gửi lại mã OTP mới về email
  Future<String?> resendOtp(String email) async {
    if (email.isEmpty) {
      return "Vui lòng cung cấp email";
    }

    try {
      await _authService.forgotPassword(email);
      return null; // Gửi lại mã thành công
    } catch (e) {
      return _parseErrorMessage(e);
    }
  }

  // Hàm tiện ích phân loại lỗi mạng / máy chủ
  String _parseErrorMessage(dynamic e) {
    String rawError = e.toString();
    String errorMessage = "Đã xảy ra lỗi không xác định";

    // Loại bỏ tiền tố "Exception: " nếu có
    if (rawError.startsWith("Exception: ")) {
      errorMessage = rawError.replaceAll("Exception: ", "");
    } else {
      errorMessage = rawError;
    }

    // Bắt lỗi mất kết nối mạng (tương đương IOException / ConnectionRefused trong Java)
    if (rawError.contains("SocketException") ||
        rawError.contains("Failed host lookup")) {
      errorMessage = "Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng!";
    }
    // Bắt lỗi phản hồi không phải JSON (ví dụ server crash hoặc lỗi 502/503 trả về HTML)
    else if (rawError.contains("FormatException") ||
        rawError.contains("Unexpected character")) {
      errorMessage = "Hệ thống đang bảo trì hoặc server bị lỗi.";
    }

    return errorMessage;
  }
}
