import '../models/user_profile_model.dart';
import '../services/profile_service.dart';
import '../utils/app_validator.dart';

// =========================================================================================
// [TÊN FILE: profile_controller.dart]
// [VỊ TRÍ]: lib/controllers/profile_controller.dart
// [MỤC ĐÍCH]: Tầng Controller điều phối nghiệp vụ cho toàn bộ phân hệ Cá nhân (Profile):
// - Chuẩn hóa kiến trúc MVC: Tách biệt hoàn toàn logic nghiệp vụ ra khỏi View (Screen).
// - View chỉ quản lý hiển thị (TextEditingController, Loading, SnackBar, Navigation).
// - Controller đảm nhiệm validation dữ liệu đầu vào và giao tiếp với Service.
// - Tối ưu hóa code (DRY): Tái sử dụng AppValidator chỉ bằng 1 dòng kiểm tra.
// - Đồng bộ hóa điều kiện kiểm tra (Họ tên bắt buộc, Mật khẩu >= 8 ký tự, xác nhận khớp)
//   giống hệt màn hình Đăng ký (Register) và Đặt lại mật khẩu (Reset Password).
// =========================================================================================

class ProfileController {
  final ProfileService _profileService;

  ProfileController({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  /// 1. Lấy thông tin cá nhân của người dùng
  Future<UserProfileModel> getProfile() async {
    return await _profileService.getProfile();
  }

  /// 2. Lấy số liệu thống kê điểm số
  Future<UserStatisticsModel> getStatistics() async {
    return await _profileService.getStatistics();
  }

  /// 3. Cập nhật thông tin cá nhân (Họ, Tên, Số điện thoại)
  /// Trả về null nếu thành công, hoặc chuỗi String thông báo lỗi nếu thất bại.
  Future<String?> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    // Tận dụng 1 dòng kiểm tra Họ, Tên và Số điện thoại (giống hệt phần Đăng ký)
    final validationError = AppValidator.validateNames(firstName, lastName) ?? AppValidator.validatePhone(phone);
    if (validationError != null) {
      return validationError;
    }

    try {
      await _profileService.updateProfile(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      );
      return null; // Không có lỗi -> Cập nhật thành công!
    } catch (e) {
      return AppValidator.formatException(e);
    }
  }

  /// 4. Đổi mật khẩu tài khoản
  /// Trả về null nếu thành công, hoặc chuỗi String thông báo lỗi nếu thất bại.
  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // 1. Tận dụng kiểm tra rỗng và điều kiện mật khẩu (>= 8 ký tự, khớp xác nhận) bằng 1 dòng
    final validationError = AppValidator.validateRequired([oldPassword, newPassword, confirmPassword]) ??
        AppValidator.validatePassword(newPassword, confirmPassword: confirmPassword, minLength: 8);

    if (validationError != null) {
      return validationError;
    }

    // 2. Kiểm tra mật khẩu mới không được trùng mật khẩu cũ
    if (oldPassword.trim() == newPassword.trim()) {
      return "Mật khẩu mới không được trùng với mật khẩu cũ!";
    }

    // 3. Gọi Service để gửi yêu cầu lên Backend
    try {
      await _profileService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return null; // Không có lỗi -> Đổi mật khẩu thành công!
    } catch (e) {
      return AppValidator.formatException(e);
    }
  }
}
