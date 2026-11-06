import 'package:flutter/material.dart';
import '../models/home_dashboard_model.dart';

// =========================================================================================
// [TÊN FILE: today_session_card.dart]
// [VỊ TRÍ]: lib/widgets/today_session_card.dart
// [MỤC ĐÍCH]: Widget tái sử dụng (Pattern MVC - View Component) hiển thị thẻ Hero "PHIÊN HỌC HÔM NAY"
// - Bám sát giao diện Screen 1 (anh_adobeXD/screen_1.png).
// - Hiển thị Tên môn học, Tên bài học, Thanh tiến độ % đã đọc.
// - Nút bấm hành động linh hoạt ("▷ Vào học" hoặc "▷ Tiếp tục học").
// =========================================================================================

class TodaySessionCard extends StatelessWidget {
  final TodaySessionModel session;
  final VoidCallback onActionPressed;

  const TodaySessionCard({
    super.key,
    required this.session,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressFraction = (session.progressPercent / 100.0).clamp(0.0, 1.0);
    final percentText = session.progressPercent > 0
        ? 'đã đọc được ${session.progressPercent.toStringAsFixed(session.progressPercent % 1 == 0 ? 0 : 1)}%'
        : 'Chưa bắt đầu (0%)';

    final cardBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFF15193B);
    final subjectColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFFB0BEC5);
    final titleColor = isDark ? const Color(0xFFF8FAFC) : Colors.white;
    final progressTextColor = isDark ? const Color(0xFF94A3B8) : Colors.white70;
    final btnBgColor = isDark ? const Color(0xFF38BDF8) : Colors.white;
    final btnTextColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF15193B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(22),
        border: isDark ? Border.all(color: const Color(0xFF334155), width: 1.2) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : const Color(0xFF15193B).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tên môn học (màu xanh sáng nhẹ nhàng)
          Text(
            session.subjectName.isNotEmpty ? session.subjectName : 'Môn học chính trị',
            style: TextStyle(
              color: subjectColor,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),

          // 2. Tiêu đề bài học (Chữ to đậm nổi bật)
          Text(
            session.lessonTitle,
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),

          // 3. Tiến độ đọc (%)
          Text(
            percentText,
            style: TextStyle(
              color: progressTextColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // 4. Thanh tiến độ LinearProgressIndicator
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 5.5,
              backgroundColor: isDark ? const Color(0xFF334155) : Colors.white.withOpacity(0.18),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? const Color(0xFF38BDF8) : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 5. Nút bấm hành động: "▷ Vào học" hoặc "▷ Tiếp tục học"
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBgColor,
                foregroundColor: btnTextColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 24,
                    color: btnTextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    session.buttonText.isNotEmpty ? session.buttonText : 'Vào học',
                    style: TextStyle(
                      color: btnTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
