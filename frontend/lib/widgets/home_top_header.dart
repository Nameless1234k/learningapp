import 'package:flutter/material.dart';
import '../models/home_dashboard_model.dart';
import '../services/user_session.dart';

// =========================================================================================
// [TÊN FILE: home_top_header.dart]
// [VỊ TRÍ]: lib/widgets/home_top_header.dart
// [TẦNG KIẾN TRÚC]: View Component (Pattern MVC)
// [MỤC ĐÍCH]: Component tái sử dụng hiển thị thanh tiêu đề phía trên của Trang chủ:
// - Avatar chữ cái đại diện (Initials).
// - Lời chào thông minh:
//   + Tài khoản mới (isNewUser == true): Hiển thị nổi bật "Chào mừng đến với Learning App"
//   + Tài khoản đã dùng (isNewUser == false): Dòng chữ trên biến mất, chỉ hiển thị "Xin chào," + Tên.
// - Icon Chuông thông báo góc phải.
// =========================================================================================

class HomeTopHeader extends StatelessWidget {
  final HomeDashboardModel? dashboard;
  final VoidCallback? onNotificationPressed;

  const HomeTopHeader({
    super.key,
    required this.dashboard,
    this.onNotificationPressed,
  });

  /// Trích xuất chữ cái đại diện từ tên trong RAM nếu dashboard chưa tải xong
  String _extractInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = dashboard?.userInitials ??
        _extractInitials(UserSession.currentFullName ?? 'User');
    final displayName = dashboard?.userFullName.isNotEmpty == true
        ? dashboard!.userFullName
        : (UserSession.currentFullName ?? 'Người học');
    final isNewUser = dashboard?.isNewUser ?? false;

    return Row(
      children: [
        // 1. Avatar chữ cái tròn navy (hoặc cyan khi Dark Mode)
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF15193B),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),

        // 2. Lời chào phân nhánh theo trạng thái tài khoản
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNewUser) ...[
                // Tài khoản mới thành lập: Hiển thị "Chào mừng đến với Learning App"
                Text(
                  'Chào mừng đến với Learning App',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else ...[
                // Tài khoản đã dùng: "Chào mừng..." biến mất hoàn toàn, chỉ hiển thị "Xin chào," + Tên
                Text(
                  'Xin chào,',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // 3. Icon Chuông thông báo
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
              size: 22,
            ),
            tooltip: 'Thông báo',
            onPressed: onNotificationPressed ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Hiện chưa có thông báo mới.'),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF15193B),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
          ),
        ),
      ],
    );
  }
}
