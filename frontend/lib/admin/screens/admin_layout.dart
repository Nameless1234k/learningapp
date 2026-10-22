import 'package:flutter/material.dart';
import '../../services/user_session.dart';
import '../widgets/admin_sidebar.dart';
import 'admin_login_screen.dart';
import 'admin_user_screen.dart';
import 'admin_document_screen.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _currentTabIndex = 0;

  final List<Widget> _screens = const [
    AdminUserScreen(),       // Menu 0: Quản trị tài khoản
    AdminDocumentScreen(),   // Menu 1: Quản trị tài liệu (gồm Tab Bài học & Môn học)
    _ExamManagementPlaceholder(), // Menu 2: Quản trị đề thi
  ];

  void _logout() async {
    await UserSession.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Row(
        children: [
          // Sidebar menu bên trái (chuẩn theo ảnh Web 1920)
          AdminSidebar(
            selectedIndex: _currentTabIndex,
            onSelectTab: (index) {
              setState(() => _currentTabIndex = index);
            },
            onLogout: _logout,
          ),

          // Nội dung màn hình tương ứng bên phải
          Expanded(
            child: _screens[_currentTabIndex],
          ),
        ],
      ),
    );
  }
}

class _ExamManagementPlaceholder extends StatelessWidget {
  const _ExamManagementPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F4F6),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản trị đề thi',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2238),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Quản lý câu hỏi, ngân hàng đề thi chính trị',
            style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_outlined, size: 64, color: Color(0xFF94A3B8)),
                    SizedBox(height: 16),
                    Text(
                      'Chức năng Quản trị đề thi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2238)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hệ thống sẽ cập nhật phân hệ này trong giai đoạn tiếp theo.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
