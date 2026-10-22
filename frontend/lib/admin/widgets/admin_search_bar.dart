import 'dart:async';
import 'package:flutter/material.dart';

// =========================================================================================
// [TÊN FILE: admin_search_bar.dart]
// [VỊ TRÍ]: lib/admin/widgets/admin_search_bar.dart
// [MỤC ĐÍCH]: Widget Thanh tìm kiếm thông minh có Debounce dùng chung cho toàn bộ trang Admin.
// - Tự động quản lý Timer Debounce (350ms) khi người dùng gõ phím.
// - Tự động xóa kết quả lọc và trả về danh sách ban đầu tức thì (0ms) khi xóa hết chữ.
// - Nút Xóa (icon clear) và Icon Tìm kiếm (kính lúp) kích hoạt tìm kiếm tức thì.
// - Tái sử dụng ở: Quản trị tài khoản, Quản trị tài liệu, Quản trị bài học, Quản trị môn học.
// =========================================================================================

class AdminSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String> onSearch;
  final VoidCallback? onClear;
  final double height;
  final int debounceMs;

  const AdminSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Tìm kiếm...',
    required this.onSearch,
    this.onClear,
    this.height = 44,
    this.debounceMs = 350,
  });

  @override
  State<AdminSearchBar> createState() => _AdminSearchBarState();
}

class _AdminSearchBarState extends State<AdminSearchBar> {
  late TextEditingController _effectiveController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(covariant AdminSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller && widget.controller != null) {
      _effectiveController = widget.controller!;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  void _triggerSearchImmediate(String val) {
    _debounceTimer?.cancel();
    widget.onSearch(val.trim());
  }

  void _onChanged(String val) {
    setState(() {}); // Cập nhật trạng thái ẩn/hiện nút X
    _debounceTimer?.cancel();

    // Nếu ô tìm kiếm trống -> Hoàn nguyên ban đầu ngay lập tức với 0 delay
    if (val.trim().isEmpty) {
      widget.onSearch('');
      return;
    }

    // Khi người dùng đang gõ -> Chờ sau thời gian debounce mới tìm kiếm
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onSearch(val.trim());
    });
  }

  void _handleClear() {
    _effectiveController.clear();
    _debounceTimer?.cancel();
    setState(() {});
    if (widget.onClear != null) {
      widget.onClear!();
    } else {
      widget.onSearch('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.height / 2),
        border: Border.all(color: const Color(0xFF94A3B8), width: 1.5),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _effectiveController,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E2238)),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText,
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
          prefixIcon: Tooltip(
            message: 'Tìm kiếm',
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.height / 2),
              onTap: () => _triggerSearchImmediate(_effectiveController.text),
              child: const Padding(
                padding: EdgeInsets.only(left: 14, right: 8),
                child: Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: widget.height - 2, minHeight: widget.height - 2),
          suffixIcon: _effectiveController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: _handleClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: _onChanged,
        onSubmitted: _triggerSearchImmediate,
      ),
    );
  }
}
