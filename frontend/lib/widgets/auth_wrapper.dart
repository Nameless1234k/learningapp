import 'package:flutter/material.dart';
import '../services/user_session.dart';

// =========================================================================================
// [TÊN FILE: auth_wrapper.dart]
// [VỊ TRÍ]: lib/widgets/auth_wrapper.dart
// [MỤC ĐÍCH]: Widget điều phối phiên đăng nhập tự động dùng chung cho cả App Mobile & Web Admin.
// - Ngăn chặn tình trạng bị đăng xuất khi người dùng nhấn F5 tải lại trang Web hoặc đóng/mở App.
// - Tự động nạp UserSession từ LocalStorage/SharedPreferences.
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

        // Đã có phiên đăng nhập hợp lệ
        if (UserSession.isLoggedIn) {
          // Kiểm tra quyền hạn nếu có yêu cầu phân quyền Role Guard
          if (widget.requiredRole != null) {
            final requiredUpper = widget.requiredRole!.toUpperCase();
            final currentUpper = (UserSession.currentRole ?? 'USER').toUpperCase();

            // Nếu trang yêu cầu quyền ADMIN mà phiên hiện tại không phải ADMIN
            if (requiredUpper == 'ADMIN' && currentUpper != 'ADMIN') {
              return widget.unauthenticatedScreen;
            }
          }
          // Hợp lệ -> Vào thẳng màn hình chính (không bao giờ văng ra login khi F5)
          return widget.authenticatedScreen;
        }

        // Chưa đăng nhập -> Hiển thị màn hình đăng nhập tương ứng
        return widget.unauthenticatedScreen;
      },
    );
  }
}
