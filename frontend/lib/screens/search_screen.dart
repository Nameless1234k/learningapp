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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền xám nhạt đồng bộ toàn ứng dụng
      appBar: AppBar(
        title: const Text(
          'Tra cứu',
          style: TextStyle(
            color: Color(0xFF15193B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
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
                    color: const Color(0xFF15193B).withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 64,
                    color: Color(0xFF15193B),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tính năng Tra cứu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15193B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hệ thống đang phát triển tính năng tra cứu khái niệm và kiến thức lý luận chính trị.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
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
