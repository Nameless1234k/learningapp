import 'package:flutter/material.dart';
import '../models/home_dashboard_model.dart';
import '../services/home_service.dart';
import '../services/user_session.dart';

// =========================================================================================
// [TÊN FILE: home_controller.dart]
// [VỊ TRÍ]: lib/controllers/home_controller.dart
// [MỤC ĐÍCH]: Controller (Pattern MVC) quản lý logic và trạng thái (State) của Trang chủ:
// - Quản lý trạng thái đang tải (isLoading), dữ liệu (dashboard), thông báo lỗi (errorMessage).
// - Cho phép gọi nạp lại (refresh) khi người dùng vuốt xuống hoặc đọc xong trở về Trang chủ.
// =========================================================================================

class HomeController extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  String? _errorMessage;
  HomeDashboardModel? _dashboard;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  HomeDashboardModel? get dashboard => _dashboard;

  /// Nạp dữ liệu Trang chủ và Phiên học hôm nay
  Future<void> loadDashboard({String? userId, bool isRefresh = false}) async {
    final effectiveUserId = userId ?? UserSession.currentUserId;
    if (effectiveUserId == null || effectiveUserId.isEmpty) {
      _errorMessage = 'Chưa xác định được phiên làm việc của người dùng.';
      notifyListeners();
      return;
    }

    if (!isRefresh) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await _homeService.getDashboard(effectiveUserId);
      _dashboard = result;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
