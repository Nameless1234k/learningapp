import 'package:flutter/material.dart';
import '../services/user_session.dart';

// =========================================================================================
// [TÊN FILE: auth_wrapper.dart]
// [VỊ TRÍ]: lib/widgets/auth_wrapper.dart
// [MỤC ĐÍCH]: Widget điều phối phiên đăng nhập tự động dùng chung cho cả App Mobile & Web Admin.
// - Ngăn chặn tình trạng bị đăng xuất khi người dùng nhấn F5 tải lại trang Web hoặc đóng/mở App.
// - Tự động nạp UserSession từ LocalStorage/SharedPreferences.
// - Kiểm tra tính hợp lệ của JWT với Backend (hết hạn hoặc Backend khởi động lại).
// - Kiểm tra Role Guard:
//   + Nếu requiredRole là 'ADMIN': chỉ tài khoản ADMIN mới vào được authenticatedScreen.
//   + Nếu requiredRole là 'USER': tài khoản hợp lệ tự động vào authenticatedScreen.
// - Nếu chưa đăng nhập hoặc sai quyền: tự động hiển thị unauthenticatedScreen (màn hình login).
// =========================================================================================

class AuthWrapper extends StatefulWidget {
  final Widget authenticatedScreen;
  final Widget unauthenticatedScreen;
  final String? requiredRole; // 'ADMIN' hoặc 'USER' (null = chấp nhận mọi role đã đăng nhập)

  const AuthWrapper({
    super.key,
    required this.authenticatedScreen,
    required this.unauthenticatedScreen,
    this.requiredRole,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _checkSession();
  }

  Future<void> _checkSession() async {
    if (!UserSession.isInitialized) {
      await UserSession.init();
    }
    // Xác thực nhanh tính hợp lệ của JWT với Backend (nếu máy chủ restart, tự động đăng xuất)
    if (UserSession.isLoggedIn) {
      await UserSession.validateSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        // Trong tích tắc nạp dữ liệu từ LocalStorage (<20ms)
        if (snapshot.connectionState == ConnectionState.waiting && !UserSession.isInitialized) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF15193B)),
            ),
          );
        }

        // BƯỚC 1: Kiểm tra xem đã đăng nhập chưa. Nếu chưa đăng nhập -> Cố định Light Mode cho các màn hình Auth
        if (!UserSession.isLoggedIn) {
          return Theme(
            data: ThemeData.light(),
            child: widget.unauthenticatedScreen,
          );
        }

        // BƯỚC 2: Kiểm tra phân quyền Role Guard nếu có yêu cầu
        if (widget.requiredRole != null) {
          final userRole = UserSession.currentRole?.toUpperCase();
          final requiredRoleUpper = widget.requiredRole!.toUpperCase();

          // Nếu yêu cầu ADMIN nhưng tài khoản là USER -> Chặn lại và đẩy về unauthenticatedScreen
          if (requiredRoleUpper == 'ADMIN' && userRole != 'ADMIN') {
            return widget.unauthenticatedScreen;
          }

          // Nếu yêu cầu USER nhưng tài khoản là ADMIN -> Có thể cho phép hoặc chặn tùy chính sách
          if (requiredRoleUpper == 'USER' && userRole == 'ADMIN') {
            // Cho phép Admin xem trang người dùng bình thường
          }
        }

        // BƯỚC 3: Phiên đăng nhập hợp lệ và đúng quyền -> Hiển thị màn hình chính
        return widget.authenticatedScreen;
      },
    );
  }
}
