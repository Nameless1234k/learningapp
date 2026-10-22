import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/admin_lesson_model.dart';
import '../models/admin_subject_model.dart';
import '../services/admin_api_service.dart';

// =========================================================================================
// [TÊN FILE: admin_document_controller.dart]
// [VỊ TRÍ]: lib/admin/controllers/admin_document_controller.dart
// [MỤC ĐÍCH]: Controller quản lý State và Logic nghiệp vụ Quản trị tài liệu (Bài học & Môn học).
// - Kế thừa ChangeNotifier phát thông báo tự động tới View (AdminDocumentScreen).
// - Quản lý việc chuyển tab, lọc môn học, đa cấp sắp xếp, tính toán kích thước file MB,
//   và các tác vụ CRUD (Thêm, Sửa, Xóa).
// =========================================================================================

class AdminDocumentController extends ChangeNotifier {
  final AdminApiService _apiService;

  AdminDocumentController({AdminApiService? apiService})
      : _apiService = apiService ?? AdminApiService();

  int _selectedSubTab = 0; // 0 = Bài học, 1 = Môn học
  List<AdminLessonModel> _lessons = [];
  List<AdminSubjectModel> _subjects = [];
  final Set<String> _selectedItemIds = {};

  String? _selectedSubjectFilter;
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, double> _fileSizesCache = {};

  int get selectedSubTab => _selectedSubTab;
  bool get isLessonTab => _selectedSubTab == 0;
  List<AdminLessonModel> get lessons => _lessons;
  List<AdminSubjectModel> get subjects => _subjects;
  Set<String> get selectedItemIds => _selectedItemIds;
  String? get selectedSubjectFilter => _selectedSubjectFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, double> get fileSizesCache => _fileSizesCache;

  void sortSubjects(List<AdminSubjectModel> list) {
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  void sortLessons(List<AdminLessonModel> list, List<AdminSubjectModel> subs) {
    final subOrderMap = {for (var s in subs) s.id: s.displayOrder};
    list.sort((a, b) {
      final orderA = a.subjectDisplayOrder != 0
          ? a.subjectDisplayOrder
          : (subOrderMap[a.subjectId] ?? 999);
      final orderB = b.subjectDisplayOrder != 0
          ? b.subjectDisplayOrder
          : (subOrderMap[b.subjectId] ?? 999);

      if (orderA != orderB) {
        return orderA.compareTo(orderB);
      }
      return a.lessonNo.compareTo(b.lessonNo);
    });
  }

  Future<void> fetchMissingFileSizes(List<AdminLessonModel> lessons) async {
    for (final lesson in lessons) {
      if (lesson.fileSizeMb != null) {
        _fileSizesCache[lesson.id] = lesson.fileSizeMb!;
        continue;
      }
      if (lesson.fileName == null ||
          lesson.fileName!.trim().isEmpty ||
          lesson.fileName == 'Chưa có file') {
        continue;
      }
      if (_fileSizesCache.containsKey(lesson.id)) continue;

      String fileUrl = _apiService.getDocumentFileUrl(
        documentId: lesson.documentId,
        filePath: lesson.filePath,
      );

      http.head(Uri.parse(fileUrl)).then((res) {
        if (res.statusCode == 200) {
          final len = res.headers['content-length'];
          if (len != null) {
            final bytes = int.tryParse(len);
            if (bytes != null) {
              final mb = (bytes / (1024 * 1024) * 10).round() / 10;
              _fileSizesCache[lesson.id] = mb;
              notifyListeners();
            }
          }
        }
      }).catchError((_) {});
    }
  }

  /// Tải toàn bộ dữ liệu ban đầu gồm Môn học và Bài học
  Future<void> loadAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final subs = await _apiService.getSubjects();
      sortSubjects(subs);
      final less = await _apiService.getLessons();
      sortLessons(less, subs);

      _subjects = subs;
      _lessons = less;
      _isLoading = false;
      _selectedItemIds.clear();
      notifyListeners();

      fetchMissingFileSizes(less);
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }

  /// Làm mới dữ liệu theo Tab hiện tại và từ khóa tìm kiếm
  Future<void> reloadCurrentTab({String? keyword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_selectedSubTab == 0) {
        if (_subjects.isEmpty) {
          _subjects = await _apiService.getSubjects();
          sortSubjects(_subjects);
        }
        final less = await _apiService.getLessons(
          subjectId: _selectedSubjectFilter,
          keyword: keyword?.trim(),
        );
        sortLessons(less, _subjects);
        _lessons = less;
        _isLoading = false;
        _selectedItemIds.clear();
        notifyListeners();

        fetchMissingFileSizes(less);
      } else {
        final subs = await _apiService.getSubjects(keyword: keyword?.trim());
        sortSubjects(subs);
        _subjects = subs;
        _isLoading = false;
        _selectedItemIds.clear();
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }

  /// Chuyển đổi giữa 2 tab: 0 (Bài học) và 1 (Môn học)
  void setSubTab(int index, {String? currentKeyword}) {
    if (_selectedSubTab == index) return;
    _selectedSubTab = index;
    _selectedItemIds.clear();
    reloadCurrentTab(keyword: currentKeyword);
  }

  /// Thay đổi bộ lọc môn học
  void setSubjectFilter(String? filter, {String? currentKeyword}) {
    _selectedSubjectFilter = filter;
    reloadCurrentTab(keyword: currentKeyword);
  }

  /// Chọn / Bỏ chọn 1 mục
  void toggleItem(String id) {
    if (_selectedItemIds.contains(id)) {
      _selectedItemIds.remove(id);
    } else {
      _selectedItemIds.add(id);
    }
    notifyListeners();
  }

  /// Chọn tất cả / Bỏ chọn tất cả mục trong tab hiện tại
  void toggleSelectAll(bool? val) {
    if (val == true) {
      if (_selectedSubTab == 0) {
        _selectedItemIds.addAll(_lessons.map((l) => l.id));
      } else {
        _selectedItemIds.addAll(_subjects.map((s) => s.id));
      }
    } else {
      _selectedItemIds.clear();
    }
    notifyListeners();
  }

  /// Tạo bài học mới
  Future<void> createLesson({
    required String title,
    required String subjectId,
    List<int>? fileBytes,
    String? fileName,
    String? currentKeyword,
  }) async {
    await _apiService.createLesson(
      title: title,
      subjectId: subjectId,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    await reloadCurrentTab(keyword: currentKeyword);
  }

  /// Cập nhật bài học
  Future<void> updateLesson({
    required String id,
    required String title,
    required String subjectId,
    List<int>? fileBytes,
    String? fileName,
    bool removeFile = false,
    String? currentKeyword,
  }) async {
    await _apiService.updateLesson(
      id: id,
      title: title,
      subjectId: subjectId,
      fileBytes: fileBytes,
      fileName: fileName,
      removeFile: removeFile,
    );
    await reloadCurrentTab(keyword: currentKeyword);
  }

  /// Tạo môn học mới
  Future<void> createSubject({
    required String code,
    required String name,
    required int displayOrder,
    String? currentKeyword,
  }) async {
    await _apiService.createSubject(code, name, displayOrder);
    await reloadCurrentTab(keyword: currentKeyword);
  }

  /// Cập nhật môn học
  Future<void> updateSubject({
    required String id,
    required String code,
    required String name,
    required int displayOrder,
    String? currentKeyword,
  }) async {
    await _apiService.updateSubject(id, code, name, displayOrder);
    await reloadCurrentTab(keyword: currentKeyword);
  }

  /// Xóa các mục đã chọn trong tab hiện tại
  Future<void> deleteSelectedItems({String? currentKeyword}) async {
    if (_selectedItemIds.isEmpty) return;

    for (final id in _selectedItemIds) {
      if (_selectedSubTab == 0) {
        await _apiService.deleteLesson(id);
      } else {
        await _apiService.deleteSubject(id);
      }
    }
    await reloadCurrentTab(keyword: currentKeyword);
  }
}
