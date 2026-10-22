import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/admin_lesson_model.dart';
import '../models/admin_subject_model.dart';

class LessonFormDialog extends StatefulWidget {
  final AdminLessonModel? initialLesson;
  final List<AdminSubjectModel> subjects;
  final Future<void> Function({
    required String title,
    required String subjectId,
    List<int>? fileBytes,
    String? fileName,
  }) onSave;

  const LessonFormDialog({
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
    }) onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LessonFormDialog(
        initialLesson: initialLesson,
        subjects: subjects,
        onSave: onSave,
      ),
    );
  }

  @override
  State<LessonFormDialog> createState() => _LessonFormDialogState();
}

class _LessonFormDialogState extends State<LessonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  String? _selectedSubjectId;
  String? _selectedFileName;
  List<int>? _selectedFileBytes;
  int? _selectedFileSize;
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

        // Kiểm tra dung lượng tối đa 200MB theo sơ đồ đặc tả
        if (size > maxFileSize) {
          setState(() {
            _errorMessage = 'chi chap nhan file PDF toi da 200 MB';
          });
          return;
        }

        final bytes = await file.readAsBytes();
        setState(() {
          _selectedFileName = file.name;
          _selectedFileBytes = bytes;
          _selectedFileSize = size;
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
      await widget.onSave(
        title: title,
        subjectId: _selectedSubjectId!,
        fileBytes: _selectedFileBytes,
        fileName: _selectedFileName,
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(
        children: [
          Icon(isEdit ? Icons.edit_note : Icons.note_add, color: Colors.blue.shade700, size: 28),
          const SizedBox(width: 10),
          Text(isEdit ? 'Sửa Bài Học' : 'Thêm Bài Học Mới', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tên bài học *',
                  hintText: 'Ví dụ: Bài 1: Đối tượng, phương pháp nghiên cứu...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập tên bài học';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: widget.subjects.any((s) => s.id == _selectedSubjectId) ? _selectedSubjectId : null,
                decoration: InputDecoration(
                  labelText: 'Thuộc môn học *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.menu_book),
                ),
                items: widget.subjects.map((sub) {
                  return DropdownMenuItem<String>(
                    value: sub.id,
                    child: Text('${sub.code} - ${sub.name}', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedSubjectId = val);
                },
                validator: (val) => val == null ? 'Vui lòng chọn môn học' : null,
              ),
              const SizedBox(height: 16),
              const Text('File tài liệu PDF (Tối đa 200 MB):', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFileName ?? 'Chưa chọn file PDF',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _selectedFileName != null ? Colors.black87 : Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_selectedFileSize != null)
                            Text(
                              '${(_selectedFileSize! / (1024 * 1024)).toStringAsFixed(2)} MB',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickPdfFile,
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: Text(_selectedFileName != null ? 'Đổi File' : 'Chọn PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        elevation: 1,
                        side: BorderSide(color: Colors.blue.shade300),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      actions: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
