import 'package:flutter/material.dart';
import '../models/admin_lesson_model.dart';

// =========================================================================================
// [TÊN FILE: admin_document_lesson_table.dart]
// [VỊ TRÍ]: lib/admin/widgets/admin_document_lesson_table.dart
// [MỤC ĐÍCH]: Component Bảng hiển thị danh sách Bài học & Tệp PDF trong trang Quản trị Tài liệu.
// - Tách từ admin_document_screen để module hóa và tối ưu kích thước file.
// - Hỗ trợ chọn từng dòng, chọn tất cả, hiển thị dung lượng file PDF hoặc trạng thái Chưa có file.
// =========================================================================================

class AdminDocumentLessonTable extends StatelessWidget {
  final List<AdminLessonModel> lessons;
  final Set<String> selectedItemIds;
  final Map<String, double> fileSizesCache;
  final ValueChanged<String> onToggleItem;
  final ValueChanged<bool?> onToggleSelectAll;

  const AdminDocumentLessonTable({
    super.key,
    required this.lessons,
    required this.selectedItemIds,
    required this.fileSizesCache,
    required this.onToggleItem,
    required this.onToggleSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có bài học nào.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
        ),
      );
    }

    final isAllSelected = selectedItemIds.length == lessons.length && lessons.isNotEmpty;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1.5)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: isAllSelected,
                  onChanged: onToggleSelectAll,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(flex: 5, child: Text('Bài học', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 14))),
              const Expanded(flex: 3, child: Text('Môn', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 14))),
              const Expanded(flex: 3, child: Text('tệp', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 14))),
            ],
          ),
        ),

        // Danh sách dòng
        Expanded(
          child: ListView.separated(
            itemCount: lessons.length,
            separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0), height: 1),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final isSelected = selectedItemIds.contains(lesson.id);

              final hasPdf = lesson.fileName != null &&
                  lesson.fileName!.trim().isNotEmpty &&
                  lesson.fileName != 'Chưa có file';

              final double? mb = lesson.fileSizeMb ?? fileSizesCache[lesson.id];
              final String sizeText = (hasPdf && mb != null)
                  ? '${mb.toStringAsFixed(1)} MB'
                  : '';

              return Material(
                color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                child: InkWell(
                  hoverColor: const Color(0xFFF1F5F9),
                  onTap: () => onToggleItem(lesson.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (_) => onToggleItem(lesson.id),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Cột Bài học
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E2238)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lesson.subjectName,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),

                        // Cột Môn
                        Expanded(
                          flex: 3,
                          child: Text(
                            lesson.subjectName,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF1E2238), fontWeight: FontWeight.w500),
                          ),
                        ),

                        // Cột Tệp
                        Expanded(
                          flex: 3,
                          child: hasPdf
                              ? Row(
                                  children: [
                                    const Icon(Icons.description, color: Color(0xFFF59E0B), size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lesson.fileName!,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E2238),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (sizeText.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              sizeText,
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Chưa có file',
                                  style: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                                ),
                        ),
                      ],
                    ),
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
