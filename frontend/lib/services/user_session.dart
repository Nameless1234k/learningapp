import 'package:shared_preferences/shared_preferences.dart';

// =========================================================================================
// [TÊN FILE]: user_session.dart
// [VỊ TRÍ]: lib/services/user_session.dart
// [MỤC ĐÍCH]: Lưu trữ và quản lý phiên làm việc của người dùng (User Session) bền vững.
// - Lưu trữ đồng thời trong RAM (truy cập tức thì đồng bộ) và SharedPreferences/LocalStorage
//   (bền vững khi nhấn F5 tải lại trang Web hoặc đóng/mở lại app Mobile).
// - Quản lý phân quyền Role: 'ADMIN' hoặc 'USER' để bảo vệ các tuyến đường riêng biệt.
// =========================================================================================

class UserSession {
  // Các khóa lưu trữ trong LocalStorage / SharedPreferences
  static const String _keyUserId = 'user_session_user_id';
  static const String _keyToken = 'user_session_token';
  static const String _keyEmail = 'user_session_email';
  static const String _keyFullName = 'user_session_full_name';
  static const String _keyRole = 'user_session_role';

  // Biến tĩnh trong RAM để đọc đồng bộ tức thì ở mọi nơi trong mã nguồn
  static String? currentUserId;
  static String? currentToken;
  static String? currentEmail;
  static String? currentFullName;
  static String? currentRole;

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Kiểm tra xem người dùng đã đăng nhập hay chưa
  static bool get isLoggedIn => currentUserId != null && currentUserId!.trim().isNotEmpty;

  /// Kiểm tra xem người dùng có phải là Quản trị viên (ADMIN) không
  static bool get isAdmin => isLoggedIn && (currentRole?.toUpperCase() == 'ADMIN');

  /// Kiểm tra xem người dùng có phải là Học viên bình thường (USER) không
  static bool get isUser => isLoggedIn && (currentRole?.toUpperCase() != 'ADMIN');

  /// Khởi tạo và nạp phiên làm việc từ SharedPreferences/LocalStorage vào RAM
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getString(_keyUserId);
      currentToken = prefs.getString(_keyToken);
      currentEmail = prefs.getString(_keyEmail);
      currentFullName = prefs.getString(_keyFullName);
      currentRole = prefs.getString(_keyRole);
      _isInitialized = true;
    } catch (_) {
      _isInitialized = true;
    }
  }

  /// Lưu thông tin phiên đăng nhập vào cả RAM và SharedPreferences
  static Future<void> saveSession({
    required String userId,
    required String token,
    required String email,
    required String fullName,
    String role = 'USER',
  }) async {
    // 1. Cập nhật ngay trong RAM
    currentUserId = userId;
    currentToken = token;
    currentEmail = email;
    currentFullName = fullName;
    currentRole = role;
    _isInitialized = true;

    // 2. Lưu bền vững vào SharedPreferences/LocalStorage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keyFullName, fullName);
      await prefs.setString(_keyRole, role);
    } catch (_) {}
  }

  /// Đăng xuất - xóa sạch phiên làm việc trong cả RAM và SharedPreferences
  static Future<void> clear() async {
    // 1. Xóa ngay trong RAM
    currentUserId = null;
    currentToken = null;
    currentEmail = null;
    currentFullName = null;
    currentRole = null;

    // 2. Xóa khỏi SharedPreferences/LocalStorage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyToken);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyFullName);
      await prefs.remove(_keyRole);
    } catch (_) {}
  }
}
