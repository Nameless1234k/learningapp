import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../widgets/app_refresh_indicator.dart';
import 'login_screen.dart';

// =========================================================================================
// [TÊN FILE: profile_screen.dart]
// [VỊ TRÍ]: lib/screens/profile_screen.dart
// [MỤC ĐÍCH]: Màn hình "Cá nhân" (Tab 5 ở Bottom Bar).
// - Hiển thị giao diện thông tin cá nhân cơ bản
// - Gắn tạm nút "ĐĂNG XUẤT" theo yêu cầu người dùng để đăng xuất khỏi ứng dụng
//   và quay về màn hình Đăng Nhập.
// =========================================================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Hàm xử lý đăng xuất người dùng khỏi ứng dụng
  void _handleLogout(BuildContext context) {
    // Hiển thị hộp thoại Dialog xác nhận đăng xuất
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Xác nhận đăng xuất',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15193B)),
          ),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản hiện tại không?'),
          actions: [
            // Nút Hủy
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            // Nút Đồng ý Đăng xuất
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                // Xóa phiên làm việc trong cả RAM và LocalStorage
                await UserSession.clear();

                // Đóng Dialog
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                
                // Xóa toàn bộ lịch sử các màn hình trước đó và quay về LoginScreen
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false, // Xóa hết toàn bộ route cũ trong ngăn xếp
                  );
                }
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Nền màu xám sáng sạch sẽ
      appBar: AppBar(
        title: const Text(
          'Cá nhân',
          style: TextStyle(
            color: Color(0xFF15193B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            physics: AppRefreshIndicator.alwaysScrollPhysics,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Khung hiển thị Avatar và tên người dùng mẫu
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar tròn
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF15193B).withOpacity(0.1),
                        child: const Icon(Icons.person, size: 36, color: Color(0xFF15193B)),
                      ),
                      const SizedBox(width: 16),
                      // Tên và email
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tài khoản người học',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15193B),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Học viên lý luận chính trị',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 2. Nút ĐĂNG XUẤT (Gắn tạm tại đây theo đúng yêu cầu)
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: const Text(
                      'Đăng xuất tài khoản',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
