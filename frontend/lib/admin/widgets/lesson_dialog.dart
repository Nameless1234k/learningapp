import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/admin_lesson_model.dart';
import '../models/admin_subject_model.dart';

class LessonDialog extends StatefulWidget {
  final AdminLessonModel? initialLesson;
  final List<AdminSubjectModel> subjects;
  final Future<void> Function({
    required String title,
    required String subjectId,
    List<int>? fileBytes,
    String? fileName,
    bool removeFile,
  }) onSave;

  const LessonDialog({
    super.key,
    this.initialLesson,
    required this.subjects,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    AdminLessonModel? initialLesson,
    required List<AdminSubjectModel> subjects,
    required Future<void> Function({
      required String title,
      required String subjectId,
      List<int>? fileBytes,
      String? fileName,
      bool removeFile,
    }) onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => LessonDialog(
        initialLesson: initialLesson,
        subjects: subjects,
        onSave: onSave,
      ),
    );
  }

  @override
  State<LessonDialog> createState() => _LessonDialogState();
}

class _LessonDialogState extends State<LessonDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  String? _selectedSubjectId;
  String? _selectedFileName;
  List<int>? _selectedFileBytes;
  int? _selectedFileSize;
  bool _removedExistingFile = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isEdit => widget.initialLesson != null;
  static const int maxFileSize = 200 * 1024 * 1024; // 200 MB

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialLesson?.title ?? '');
    _selectedSubjectId = widget.initialLesson?.subjectId;
    if (_selectedSubjectId == null && widget.subjects.isNotEmpty) {
      _selectedSubjectId = widget.subjects.first.id;
    }
    _selectedFileName = widget.initialLesson?.fileName;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    setState(() => _errorMessage = null);
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final size = (await file.length()) ?? 0;

        if (size > maxFileSize) {
          setState(() {
            _errorMessage = 'Chỉ chấp nhận file PDF tối đa 200 MB';
          });
          return;
        }

        final bytes = await file.readAsBytes();
        setState(() {
          _selectedFileName = file.name;
          _selectedFileBytes = bytes;
          _selectedFileSize = size;
          _removedExistingFile = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể chọn file: $e';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null || _selectedSubjectId!.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng chọn môn học!');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final title = _titleController.text.trim();
      final bool removeFile = isEdit && _removedExistingFile && _selectedFileBytes == null;
      await widget.onSave(
        title: title,
        subjectId: _selectedSubjectId!,
        fileBytes: _selectedFileBytes,
        fileName: _selectedFileName,
        removeFile: removeFile,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
      ),
      backgroundColor: Colors.white,
      elevation: 16,
      child: Container(
        width: 560,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề (đúng theo ảnh Web 1920 - 3 & 5)
              Text(
                isEdit ? 'Sửa bài học' : 'Thêm bài học',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2238),
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),
              ],

              // Trường 1: Tên bài học
              const Text(
                'Tên bài học',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E2238)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1E2238), width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập tên bài học';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Trường 2: Môn học
              const Text(
                'Môn học',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E2238)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: widget.subjects.any((s) => s.id == _selectedSubjectId) ? _selectedSubjectId : null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1E2238), width: 1.5),
                  ),
                ),
                items: widget.subjects.map((sub) {
                  return DropdownMenuItem<String>(
                    value: sub.id,
                    child: Text(sub.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedSubjectId = val);
                },
                validator: (val) => val == null ? 'Vui lòng chọn môn học' : null,
              ),
              const SizedBox(height: 20),

              // Trường 3: Tài liệu (Vùng hiển thị hoặc kéo thả / chọn file PDF)
              const Text(
                'Tài liệu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E2238)),
              ),
              const SizedBox(height: 8),
              if (_selectedFileName != null &&
                  _selectedFileName!.trim().isNotEmpty &&
                  _selectedFileName != 'Chưa có file') ...[
                // Hiển thị file đã chọn kèm nút 'X' để gỡ file nếu chọn nhầm
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.description,
                          color: Color(0xFFD97706),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFileName!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2238),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _selectedFileSize != null
                                  ? (_selectedFileSize! >= 1024 * 1024
                                      ? '${(_selectedFileSize! / (1024 * 1024)).toStringAsFixed(1)} MB'
                                      : '${(_selectedFileSize! / 1024).round()} KB')
                                  : (widget.initialLesson?.fileSizeMb != null
                                      ? '${widget.initialLesson!.fileSizeMb!.toStringAsFixed(1)} MB'
                                      : 'Tệp PDF'),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nút đổi file khác
                      TextButton.icon(
                        onPressed: _pickPdfFile,
                        icon: const Icon(Icons.sync, size: 16, color: Color(0xFF2563EB)),
                        label: const Text('Đổi file', style: TextStyle(fontSize: 13, color: Color(0xFF2563EB))),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Nút "X" tròn đỏ để gỡ file PDF khi thêm nhầm
                      Tooltip(
                        message: 'Gỡ file PDF này',
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedFileName = null;
                              _selectedFileBytes = null;
                              _selectedFileSize = null;
                              _removedExistingFile = true;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Vùng kéo thả / chọn file PDF chuẩn theo ảnh Web 1920 - 3
                InkWell(
                  onTap: _pickPdfFile,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.upload_file_outlined,
                            size: 32,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Kéo và thả file vào đây để đưa lên',
                          style: TextStyle(fontSize: 14, color: Color(0xFF1E2238), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Hoặc chọn đường dẫn cho file .pdf (tối đa 200 MB)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // 2 Nút hành động
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E2238),
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Hủy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2238), // Nút xanh đen chuẩn ảnh
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Lưu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
