import 'package:flutter/material.dart';
import '../models/admin_subject_model.dart';
import '../services/admin_api_service.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/subject_form_dialog.dart';

class AdminSubjectScreen extends StatefulWidget {
  const AdminSubjectScreen({super.key});

  @override
  State<AdminSubjectScreen> createState() => _AdminSubjectScreenState();
}

class _AdminSubjectScreenState extends State<AdminSubjectScreen> {
  final AdminApiService _apiService = AdminApiService();
  final TextEditingController _searchController = TextEditingController();

  List<AdminSubjectModel> _subjects = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects({String? keyword}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _apiService.getSubjects(keyword: keyword);
      setState(() {
        _subjects = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  void _onSearch(String value) {
    _loadSubjects(keyword: value.trim());
  }

  void _openAddDialog() {
    SubjectFormDialog.show(
      context,
      onSave: (code, name, displayOrder) async {
        await _apiService.createSubject(code, name, displayOrder);
        _showToast('Đã thêm môn học thành công!');
        _loadSubjects(keyword: _searchController.text);
      },
    );
  }

  void _openEditDialog(AdminSubjectModel subject) {
    SubjectFormDialog.show(
      context,
      initialSubject: subject,
      onSave: (code, name, displayOrder) async {
        await _apiService.updateSubject(subject.id, code, name, displayOrder);
        _showToast('Đã cập nhật môn học thành công!');
        _loadSubjects(keyword: _searchController.text);
      },
    );
  }

  Future<void> _deleteSubject(AdminSubjectModel subject) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Xóa môn học',
      message: 'Bạn có chắc chắn muốn xóa môn học "${subject.name}" (${subject.code}) không?',
      confirmText: 'Xác nhận xóa',
      cancelText: 'Hủy',
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteSubject(subject.id);
        _showToast('Đã xóa môn học thành công!');
        _loadSubjects(keyword: _searchController.text);
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
          // Toolbar: Tìm kiếm & Nút thêm
          Row(
            children: [
              Expanded(
                flex: 3,
                child: AdminSearchBar(
                  controller: _searchController,
                  hintText: 'Tìm kiếm theo tên hoặc mã môn học...',
                  onSearch: _onSearch,
                  onClear: () => _onSearch(''),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _onSearch(_searchController.text),
                icon: const Icon(Icons.search, size: 20),
                label: const Text('Tìm kiếm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openAddDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Thêm môn học mới'),
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

          // Bảng môn học (DataTable)
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
                                onPressed: () => _loadSubjects(),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : _subjects.isEmpty
                          ? const Center(
                              child: Text(
                                'Chưa có môn học nào hoặc không tìm thấy kết quả.',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                horizontalMargin: 20,
                                columnSpacing: 30,
                                columns: const [
                                  DataColumn(label: Text('Mã môn học', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Tên môn học', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Thứ tự hiển thị', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Ngày tạo', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: _subjects.map((sub) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.indigo.shade200),
                                          ),
                                          child: Text(
                                            sub.code,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade800,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                                      DataCell(Text(sub.displayOrder.toString())),
                                      DataCell(Text(sub.createdAt ?? '—', style: const TextStyle(color: Colors.grey, fontSize: 13))),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                              tooltip: 'Sửa môn học',
                                              onPressed: () => _openEditDialog(sub),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                              tooltip: 'Xóa môn học',
                                              onPressed: () => _deleteSubject(sub),
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
