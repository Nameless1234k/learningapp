import 'package:flutter/material.dart';

// =========================================================================================
// [TÊN FILE: admin_status_badge.dart]
// [VỊ TRÍ]: lib/admin/widgets/admin_status_badge.dart
// [MỤC ĐÍCH]: Component Huy hiệu trạng thái (Badge) dùng chung cho các bảng trong trang Admin.
// - Trạng thái tài khoản: Đang hoạt động (Xanh lá) / Tạm khóa (Đỏ)
// - Vai trò: Quản trị viên (ADMIN) / Học viên (USER)
// - Trạng thái tệp tài liệu: Đã đính kèm PDF / Chưa có file
// =========================================================================================

enum BadgeType { status, role, file }

class AdminStatusBadge extends StatelessWidget {
  final String label;
  final bool isActive;
  final BadgeType type;

  const AdminStatusBadge({
    super.key,
    required this.label,
    this.isActive = true,
    this.type = BadgeType.status,
  });

  factory AdminStatusBadge.userStatus(bool isActive) {
    return AdminStatusBadge(
      label: isActive ? 'Đang hoạt động' : 'Tạm khóa',
      isActive: isActive,
      type: BadgeType.status,
    );
  }

  factory AdminStatusBadge.role(String role) {
    final isAdmin = role.toUpperCase() == 'ADMIN';
    return AdminStatusBadge(
      label: isAdmin ? 'Quản trị viên' : 'Học viên',
      isActive: isAdmin,
      type: BadgeType.role,
    );
  }

  factory AdminStatusBadge.fileStatus(bool hasFile) {
    return AdminStatusBadge(
      label: hasFile ? 'Đã có file PDF' : 'Chưa có file',
      isActive: hasFile,
      type: BadgeType.file,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (type) {
      case BadgeType.status:
        bg = isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
        fg = isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
        border = isActive ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5);
        break;
      case BadgeType.role:
        bg = isActive ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9);
        fg = isActive ? const Color(0xFF1D4ED8) : const Color(0xFF475569);
        border = isActive ? const Color(0xFFBFDBFE) : const Color(0xFFCBD5E1);
        break;
      case BadgeType.file:
        bg = isActive ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED);
        fg = isActive ? const Color(0xFF166534) : const Color(0xFFC2410C);
        border = isActive ? const Color(0xFFBBF7D0) : const Color(0xFFFED7AA);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
