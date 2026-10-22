import 'package:flutter/foundation.dart';
import '../models/admin_user_model.dart';
import '../services/admin_api_service.dart';

// =========================================================================================
// [TÊN FILE: admin_user_controller.dart]
// [VỊ TRÍ]: lib/admin/controllers/admin_user_controller.dart
// [MỤC ĐÍCH]: Controller quản lý State và Logic nghiệp vụ màn hình Quản trị người dùng (MVC).
// - Kế thừa ChangeNotifier để phát tín hiệu cập nhật giao diện tự động.
// - Tách biệt hoàn toàn khỏi Widget UI (AdminUserScreen), giúp code sạch sẽ và dễ test.
// =========================================================================================

class AdminUserController extends ChangeNotifier {
  final AdminApiService _apiService;

  AdminUserController({AdminApiService? apiService})
      : _apiService = apiService ?? AdminApiService();

  List<AdminUserModel> _allUsers = [];
  final Set<String> _selectedIds = {};
  String _selectedRoleFilter = 'Tất cả';
  bool _isLoading = false;
  String? _errorMessage;

  List<AdminUserModel> get allUsers => _allUsers;
  Set<String> get selectedIds => _selectedIds;
  String get selectedRoleFilter => _selectedRoleFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Danh sách người dùng sau khi áp dụng bộ lọc và sắp xếp nghiệp vụ
  List<AdminUserModel> get filteredUsers {
    List<AdminUserModel> list = _allUsers;
    if (_selectedRoleFilter != 'Tất cả') {
      list = list.where((u) => u.role.toUpperCase() == _selectedRoleFilter.toUpperCase()).toList();
    } else {
      list = List.from(list);
    }

    // Sắp xếp:
    // 1. Tài khoản ADMIN luôn nằm lên đầu tiên (vị trí số 1)
    // 2. Các tài khoản người dùng sắp xếp theo ngày tạo sớm nhất nằm ở vị trí thứ 2 và tăng dần
    list.sort((a, b) {
      final aIsAdmin = a.role.toUpperCase() == 'ADMIN';
      final bIsAdmin = b.role.toUpperCase() == 'ADMIN';
      if (aIsAdmin && !bIsAdmin) return -1;
      if (!aIsAdmin && bIsAdmin) return 1;

      // Cùng là ADMIN hoặc cùng là USER: Sắp xếp theo ngày tạo sớm nhất lên trước (tăng dần)
      final parseA = DateTime.tryParse(a.createdAt);
      final parseB = DateTime.tryParse(b.createdAt);
      if (parseA != null && parseB != null) {
        return parseA.compareTo(parseB);
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return list;
  }

  /// Danh sách ID hợp lệ được chọn (tự động loại trừ tài khoản ADMIN khỏi thao tác khóa/xóa)
  List<String> get validSelectedNonAdminIds {
    return _selectedIds.where((id) {
      final u = _allUsers.firstWhere(
        (x) => x.id == id,
        orElse: () => AdminUserModel(
          id: '',
          lastName: '',
          firstName: '',
          fullName: '',
          email: '',
          role: 'USER',
          isActive: false,
          createdAt: '',
        ),
      );
      return u.role.toUpperCase() != 'ADMIN';
    }).toList();
  }

  /// Tải danh sách người dùng từ API Backend
  Future<void> loadUsers({String? keyword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _apiService.getUsers(keyword: keyword);
      _allUsers = list;
      _isLoading = false;
      _selectedIds.clear();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }

  /// Đổi bộ lọc vai trò (Tất cả / User / Admin)
  void setRoleFilter(String role) {
    if (_selectedRoleFilter != role) {
      _selectedRoleFilter = role;
      notifyListeners();
    }
  }

  /// Chọn / Bỏ chọn 1 tài khoản cụ thể
  void toggleSelect(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Chọn tất cả / Bỏ chọn tất cả người dùng không phải ADMIN
  void toggleSelectAll(bool? val) {
    final nonAdminUsers = filteredUsers.where((u) => u.role.toUpperCase() != 'ADMIN').toList();
    if (val == true) {
      _selectedIds.addAll(nonAdminUsers.map((u) => u.id));
    } else {
      _selectedIds.removeAll(nonAdminUsers.map((u) => u.id));
    }
    notifyListeners();
  }

  /// Tạm khóa các tài khoản đã chọn (bảo vệ tài khoản ADMIN)
  Future<void> lockSelectedUsers({String? currentKeyword}) async {
    final validIds = validSelectedNonAdminIds;
    if (validIds.isEmpty) {
      throw Exception('Vui lòng chọn ít nhất một tài khoản (không thể thao tác trên Quản trị viên)!');
    }
    await _apiService.bulkUpdateStatus(validIds, false);
    await loadUsers(keyword: currentKeyword);
  }

  /// Kích hoạt các tài khoản đã chọn
  Future<void> activateSelectedUsers({String? currentKeyword}) async {
    final validIds = validSelectedNonAdminIds;
    if (validIds.isEmpty) {
      throw Exception('Vui lòng chọn ít nhất một tài khoản (không thể thao tác trên Quản trị viên)!');
    }
    await _apiService.bulkUpdateStatus(validIds, true);
    await loadUsers(keyword: currentKeyword);
  }

  /// Xóa các tài khoản đã chọn
  Future<void> deleteSelectedUsers({String? currentKeyword}) async {
    final validIds = validSelectedNonAdminIds;
    if (validIds.isEmpty) {
      throw Exception('Vui lòng chọn ít nhất một tài khoản (không thể thao tác trên Quản trị viên)!');
    }
    await _apiService.bulkDeleteUsers(validIds);
    await loadUsers(keyword: currentKeyword);
  }
}
