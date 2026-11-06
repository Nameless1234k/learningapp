import 'package:flutter/material.dart';
import '../models/home_dashboard_model.dart';

// =========================================================================================
// [TÊN FILE: recent_lessons_section.dart]
// [VỊ TRÍ]: lib/widgets/recent_lessons_section.dart
// [TẦNG KIẾN TRÚC]: View Component (Pattern MVC)
// [MỤC ĐÍCH]: Component tái sử dụng hiển thị danh sách bài học gần đây ("ĐÃ HỌC"):
// - Bám sát giao diện Screen 1 (anh_adobeXD/screen_1.png).
// - Hiển thị tiêu đề, tên môn học, % tiến độ đã đọc.
// - Kích hoạt callback khi học viên nhấn vào từng bài học.
// =========================================================================================

class RecentLessonsSection extends StatelessWidget {
  final List<RecentLessonModel> recentLessons;
  final ValueChanged<RecentLessonModel> onLessonTap;

  const RecentLessonsSection({
    super.key,
    required this.recentLessons,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recentLessons.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tiêu đề khối "Đã học" và tổng số lượng
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đã học',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
              ),
            ),
            Text(
              '${recentLessons.length} nội dung',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2. Thẻ bo tròn chứa danh sách bài đã học
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentLessons.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 64,
              endIndent: 16,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF0F2F5),
            ),
            itemBuilder: (context, index) {
              final item = recentLessons[index];
              final isCompleted = item.progressPercent >= 100;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onLessonTap(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Row(
                    children: [
                      // Icon đọc lại bo tròn
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.sync_rounded,
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF7E8B9B),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Thông tin tiêu đề bài học và môn học
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.lessonTitle,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subjectName,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Huy hiệu phần trăm tiến độ
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? (isDark
                                  ? const Color(0xFF064E3B).withValues(alpha: 0.7)
                                  : Colors.green.withOpacity(0.12))
                              : (isDark
                                  ? const Color(0xFF0C4A6E).withValues(alpha: 0.7)
                                  : const Color(0xFF15193B).withOpacity(0.08)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.progressPercent.toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? (isDark ? const Color(0xFF34D399) : Colors.green[700])
                                : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF15193B)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
