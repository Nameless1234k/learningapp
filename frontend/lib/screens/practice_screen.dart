import 'package:flutter/material.dart';
import '../widgets/app_refresh_indicator.dart';

// =========================================================================================
// [TÊN FILE: practice_screen.dart]
// [VỊ TRÍ]: lib/screens/practice_screen.dart
// [MỤC ĐÍCH]: Màn hình trắng (Placeholder) cho tính năng "Luyện tập" (Tab 4 ở Bottom Bar).
// Dùng làm trang giữ chỗ cho các bài trắc nghiệm, giải thích (Screen 15).
// =========================================================================================

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền xám xanh nhạt
      appBar: AppBar(
        title: const Text(
          'Luyện tập',
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
                // Icon minh họa cho tính năng làm bài tập, thi thử
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15193B).withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.checklist_rounded,
                    size: 64,
                    color: Color(0xFF15193B),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Luyện tập trắc nghiệm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15193B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tính năng luyện tập trắc nghiệm có lời giải thích chi tiết đang được hoàn thiện.',
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
