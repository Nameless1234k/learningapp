import 'package:flutter/material.dart';
import '../models/admin_subject_model.dart';

// =========================================================================================
// [TÊN FILE: admin_document_subject_table.dart]
// [VỊ TRÍ]: lib/admin/widgets/admin_document_subject_table.dart
// [MỤC ĐÍCH]: Component Bảng hiển thị danh sách Môn học trong trang Quản trị Tài liệu.
// - Tách từ admin_document_screen để module hóa và tối ưu kích thước file.
// - Hỗ trợ chọn từng dòng, chọn tất cả, hiển thị mã môn dạng Pill xám bo góc chuẩn thiết kế.
// =========================================================================================

class AdminDocumentSubjectTable extends StatelessWidget {
  final List<AdminSubjectModel> subjects;
  final Set<String> selectedItemIds;
  final ValueChanged<String> onToggleItem;
  final ValueChanged<bool?> onToggleSelectAll;

  const AdminDocumentSubjectTable({
    super.key,
    required this.subjects,
    required this.selectedItemIds,
    required this.onToggleItem,
    required this.onToggleSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có môn học nào.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
        ),
      );
    }

    final isAllSelected = selectedItemIds.length == subjects.length && subjects.isNotEmpty;

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
              const Expanded(flex: 6, child: Text('Môn học', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 14))),
              const Expanded(flex: 4, child: Text('Mã môn học', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 14))),
            ],
          ),
        ),

        // Danh sách dòng
        Expanded(
          child: ListView.separated(
            itemCount: subjects.length,
            separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0), height: 1),
            itemBuilder: (context, index) {
              final sub = subjects[index];
              final isSelected = selectedItemIds.contains(sub.id);

              return Material(
                color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                child: InkWell(
                  hoverColor: const Color(0xFFF1F5F9),
                  onTap: () => onToggleItem(sub.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (_) => onToggleItem(sub.id),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Cột Tên môn học
                        Expanded(
                          flex: 6,
                          child: Text(
                            sub.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E2238)),
                          ),
                        ),

                        // Cột Mã môn học dạng Pill xám bo góc
                        Expanded(
                          flex: 4,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDFE2E6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                              ),
                              child: Text(
                                sub.code,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
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
