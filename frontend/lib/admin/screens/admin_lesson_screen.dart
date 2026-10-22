import 'package:flutter/material.dart';
import '../models/admin_lesson_model.dart';
import '../models/admin_subject_model.dart';
import '../services/admin_api_service.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/lesson_form_dialog.dart';

class AdminLessonScreen extends StatefulWidget {
  const AdminLessonScreen({super.key});

  @override
  State<AdminLessonScreen> createState() => _AdminLessonScreenState();
}

class _AdminLessonScreenState extends State<AdminLessonScreen> {
  final AdminApiService _apiService = AdminApiService();
  final TextEditingController _searchController = TextEditingController();

  List<AdminLessonModel> _lessons = [];
  List<AdminSubjectModel> _subjects = [];
  String? _selectedSubjectFilter;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final subs = await _apiService.getSubjects();
      final less = await _apiService.getLessons();
      setState(() {
        _subjects = subs;
        _lessons = less;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  Future<void> _loadLessons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final less = await _apiService.getLessons(
        subjectId: _selectedSubjectFilter,
        keyword: _searchController.text.trim(),
      );
      setState(() {
        _lessons = less;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  void _openAddDialog() {
    LessonFormDialog.show(
      context,
      subjects: _subjects,
      onSave: ({required title, required subjectId, fileBytes, fileName}) async {
        await _apiService.createLesson(
          title: title,
          subjectId: subjectId,
          fileBytes: fileBytes,
          fileName: fileName,
        );
        _showToast('Đã thêm bài học và tài liệu thành công!');
        _loadLessons();
      },
    );
  }

  void _openEditDialog(AdminLessonModel lesson) {
    LessonFormDialog.show(
      context,
      initialLesson: lesson,
      subjects: _subjects,
      onSave: ({required title, required subjectId, fileBytes, fileName}) async {
        await _apiService.updateLesson(
          id: lesson.id,
          title: title,
          subjectId: subjectId,
          fileBytes: fileBytes,
          fileName: fileName,
        );
        _showToast('Đã cập nhật bài học thành công!');
        _loadLessons();
      },
    );
  }

  Future<void> _deleteLesson(AdminLessonModel lesson) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Xóa bài học',
      message: 'Bạn có chắc chắn muốn xóa bài học "${lesson.title}" cùng tài liệu PDF liên kết không?',
      confirmText: 'Xác nhận xóa',
      cancelText: 'Hủy',
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteLesson(lesson.id);
        _showToast('Đã xóa bài học thành công!');
        _loadLessons();
      } catch (e) {
        _showToast(e.toString().replaceAll("Exception: ", ""), isError: true);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar: Tìm kiếm, Bộ lọc môn học & Nút Thêm mới
          Row(
            children: [
              // Bộ lọc Dropdown môn học
              Container(
                width: 240,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSubjectFilter,
                    hint: const Text('Tất cả các môn học'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Tất cả các môn học', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ..._subjects.map((sub) {
                        return DropdownMenuItem<String>(
                          value: sub.id,
                          child: Text('${sub.code} - ${sub.name}', overflow: TextOverflow.ellipsis),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedSubjectFilter = val);
                      _loadLessons();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Ô Tìm kiếm bài học tái sử dụng AdminSearchBar có Debounce tự động
              Expanded(
                child: AdminSearchBar(
                  controller: _searchController,
                  hintText: 'Tìm kiếm theo tên bài học...',
                  onSearch: (_) => _loadLessons(),
                  onClear: () => _loadLessons(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _loadLessons,
                icon: const Icon(Icons.search, size: 20),
                label: const Text('Tìm kiếm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 14),
              ElevatedButton.icon(
                onPressed: _subjects.isEmpty ? null : _openAddDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Thêm bài học mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bảng bài học (DataTable)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadLessons,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : _lessons.isEmpty
                          ? const Center(
                              child: Text(
                                'Chưa có bài học nào hoặc không tìm thấy bài học phù hợp.',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                horizontalMargin: 20,
                                columnSpacing: 24,
                                columns: const [
                                  DataColumn(label: Text('Bài số', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Tên bài học', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Thuộc môn học', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Tài liệu PDF', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Ngày tạo', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: _lessons.map((lesson) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: Text(
                                            'Bài ${lesson.lessonNo}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 320,
                                          child: Text(
                                            lesson.title,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.blue.shade200),
                                          ),
                                          child: Text(
                                            lesson.subjectName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade800,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.picture_as_pdf,
                                              size: 18,
                                              color: lesson.fileName != null ? Colors.red : Colors.grey,
                                            ),
                                            const SizedBox(width: 6),
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 180),
                                              child: Text(
                                                lesson.fileName ?? 'Chưa có file',
                                                style: TextStyle(
                                                  color: lesson.fileName != null ? Colors.black87 : Colors.grey,
                                                  fontStyle: lesson.fileName != null ? FontStyle.normal : FontStyle.italic,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(lesson.createdAt, style: const TextStyle(color: Colors.grey, fontSize: 13))),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                              tooltip: 'Sửa bài học',
                                              onPressed: () => _openEditDialog(lesson),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                              tooltip: 'Xóa bài học',
                                              onPressed: () => _deleteLesson(lesson),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
