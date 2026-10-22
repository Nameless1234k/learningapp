import 'package:flutter/material.dart';
import '../widgets/app_refresh_indicator.dart';

// =========================================================================================
// [TÊN FILE: home_screen.dart]
// [VỊ TRÍ]: lib/screens/home_screen.dart
// [MỤC ĐÍCH]: Màn hình Trang chủ (Tab 1 mặc định khi người dùng vừa đăng nhập thành công).
// Hiển thị lời chào và tổng quan tính năng của ứng dụng.
// =========================================================================================

class HomeScreen extends StatelessWidget {
  final Function(int)? onSwitchTab; // Callback chuyển tab nếu bấm vào phím tắt trên trang chủ

  const HomeScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền xám nhạt toàn ứng dụng
      appBar: AppBar(
        title: const Text(
          'Trang chủ',
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
            // Hiệu ứng làm mới mượt mà trên trang chủ
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            physics: AppRefreshIndicator.alwaysScrollPhysics,
            padding: const EdgeInsets.all(24.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Tiêu đề chào mừng người dùng
              const Text(
                'Chào mừng bạn trở lại!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF15193B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tiếp tục hành trình học tập các môn lý luận chính trị.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 28),

              // 2. Banner phím tắt dẫn vào mục "Tài liệu"
              GestureDetector(
                onTap: () {
                  // Chuyển sang Tab 2 (Tài liệu)
                  if (onSwitchTab != null) {
                    onSwitchTab!(2);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF15193B), Color(0xFF2E3856)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF15193B).withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kho tài liệu học tập',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Xem danh sách 5 môn học & bài học',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ],
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
