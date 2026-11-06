import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_endpoints.dart';
import 'user_session.dart';

// =========================================================================================
// [TÊN FILE: theme_service.dart]
// [VỊ TRÍ]: lib/services/theme_service.dart
// [MỤC ĐÍCH]: Quản lý trạng thái Theme Sáng / Tối (Dark / Light Mode) toàn ứng dụng:
// - Sử dụng ValueNotifier để kích hoạt chuyển đổi tức thì trên giao diện mà không bị giật lag.
// - Lưu trữ SharedPreferences/LocalStorage để hiển thị đúng ngay khi mở app (<5ms).
// - Đồng bộ với Database PostgreSQL qua API Backend khi có mạng.
// =========================================================================================

class ThemeService {
  static const String _keyDarkMode = 'app_theme_dark_mode';
  static SharedPreferences? _prefs;

  static String _getUserKey(String? userId) => 'app_theme_dark_mode_${userId ?? "default"}';

  // ValueNotifier quản lý ThemeMode cho toàn app
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  /// Khởi tạo theme từ bộ nhớ cục bộ lúc bật app:
  /// CHỈ áp dụng Dark Mode khi học viên ĐÃ ĐĂNG NHẬP.
  /// Nếu chưa đăng nhập (màn hình Login, Register...) thì luôn luôn là ThemeMode.light!
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (UserSession.isLoggedIn && UserSession.currentUserId != null) {
        final userKey = _getUserKey(UserSession.currentUserId);
        final isDark = _prefs?.getBool(userKey) ?? _prefs?.getBool(_keyDarkMode) ?? false;
        themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
      } else {
        themeModeNotifier.value = ThemeMode.light;
      }
    } catch (_) {
      themeModeNotifier.value = ThemeMode.light;
    }
  }

  /// Nạp cấu hình Dark Mode khi học viên đăng nhập thành công
  static Future<void> loadUserSettings(String userId) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final userKey = _getUserKey(userId);
      final isDark = _prefs?.getBool(userKey) ?? _prefs?.getBool(_keyDarkMode) ?? false;
      themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

      // Nạp cấu hình từ Backend ngầm nếu có kết nối
      loadSettingsFromBackend(userId);
    } catch (_) {}
  }

  /// Đặt lại theme về Light Mode khi đăng xuất
  static void resetToLight() {
    themeModeNotifier.value = ThemeMode.light;
  }

  /// Chuyển đổi trạng thái Dark Mode từ nút công tắc Switch
  static Future<void> toggleDarkMode(bool enabled) async {
    // 1. Cập nhật ngay UI để người dùng thấy mượt mà không độ trễ
    themeModeNotifier.value = enabled ? ThemeMode.dark : ThemeMode.light;

    // 2. Lưu bền vững vào máy khách theo User ID đã đăng nhập
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final userKey = _getUserKey(UserSession.currentUserId);
      await _prefs?.setBool(userKey, enabled);
      await _prefs?.setBool(_keyDarkMode, enabled);
    } catch (_) {}

    // 3. Đồng bộ ngầm lên Backend nếu người dùng đã đăng nhập (chạy nền, không chặn UI)
    if (UserSession.isLoggedIn && UserSession.currentUserId != null) {
      _syncToBackend(UserSession.currentUserId!, enabled);
    }
  }

  /// Đồng bộ thiết lập lên Backend PostgreSQL
  static Future<void> _syncToBackend(String userId, bool isDark) async {
    try {
      final url = Uri.parse('${ApiEndpoints.userSettingsAPI}?userId=$userId');
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (UserSession.currentToken != null && UserSession.currentToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${UserSession.currentToken}';
      }

      await http.put(
        url,
        headers: headers,
        body: jsonEncode({'darkMode': isDark}),
      ).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Khi mất mạng tạm thời, không làm gián đoạn UI
    }
  }

  /// Nạp cài đặt từ Backend sau khi đăng nhập thành công
  static Future<void> loadSettingsFromBackend(String userId) async {
    try {
      final url = Uri.parse('${ApiEndpoints.userSettingsAPI}?userId=$userId');
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (UserSession.currentToken != null && UserSession.currentToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${UserSession.currentToken}';
      }

      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final bool isDark = data['darkMode'] == true;
        themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyDarkMode, isDark);
      }
    } catch (_) {}
  }
}
