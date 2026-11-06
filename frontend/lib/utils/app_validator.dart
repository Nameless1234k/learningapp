// =========================================================================================
// [TÊN FILE: app_validator.dart]
// [VỊ TRÍ]: lib/utils/app_validator.dart
// [MỤC ĐÍCH]: Tiện ích kiểm tra tính hợp lệ dữ liệu (Validator Helper) dùng chung toàn Frontend:
// - Đảm bảo nguyên tắc DRY (Don't Repeat Yourself): Cung cấp các hàm kiểm tra chỉ bằng 1 dòng.
// - Đồng bộ hóa điều kiện kiểm tra dữ liệu và thông báo lỗi giữa Đăng ký (Register), Đổi mật khẩu
//   và Cập nhật hồ sơ cá nhân (Profile).
// - Định dạng và bóc tách chuỗi ngoại lệ (Exception) thành thông điệp thân thiện với người dùng.
// =========================================================================================

class AppValidator {
  // Biểu thức Regex kiểm tra định dạng email chuẩn: giống register_controller.dart
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
  );

  // Biểu thức Regex kiểm tra số điện thoại (9 đến 11 chữ số)
  static final RegExp _phoneRegex = RegExp(r'^[0-9]{9,11}$');

  /// 1. Kiểm tra danh sách các trường bắt buộc không được để trống
  /// Trả về chuỗi lỗi nếu có trường rỗng, trả về null nếu hợp lệ.
  static String? validateRequired(List<String?> fields) {
    for (final field in fields) {
      if (field == null || field.trim().isEmpty) {
        return "Vui lòng nhập đầy đủ thông tin";
      }
    }
    return null;
  }

  /// 2. Kiểm tra Họ và Tên (dùng chung cho cả Đăng ký và Cập nhật cá nhân)
  static String? validateNames(String? firstName, String? lastName) {
    if (firstName == null || firstName.trim().isEmpty || lastName == null || lastName.trim().isEmpty) {
      return "Vui lòng nhập đầy đủ thông tin";
    }
    return null;
  }

  /// 3. Kiểm tra định dạng Email
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return "Vui lòng nhập đầy đủ thông tin";
    }
    if (!_emailRegex.hasMatch(email.trim())) {
      return "Email không đúng định dạng";
    }
    return null;
  }

  /// 4. Kiểm tra số điện thoại (nếu người dùng có nhập)
  static String? validatePhone(String? phone) {
    if (phone != null && phone.trim().isNotEmpty) {
      if (!_phoneRegex.hasMatch(phone.trim())) {
        return "Số điện thoại không hợp lệ (9 - 11 chữ số)!";
      }
    }
    return null;
  }

  /// 5. Kiểm tra mật khẩu (độ dài tối thiểu 8 ký tự, kiểm tra trùng khớp xác nhận)
  /// Đồng bộ hoàn toàn với màn hình Đăng ký và Đặt lại mật khẩu!
  static String? validatePassword(
    String? password, {
    String? confirmPassword,
    int minLength = 8,
  }) {
    if (password == null || password.isEmpty) {
      return "Vui lòng nhập đầy đủ thông tin";
    }
    if (password.length < minLength) {
      return "Mật khẩu phải dài ít nhất $minLength ký tự";
    }
    if (confirmPassword != null && password != confirmPassword) {
      return "Mật khẩu xác nhận không khớp";
    }
    return null;
  }

  /// 6. Bóc tách và định dạng Exception thành thông báo lỗi dễ hiểu cho người dùng
  /// Rút gọn toàn bộ logic try-catch lặp đi lặp lại chỉ còn 1 dòng duy nhất!
  static String formatException(Object e) {
    String rawError = e.toString();
    String errorMessage = "Đã xảy ra lỗi không xác định";

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
