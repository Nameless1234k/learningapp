import '../../services/auth_service.dart';
import '../../services/user_session.dart';

class AdminAuthController {
  final AuthService _authService = AuthService();

  Future<String?> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return 'Vui lòng nhập đầy đủ Email và Mật khẩu!';
    }

    try {
      final authData = await _authService.login(email.trim(), password.trim());
      
      final role = authData['role']?.toString().toUpperCase() ?? 'USER';
      if (role != 'ADMIN') {
        UserSession.clear();
        return 'Tài khoản của bạn không có quyền truy cập trang Quản trị!';
      }

      // Lưu phiên làm việc Admin bền vững (LocalStorage)
      await UserSession.saveSession(
        userId: authData['userId']?.toString() ?? '',
        token: authData['token']?.toString() ?? '',
        email: authData['email']?.toString() ?? email,
        fullName: authData['fullName']?.toString() ?? 'Quản trị viên',
        role: 'ADMIN',
      );

      return null; // Đăng nhập thành công
    } catch (e) {
      String rawError = e.toString();
      if (rawError.startsWith("Exception: ")) {
        return rawError.replaceAll("Exception: ", "");
      }
      return rawError;
    }
  }
}
