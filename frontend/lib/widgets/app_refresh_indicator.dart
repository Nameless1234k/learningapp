import 'package:flutter/material.dart';

// =========================================================================================
// [TÊN FILE: app_refresh_indicator.dart]
// [VỊ TRÍ]: lib/widgets/app_refresh_indicator.dart
// [MỤC ĐÍCH]: Widget dùng chung toàn ứng dụng để kích hoạt tính năng "Kéo để làm mới" (Pull-to-refresh).
// - Đồng bộ phong cách thiết kế, màu sắc thương hiệu (Brand Color: 0xFF15193B) và nền trắng.
// - Tái sử dụng ở mọi màn hình trong App (Môn học, Bài học, Trang chủ, Tra cứu, Cá nhân...).
// - Hỗ trợ kéo làm mới trên mọi trạng thái: danh sách có nội dung, danh sách rỗng, hoặc thông báo lỗi.
// =========================================================================================

class AppRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color color;
  final Color backgroundColor;
  final double displacement;
  final double edgeOffset;

  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color = const Color(0xFF15193B),
    this.backgroundColor = Colors.white,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
  });

  /// Scroll physics tiêu chuẩn đảm bảo luôn kéo vuốt được kể cả khi danh sách trống hoặc ngắn
  static const ScrollPhysics alwaysScrollPhysics = AlwaysScrollableScrollPhysics();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color,
      backgroundColor: backgroundColor,
      displacement: displacement,
      edgeOffset: edgeOffset,
      child: child,
    );
  }
}
