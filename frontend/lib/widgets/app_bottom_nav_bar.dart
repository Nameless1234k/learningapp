import 'package:flutter/material.dart';

// =========================================================================================
// [TÊN FILE: app_bottom_nav_bar.dart]
// [VỊ TRÍ]: lib/widgets/app_bottom_nav_bar.dart
// [TẦNG KIẾN TRÚC]: View Component (Pattern MVC)
// [MỤC ĐÍCH]: Component tái sử dụng hiển thị thanh điều hướng đáy (Bottom Navigation Bar):
// - Thiết kế chuẩn theo Adobe XD Screen 1, 9, 22.
// - 5 Tabs: Trang chủ, Tra cứu, Tài liệu, Luyện tập, Cá nhân.
// - Tự động thích ứng màu sắc hoàn hảo cho cả Light Mode và Dark Mode.
// =========================================================================================

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final navBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: navBgColor,
        border: Border(
          top: BorderSide(
            color: navBorderColor,
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
                isDark: isDark,
              ),

              // 2. Tab Tra cứu
              _buildNavItem(
                index: 1,
                icon: Icons.search_rounded,
                activeIcon: Icons.search_rounded,
                label: 'Tra cứu',
                isDark: isDark,
              ),

              // 3. Tab Tài liệu
              _buildNavItem(
                index: 2,
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book_rounded,
                label: 'Tài liệu',
                isDark: isDark,
              ),

              // 4. Tab Luyện tập
              _buildNavItem(
                index: 3,
                icon: Icons.checklist_outlined,
                activeIcon: Icons.checklist_rounded,
                label: 'Luyện tập',
                isDark: isDark,
              ),

              // 5. Tab Cá nhân
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Cá nhân',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    final bool isSelected = currentIndex == index;
    final Color activeColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF15193B);
    final Color inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF8E8E93);
    final Color itemColor = isSelected ? activeColor : inactiveColor;

    return InkWell(
      onTap: () => onTabSelected(index),
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
