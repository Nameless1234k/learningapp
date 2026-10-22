import 'package:flutter/material.dart';
import '../controllers/admin_user_controller.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/status_confirm_dialog.dart';
import '../widgets/admin_hover_button.dart';
import '../widgets/admin_search_bar.dart';

// =========================================================================================
// [TÊN FILE: admin_user_screen.dart]
// [VỊ TRÍ]: lib/admin/screens/admin_user_screen.dart
// [MỤC ĐÍCH]: Màn hình Quản trị người dùng (View trong mô hình MVC).
// - Đã được tách toàn bộ logic nghiệp vụ và state sang AdminUserController.
// - File chỉ giữ lại phần hiển thị giao diện thuần túy, sạch sẽ và dễ bảo trì.
// =========================================================================================

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  final AdminUserController _controller = AdminUserController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLockAction() async {
    final validCount = _controller.validSelectedNonAdminIds.length;
    if (validCount == 0) {
      _showToast('Vui lòng chọn ít nhất một tài khoản (không thể thao tác trên Quản trị viên)!', isError: true);
      return;
    }

    final confirmed = await StatusConfirmDialog.show(
      context,
      title: 'Tạm khóa tài khoản',
      message: 'Chuyển $validCount tài khoản sang trạng thái tạm khóa?',
      isLockAction: true,
    );

    if (confirmed == true) {
      try {
        await _controller.lockSelectedUsers(currentKeyword: _searchController.text);
        _showToast('Đã tạm khóa các tài khoản đã chọn!');
      } catch (e) {
        _showToast(e.toString().replaceAll("Exception: ", ""), isError: true);
      }
    }
  }

  Future<void> _handleActivateAction() async {
    final validCount = _controller.validSelectedNonAdminIds.length;
    if (validCount == 0) {
      _showToast('Vui lòng chọn ít nhất một tài khoản (không thể thao tác trên Quản trị viên)!', isError: true);
      return;
    }

    final confirmed = await StatusConfirmDialog.show(
      context,
      title: 'Kích hoạt tài khoản',
      message: 'Chuyển $validCount tài khoản sang trạng thái hoạt động?',
      isLockAction: false,
    );

    if (confirmed == true) {
      try {
        await _controller.activateSelectedUsers(currentKeyword: _searchController.text);
        _showToast('Đã kích hoạt các tài khoản đã chọn!');
      } catch (e) {
        _showToast(e.toString().replaceAll("Exception: ", ""), isError: true);
      }
    }
  }

  Future<void> _handleDeleteAction() async {
    final validCount = _controller.validSelectedNonAdminIds.length;
    if (validCount == 0) {
      _showToast('Vui lòng chọn ít nhất một tài khoản (không thể thao tác trên Quản trị viên)!', isError: true);
      return;
    }

    final confirmed = await DeleteConfirmDialog.show(
      context,
      title: 'Xóa tài khoản',
      message: 'Bạn có chắc chắn muốn xóa $validCount tài khoản đã chọn?\nThao tác này không thể hoàn tác.',
    );

    if (confirmed == true) {
      try {
        await _controller.deleteSelectedUsers(currentKeyword: _searchController.text);
        _showToast('Đã xóa thành công $validCount tài khoản!');
      } catch (e) {
        _showToast(e.toString().replaceAll("Exception: ", ""), isError: true);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final displayUsers = _controller.filteredUsers;

        return Container(
          color: const Color(0xFFF3F4F6),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tiêu đề & Tổng số lượng tài khoản
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quản trị tài khoản',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2238),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Quản lý tài khoản người dùng',
                        style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Text(
                    '${displayUsers.length} tài khoản',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Action Toolbar: Tạm khóa | Kích hoạt | Xóa
              Row(
                children: [
                  AdminHoverButton(
                    onTap: _handleLockAction,
                    icon: Icons.lock_outline,
                    label: 'Tạm khóa',
                    textColor: const Color(0xFF475569),
                    backgroundColor: Colors.white,
                    hoverBackgroundColor: const Color(0xFFF1F5F9),
                    borderColor: const Color(0xFFCBD5E1),
                    hoverBorderColor: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 10),
                  AdminHoverButton(
                    onTap: _handleActivateAction,
                    icon: Icons.check_circle_outline,
                    label: 'Kích hoạt',
                    textColor: const Color(0xFF0F766E),
                    backgroundColor: Colors.white,
                    hoverBackgroundColor: const Color(0xFFF0FDF4),
                    borderColor: const Color(0xFFCBD5E1),
                    hoverBorderColor: const Color(0xFF86EFAC),
                    hoverTextColor: const Color(0xFF15803D),
                  ),
                  const SizedBox(width: 10),
                  AdminHoverButton(
                    onTap: _handleDeleteAction,
                    icon: Icons.delete_outline,
                    label: 'Xóa',
                    textColor: const Color(0xFFDC2626),
                    backgroundColor: Colors.white,
                    hoverBackgroundColor: const Color(0xFFFEF2F2),
                    borderColor: const Color(0xFFFECACA),
                    hoverBorderColor: const Color(0xFFEF4444),
                    hoverTextColor: const Color(0xFFB91C1C),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 3. Thanh Tìm kiếm & Dropdown lọc Role
              Row(
                children: [
                  SizedBox(
                    width: 380,
                    child: AdminSearchBar(
                      controller: _searchController,
                      hintText: 'Tìm kiếm theo tên, email...',
                      onSearch: (kw) => _controller.loadUsers(keyword: kw),
                      onClear: () => _controller.loadUsers(),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                        value: _controller.selectedRoleFilter,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF475569)),
                        items: const [
                          DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả')),
                          DropdownMenuItem(value: 'User', child: Text('User')),
                          DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        ],
                        onChanged: (val) {
                          if (val != null) _controller.setRoleFilter(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Bảng dữ liệu người dùng
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
                                    onPressed: () => _controller.loadUsers(),
                                    child: const Text('Thử lại'),
                                  ),
                                ],
                              ),
                            )
                          : displayUsers.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Không có dữ liệu người dùng.',
                                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                                  ),
                                )
                              : Column(
                                  children: [
                                    // Header bảng
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      decoration: const BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1.5)),
                                      ),
                                      child: Row(
                                        children: [
                                          Builder(
                                            builder: (context) {
                                              final nonAdminUsers = displayUsers.where((u) => u.role.toUpperCase() != 'ADMIN').toList();
                                              final isAllSelected = nonAdminUsers.isNotEmpty &&
                                                  nonAdminUsers.every((u) => _controller.selectedIds.contains(u.id));

                                              return SizedBox(
                                                width: 40,
                                                child: Checkbox(
                                                  value: isAllSelected,
                                                  onChanged: nonAdminUsers.isEmpty
                                                      ? null
                                                      : (val) => _controller.toggleSelectAll(val),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 16),
                                          const Expanded(flex: 3, child: Text('Người dùng', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 14))),
                                          const Expanded(flex: 2, child: Text('Vai trò', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 14))),
                                          const Expanded(flex: 2, child: Text('Số ĐT', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 14))),
                                          const Expanded(flex: 2, child: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 14))),
                                          const Expanded(flex: 2, child: Text('Ngày tạo', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 14))),
                                        ],
                                      ),
                                    ),

                                    // Danh sách dòng
                                    Expanded(
                                      child: ListView.separated(
                                        itemCount: displayUsers.length,
                                        separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0), height: 1),
                                        itemBuilder: (context, index) {
                                          final user = displayUsers[index];
                                          final isAdmin = user.role.toUpperCase() == 'ADMIN';
                                          final isSelected = !isAdmin && _controller.selectedIds.contains(user.id);

                                          final initials = user.firstName.isNotEmpty
                                              ? user.firstName.substring(0, 1).toUpperCase()
                                              : 'U';

                                          return Material(
                                            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                                            child: InkWell(
                                              hoverColor: isAdmin ? Colors.transparent : const Color(0xFFF1F5F9),
                                              onTap: isAdmin ? null : () => _controller.toggleSelect(user.id),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 40,
                                                      child: isAdmin
                                                          ? const Center(
                                                              child: Tooltip(
                                                                message: 'Tài khoản Quản trị viên được bảo vệ',
                                                                child: Icon(Icons.shield_outlined, size: 20, color: Color(0xFF94A3B8)),
                                                              ),
                                                            )
                                                          : Checkbox(
                                                              value: isSelected,
                                                              onChanged: (val) => _controller.toggleSelect(user.id),
                                                            ),
                                                    ),
                                                    const SizedBox(width: 16),

                                                    // Cột Người dùng: Avatar tròn + Tên + Email
                                                    Expanded(
                                                      flex: 3,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 42,
                                                            height: 42,
                                                            decoration: const BoxDecoration(
                                                              color: Color(0xFF26293D),
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                initials,
                                                                style: const TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 14),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  user.fullName,
                                                                  style: const TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Color(0xFF1E2238),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 2),
                                                                Text(
                                                                  user.email,
                                                                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Cột Vai trò
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        user.role == 'ADMIN' ? 'Admin' : 'User',
                                                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E2238), fontWeight: FontWeight.w500),
                                                      ),
                                                    ),

                                                    // Cột Số ĐT
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        user.phone ?? '—',
                                                        style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
                                                      ),
                                                    ),

                                                    // Cột Trạng thái pill xanh hoặc vàng
                                                    Expanded(
                                                      flex: 2,
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                                          decoration: BoxDecoration(
                                                            color: user.isActive
                                                                ? const Color(0xFF86EFAC)
                                                                : const Color(0xFFFDE047),
                                                            borderRadius: BorderRadius.circular(16),
                                                          ),
                                                          child: Text(
                                                            user.isActive ? 'Hoạt động' : 'Tạm khóa',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w600,
                                                              color: user.isActive ? const Color(0xFF14532D) : const Color(0xFF78350F),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // Cột Ngày tạo
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        user.createdAt,
                                                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
                                ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
