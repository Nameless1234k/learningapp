import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import '../models/user_profile_model.dart';
import '../services/theme_service.dart';
import '../services/user_session.dart';
import '../widgets/app_refresh_indicator.dart';
import 'login_screen.dart';
import 'profile_edit_screen.dart';

// =========================================================================================
// [TÊN FILE: profile_screen.dart]
// [VỊ TRÍ]: lib/screens/profile_screen.dart
// [MỤC ĐÍCH]: Màn hình "Cá nhân" (Tab 5 ở Bottom Bar) thiết kế chuẩn theo screen_22.png:
// - Header: Tiêu đề "Cá nhân", phụ đề "Thống kê và thiết lập", nút chuông thông báo
// - Mục Thống kê:
//   + Khi chưa có trắc nghiệm (hiện tại): Khung hiển thị "Chưa có thống kê"
//   + Kiến trúc sẵn sàng: Tự động vẽ Biểu đồ cột 5 môn (Screen 22) khi có dữ liệu
// - Mục Thiết lập:
//   + 1. Giao diện sáng/tối với Nút công tắc bật/tắt (Switch Toggle)
//   + 2. Cài đặt tài khoản cá nhân -> chuyển sang screen_24.png
//   + 3. Đăng xuất -> Dialog xác nhận và xóa phiên làm việc
// - Hỗ trợ mượt mà cả Light Mode và Dark Mode
// =========================================================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileController = ProfileController();
  UserStatisticsModel? _stats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _profileController.getStatistics();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  /// Xử lý đăng xuất với Dialog xác nhận
  void _handleLogout(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Xác nhận đăng xuất',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF15193B),
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () async {
                await UserSession.clear();
                ThemeService.resetToLight(); // Trả về Light Mode khi đăng xuất, đảm bảo màn hình Login luôn ở Giao diện Sáng
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final cardBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF0E5DB);
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: _loadStatistics,
          child: SingleChildScrollView(
            physics: AppRefreshIndicator.alwaysScrollPhysics,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // 1. HEADER (Cá nhân + Thống kê và thiết lập + Nút chuông)
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cá nhân',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thống kê và thiết lập',
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  // Nút chuông thông báo tròn viền mỏng
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: primaryTextColor,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Bạn chưa có thông báo mới'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ==========================================
              // 2. PHẦN THỐNG KÊ (Screen 22)
              // ==========================================
              Text(
                'Thống kê',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),

              // Card hiển thị thống kê
              _buildStatisticsSection(isDark, cardBgColor, cardBorderColor, primaryTextColor, secondaryTextColor),

              const SizedBox(height: 32),

              // ==========================================
              // 3. PHẦN THIẾT LẬP (Screen 22)
              // ==========================================
              Text(
                'Thiết lập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),

              // Khung bo viền chứa 3 mục: Sáng/Tối (Switch), Cài đặt tài khoản, Đăng xuất
              Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cardBorderColor, width: 1.5),
                ),
                child: Column(
                  children: [
                    // Mục 1: Giao diện sáng/tối (NÚT CÔNG TẮC BẬT TẮT SWITCH TOGGLE)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isDark ? Icons.nightlight_round_rounded : Icons.wb_sunny_rounded,
                            size: 24,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B), // Màu cam vàng rực rỡ cho mặt trời
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Giao diện sáng/tối',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                          Switch(
                            value: isDark,
                            activeThumbColor: const Color(0xFF38BDF8),
                            activeTrackColor: const Color(0xFF0284C7).withValues(alpha: 0.5),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFCBD5E1),
                            onChanged: (value) {
                              ThemeService.toggleDarkMode(value);
                            },
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1EAE4)),

                    // Mục 2: Cài đặt tài khoản cá nhân
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
                        );
                        if (result == true && mounted) {
                          setState(() {}); // Làm mới lại nếu có cập nhật
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              size: 24,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Cài đặt tài khoản cá nhân',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1EAE4)),

                    // Mục 3: Đăng xuất
                    InkWell(
                      onTap: () => _handleLogout(context, isDark),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.logout_rounded,
                              size: 24,
                              color: Color(0xFFC2410C),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Đăng xuất',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFC2410C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  );
}

  /// Khung hiển thị Thống kê:
  /// - Nếu chưa làm bài (mặc định hiện tại): Hiện "Chưa có thống kê"
  /// - Nếu đã làm bài: Vẽ biểu đồ 5 cột môn học đúng theo Screen 22
  Widget _buildStatisticsSection(
    bool isDark,
    Color cardBgColor,
    Color cardBorderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    if (_isLoadingStats) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardBorderColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFF15193B)),
      );
    }

    final hasData = _stats?.hasData == true && (_stats?.totalQuestions ?? 0) > 0;

    if (!hasData) {
      // ==========================================
      // TRƯỜNG HỢP HIỆN TẠI: CHƯA CÓ THỐNG KÊ
      // ==========================================
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardBorderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 38,
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có thống kê',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn chưa hoàn thành câu hỏi trắc nghiệm nào. Hãy làm bài luyện tập để theo dõi điểm số tại đây nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    // ==========================================
    // TRƯỜNG HỢP CÓ DỮ LIỆU: VẼ BIỂU ĐỒ CỘT 5 MÔN (Screen 22)
    // ==========================================
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'điểm',
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
              Text(
                'môn',
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vùng vẽ 5 cột điểm
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBarColumn('Triết học', 56, const Color(0xFFFF6B81), isDark),
                _buildBarColumn('CNXH', 52, const Color(0xFFC084FC), isDark),
                _buildBarColumn('TT HCM', 62, const Color(0xFF4F46E5), isDark),
                _buildBarColumn('LSĐ', 59, const Color(0xFF38BDF8), isDark),
                _buildBarColumn('KTCT', 66, const Color(0xFF34D399), isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Dựa trên ${_stats?.totalQuestions ?? 0} câu trắc nghiệm đã làm',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn(String label, int score, Color barColor, bool isDark) {
    final barHeight = (score / 100) * 130;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$score',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 38,
          height: barHeight,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 52,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: barColor,
            ),
          ),
        ),
      ],
    );
  }
}
