import 'package:flutter/material.dart';
import '../models/admin_subject_model.dart';

class SubjectFormDialog extends StatefulWidget {
  final AdminSubjectModel? initialSubject;
  final Future<void> Function(String code, String name, int displayOrder) onSave;

  const SubjectFormDialog({
    super.key,
    this.initialSubject,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    AdminSubjectModel? initialSubject,
    required Future<void> Function(String code, String name, int displayOrder) onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SubjectFormDialog(
        initialSubject: initialSubject,
        onSave: onSave,
      ),
    );
  }

  @override
  State<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _orderController;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isEdit => widget.initialSubject != null;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialSubject?.code ?? '');
    _nameController = TextEditingController(text: widget.initialSubject?.name ?? '');
    _orderController = TextEditingController(
      text: widget.initialSubject?.displayOrder.toString() ?? '1',
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final code = _codeController.text.trim();
      final name = _nameController.text.trim();
      final order = int.tryParse(_orderController.text.trim()) ?? 1;

      await widget.onSave(code, name, order);
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
          Icon(isEdit ? Icons.edit_note : Icons.add_circle_outline, color: Colors.blue.shade700, size: 28),
          const SizedBox(width: 10),
          Text(isEdit ? 'Sửa Môn Học' : 'Thêm Môn Học Mới', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 480,
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
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Mã môn học *',
                  hintText: 'Ví dụ: TRIET_HOC, CNXHKH, KTCT',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.code),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập mã môn học';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên môn học *',
                  hintText: 'Ví dụ: Triết học Mác - Lênin',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.menu_book),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập tên môn học';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Thứ tự hiển thị',
                  hintText: '1, 2, 3...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.sort),
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
