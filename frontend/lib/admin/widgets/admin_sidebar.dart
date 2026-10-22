import 'package:flutter/material.dart';
import '../../services/user_session.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int index) onSelectTab;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin tài khoản người đang đăng nhập từ UserSession
    final adminName = (UserSession.currentFullName != null && UserSession.currentFullName!.trim().isNotEmpty)
        ? UserSession.currentFullName!.trim()
        : (UserSession.currentEmail ?? 'Quản trị viên');
    final avatarLetter = adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A';

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Color(0xFFECEEF1), // Nền xám nhạt chuẩn ảnh Web 1920
        border: Border(right: BorderSide(color: Color(0xFFCBD5E1), width: 1.5)),
      ),
      child: Column(
        children: [
          // Logo & Tên Admin trên cùng
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD5D8DE), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF26293D),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App learning',
                      style: TextStyle(
                        color: Color(0xFF1E2238),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Trang Admin',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Menu Quản trị tài khoản
          _buildPillItem(
            index: 0,
            icon: Icons.people_outline,
            title: 'Quản trị tài khoản',
          ),
          const SizedBox(height: 10),

          // Menu Quản trị học tập (gồm cả Môn học và Bài học)
          _buildPillItem(
            index: 1,
            icon: Icons.menu_book_outlined,
            title: 'Quản trị học tập',
          ),
          const SizedBox(height: 10),

          // Menu Quản trị đề thi
          _buildPillItem(
            index: 2,
            icon: Icons.assignment_outlined,
            title: 'Quản trị đề thi',
          ),

          const Spacer(),

          // Đường kẻ ngang ngăn cách phần tài khoản bên dưới
          const Divider(color: Color(0xFFCBD5E1), height: 1.5),

          // Phần thông tin Admin bên dưới góc trái
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF26293D),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        adminName,
                        style: const TextStyle(
                          color: Color(0xFF1E2238),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Admin',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onLogout,
                  tooltip: 'Đăng xuất',
                  icon: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => onSelectTab(index),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF22263C) : const Color(0xFFDFE2E6),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF475569),
                size: 20,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
