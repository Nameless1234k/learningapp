import 'package:flutter/material.dart';
import '../controllers/admin_document_controller.dart';
import '../widgets/admin_document_lesson_table.dart';
import '../widgets/admin_document_subject_table.dart';
import '../widgets/admin_hover_button.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/lesson_dialog.dart';
import '../widgets/subject_dialog.dart';

// =========================================================================================
// [TÊN FILE: admin_document_screen.dart]
// [VỊ TRÍ]: lib/admin/screens/admin_document_screen.dart
// [MỤC ĐÍCH]: Màn hình Quản trị Tài liệu & Thư viện (View trong mô hình MVC).
// - Đã tách toàn bộ State, logic nghiệp vụ, gọi API sang AdminDocumentController.
// - File chỉ giữ lại hiển thị UI, các dialog tương tác và các bảng con tái sử dụng.
// =========================================================================================

class AdminDocumentScreen extends StatefulWidget {
  const AdminDocumentScreen({super.key});

  @override
  State<AdminDocumentScreen> createState() => _AdminDocumentScreenState();
}

class _AdminDocumentScreenState extends State<AdminDocumentScreen> {
  final AdminDocumentController _controller = AdminDocumentController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.loadAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    _searchController.clear();
    _controller.setSubTab(index);
  }

  // Action: Thêm
  void _handleAdd() {
    if (_controller.isLessonTab) {
      LessonDialog.show(
        context,
        subjects: _controller.subjects,
        onSave: ({required title, required subjectId, fileBytes, fileName, removeFile = false}) async {
          await _controller.createLesson(
            title: title,
            subjectId: subjectId,
            fileBytes: fileBytes,
            fileName: fileName,
            currentKeyword: _searchController.text,
          );
        },
      );
    } else {
      SubjectDialog.show(
        context,
        onSave: (code, name, displayOrder) async {
          await _controller.createSubject(
            code: code,
            name: name,
            displayOrder: displayOrder,
            currentKeyword: _searchController.text,
          );
        },
      );
    }
  }

  // Action: Sửa
  void _handleEdit() {
    if (_controller.selectedItemIds.length != 1) return;
    final selectedId = _controller.selectedItemIds.first;

    if (_controller.isLessonTab) {
      final lesson = _controller.lessons.firstWhere((l) => l.id == selectedId);
      LessonDialog.show(
        context,
        subjects: _controller.subjects,
        initialLesson: lesson,
        onSave: ({required title, required subjectId, fileBytes, fileName, removeFile = false}) async {
          await _controller.updateLesson(
            id: lesson.id,
            title: title,
            subjectId: subjectId,
            fileBytes: fileBytes,
            fileName: fileName,
            removeFile: removeFile,
            currentKeyword: _searchController.text,
          );
        },
      );
    } else {
      final subject = _controller.subjects.firstWhere((s) => s.id == selectedId);
      SubjectDialog.show(
        context,
        initialSubject: subject,
        onSave: (code, name, displayOrder) async {
          await _controller.updateSubject(
            id: subject.id,
            code: code,
            name: name,
            displayOrder: displayOrder,
            currentKeyword: _searchController.text,
          );
        },
      );
    }
  }

  // Action: Xóa
  Future<void> _handleDelete() async {
    if (_controller.selectedItemIds.isEmpty) return;

    final count = _controller.selectedItemIds.length;
    final typeName = _controller.isLessonTab ? 'bài học' : 'môn học';

    final confirmed = await DeleteConfirmDialog.show(
      context,
      title: 'Xác nhận xóa',
      message: 'Bạn có chắc chắn muốn xóa $count $typeName đã chọn?\nThao tác này không thể hoàn tác.',
    );

    if (confirmed == true) {
      try {
        await _controller.deleteSelectedItems(currentKeyword: _searchController.text);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final isLessonTab = _controller.isLessonTab;

        return Container(
          color: const Color(0xFFF3F4F6),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tiêu đề lớn & Phụ đề
              const Text(
                'Quản trị tài liệu',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2238),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Quản lý môn học, danh sách bài học và tài liệu PDF đính kèm',
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),

              // 2. Hai SubTab gạch dưới: Bài học | Môn học
              Row(
                children: [
                  _buildUnderlineTab(index: 0, title: 'Bài học', icon: Icons.menu_book_outlined),
                  const SizedBox(width: 36),
                  _buildUnderlineTab(index: 1, title: 'Môn học', icon: Icons.school_outlined),
                ],
              ),
              const Divider(height: 1, thickness: 1.5, color: Color(0xFFCBD5E1)),
              const SizedBox(height: 20),

              // 3. Toolbar: Các nút Thêm/Sửa/Xóa + Tìm kiếm thông minh + Dropdown lọc
              Row(
                children: [
                  AdminHoverButton(
                    onTap: _handleAdd,
                    icon: Icons.add,
                    label: isLessonTab ? 'Thêm bài học' : 'Thêm môn học',
                    textColor: Colors.white,
                    backgroundColor: const Color(0xFF1E2238),
                    hoverBackgroundColor: const Color(0xFF334155),
                    borderColor: const Color(0xFF1E2238),
                    hoverBorderColor: const Color(0xFF334155),
                  ),
                  const SizedBox(width: 10),
                  AdminHoverButton(
                    onTap: _handleEdit,
                    icon: Icons.edit_outlined,
                    label: 'Sửa',
                    textColor: const Color(0xFF1E2238),
                    backgroundColor: Colors.white,
                    hoverBackgroundColor: const Color(0xFFF1F5F9),
                    borderColor: const Color(0xFFCBD5E1),
                    hoverBorderColor: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 10),
                  AdminHoverButton(
                    onTap: _handleDelete,
                    icon: Icons.delete_outline,
                    label: 'Xóa',
                    textColor: const Color(0xFFDC2626),
                    backgroundColor: Colors.white,
                    hoverBackgroundColor: const Color(0xFFFEF2F2),
                    borderColor: const Color(0xFFFECACA),
                    hoverBorderColor: const Color(0xFFEF4444),
                    hoverTextColor: const Color(0xFFB91C1C),
                  ),
                  const Spacer(),

                  // Ô Tìm kiếm tái sử dụng AdminSearchBar có Debounce tự động
                  SizedBox(
                    width: 320,
                    child: AdminSearchBar(
                      controller: _searchController,
                      hintText: isLessonTab ? 'Tìm kiếm theo tên bài học...' : 'Tìm kiếm theo tên hoặc mã môn học...',
                      onSearch: (kw) => _controller.reloadCurrentTab(keyword: kw),
                      onClear: () => _controller.reloadCurrentTab(),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Bộ lọc Môn học (chỉ hiển thị ở Tab Bài học)
                  if (isLessonTab) ...[
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFF94A3B8), width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _controller.selectedSubjectFilter,
                          hint: const Text('Môn học: tất cả', style: TextStyle(fontSize: 14, color: Color(0xFF475569))),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF475569)),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Môn học: tất cả'),
                            ),
                            ..._controller.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                          ],
                          onChanged: (val) {
                            _controller.setSubjectFilter(val, currentKeyword: _searchController.text);
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // 4. Bảng dữ liệu tương ứng theo Tab
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                  ),
                  child: _controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _controller.errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_controller.errorMessage!, style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => _controller.reloadCurrentTab(keyword: _searchController.text),
                                    child: const Text('Thử lại'),
                                  ),
                                ],
                              ),
                            )
                          : isLessonTab
                              ? AdminDocumentLessonTable(
                                  lessons: _controller.lessons,
                                  selectedItemIds: _controller.selectedItemIds,
                                  fileSizesCache: _controller.fileSizesCache,
                                  onToggleItem: (id) => _controller.toggleItem(id),
                                  onToggleSelectAll: (val) => _controller.toggleSelectAll(val),
                                )
                              : AdminDocumentSubjectTable(
                                  subjects: _controller.subjects,
                                  selectedItemIds: _controller.selectedItemIds,
                                  onToggleItem: (id) => _controller.toggleItem(id),
                                  onToggleSelectAll: (val) => _controller.toggleSelectAll(val),
                                ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnderlineTab({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _controller.selectedSubTab == index;

    return InkWell(
      onTap: () => _onTabChanged(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF1E2238) : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF1E2238) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 90,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1E2238) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
