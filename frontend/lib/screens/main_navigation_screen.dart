import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'document_list_screen.dart';
import 'practice_screen.dart';
import 'profile_screen.dart';

// =========================================================================================
// [TÊN FILE: main_navigation_screen.dart]
// [VỊ TRÍ]: lib/screens/main_navigation_screen.dart
// [MỤC ĐÍCH]: Màn hình khung chứa Bottom Navigation Bar chính của toàn bộ ứng dụng.
// - Tạo thanh điều hướng dưới đáy (Bottom Bar) chuẩn theo thiết kế Adobe XD (Screen 9, 14, 15)
// - Gồm 5 Tab: Trang chủ, Tra cứu, Tài liệu, Luyện tập, Cá nhân
// - Khi nhấn vào tab nào thì chuyển trang tương ứng
// - Mặc định khi vừa đăng nhập vào thì hiển thị TAB TRANG CHỦ (index = 0) theo yêu cầu.
// =========================================================================================

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex; // Cho phép truyền index ban đầu (mặc định là 0: Trang chủ)

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  // Biến lưu chỉ số trang hiện tại đang được chọn (0: Trang chủ, 1: Tra cứu, 2: Tài liệu, 3: Luyện tập, 4: Cá nhân)
  late int _currentIndex;

  /// GlobalKey quản lý state màn hình Danh sách tài liệu để kích hoạt làm mới khi chuyển tab
  final GlobalKey<DocumentListScreenState> documentListKey = GlobalKey<DocumentListScreenState>();

  // Danh sách các màn hình tương ứng với 5 Tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Gán index mặc định (0: Trang chủ khi vừa đăng nhập vào)
    _currentIndex = widget.initialIndex;

    // Khởi tạo danh sách 5 trang
    _screens = [
      // Tab 0: Trang chủ (kèm callback chuyển tab khi bấm banner)
      HomeScreen(
        onSwitchTab: _switchToTab,
      ),
      // Tab 1: Tra cứu (Trang trắng placeholder)
      const SearchScreen(),
      // Tab 2: Tài liệu (Screen 9 theo Adobe XD & Đặc tả Use Case)
      DocumentListScreen(key: documentListKey),
      // Tab 3: Luyện tập (Trang trắng placeholder)
      const PracticeScreen(),
      // Tab 4: Cá nhân (Trang trắng có nút Đăng xuất tạm thời)
      const ProfileScreen(),
    ];
  }

  // Hàm chuyển đổi tab khi người dùng bấm vào một mục ở Bottom Bar
  void _onTabTapped(int index) {
    _switchToTab(index);
  }

  /// Chuyển tab và tự động đồng bộ/làm mới dữ liệu mới nhất
  void _switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    _triggerTabRefresh(index);
  }

  /// Kích hoạt làm mới ngầm khi chuyển vào tab tương ứng
  void _triggerTabRefresh(int index) {
    if (index == 2) {
      // Khi học viên bấm vào Tab 2 (Tài liệu): tự động làm mới ngầm dữ liệu danh sách môn học mới nhất
      documentListKey.currentState?.refresh(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack giúp giữ nguyên trạng thái (State) của các tab, không bị tải lại từ đầu mỗi khi chuyển tab
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // Thanh điều hướng đáy (Bottom Navigation Bar) thiết kế chuẩn theo Adobe XD
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE5E7EB), // Đường kẻ viền mỏng phía trên Bottom Bar
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Tab Trang chủ
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Trang chủ',
                ),

                // 2. Tab Tra cứu
                _buildNavItem(
                  index: 1,
                  icon: Icons.search_rounded,
                  activeIcon: Icons.search_rounded,
                  label: 'Tra cứu',
                ),

                // 3. Tab Tài liệu (Screen 9)
                _buildNavItem(
                  index: 2,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book_rounded,
                  label: 'Tài liệu',
                ),

                // 4. Tab Luyện tập
                _buildNavItem(
                  index: 3,
                  icon: Icons.checklist_outlined,
                  activeIcon: Icons.checklist_rounded,
                  label: 'Luyện tập',
                ),

                // 5. Tab Cá nhân
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Cá nhân',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget con tạo từng nút bấm điều hướng trên Bottom Bar
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = _currentIndex == index;
    // Màu sắc theo Adobe XD: xanh tím than đậm (#15193B) khi chọn, xám (#8E8E93) khi không chọn
    final Color itemColor = isSelected ? const Color(0xFF15193B) : const Color(0xFF8E8E93);

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: itemColor,
              size: 26,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: itemColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
