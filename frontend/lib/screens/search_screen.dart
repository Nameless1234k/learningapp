import 'package:flutter/material.dart';
import '../widgets/app_refresh_indicator.dart';

// =========================================================================================
// [TÊN FILE: search_screen.dart]
// [VỊ TRÍ]: lib/screens/search_screen.dart
// [MỤC ĐÍCH]: Màn hình trắng (Placeholder) cho tính năng "Tra cứu" (Tab 2 ở Bottom Bar).
// Theo yêu cầu của dự án: tạo trang trắng giữ chỗ trước để chuyển tab không bị lỗi.
// =========================================================================================

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Tra cứu',
          style: TextStyle(
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: AppRefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          physics: AppRefreshIndicator.alwaysScrollPhysics,
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon minh họa cho tính năng tìm kiếm
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155).withValues(alpha: 0.5)
                        : const Color(0xFF15193B).withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: 64,
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF15193B),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tính năng Tra cứu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hệ thống đang phát triển tính năng tra cứu khái niệm và kiến thức lý luận chính trị.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.black54,
                    height: 1.4,
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
