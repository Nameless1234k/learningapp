import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../models/home_dashboard_model.dart';
import '../utils/url_helper.dart';
import '../widgets/app_refresh_indicator.dart';
import '../widgets/home_top_header.dart';
import '../widgets/today_session_card.dart';
import '../widgets/recent_lessons_section.dart';
import 'pdf_viewer_screen.dart';
import 'subject_detail_screen.dart';

// =========================================================================================
// [TÊN FILE: home_screen.dart]
// [VỊ TRÍ]: lib/screens/home_screen.dart
// [MÔ HÌNH KIẾN TRÚC]: MVC (Model - View - Controller):
// - Controller: HomeController quản lý toàn bộ trạng thái (State), tải dữ liệu và cờ loading/lỗi.
// - Views / Components:
//   + HomeTopHeader: Hiển thị avatar và lời chào (Chào mừng đến với Learning App cho tài khoản mới).
//   + TodaySessionCard: Thẻ Hero hiển thị bài học hôm nay kèm tiến độ và nút bấm.
//   + RecentLessonsSection: Danh sách các bài đã học gần đây.
// - Điều hướng theo luồng tài liệu: Khi bấm "Vào học" / "Tiếp tục học" sẽ chuyển tiếp theo luồng
//   Tab Tài liệu (Môn học -> Bài học -> PDF), để khi thoát PDF ra Bài học, thoát Bài học ra Môn học!
// - Zero-click Sync: Tự động đồng bộ và nạp lại khi thoát PDF hoặc chuyển tab.
// =========================================================================================

class HomeScreen extends StatefulWidget {
  final Function(int)? onSwitchTab;
  final void Function(TodaySessionModel session)? onOpenSessionInDocumentTab;

  const HomeScreen({
    super.key,
    this.onSwitchTab,
    this.onOpenSessionInDocumentTab,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();
    // Nạp dữ liệu Trang chủ từ Backend ngay khi mở ứng dụng
    _controller.loadDashboard();
  }

  /// Hàm làm mới ngầm được gọi tự động khi học viên từ Tab Tài liệu chuyển về Trang chủ
  void refreshDashboard() {
    if (mounted) {
      _controller.loadDashboard(isRefresh: true);
    }
  }

  /// Điều hướng từ Phiên học hôm nay theo chuẩn luồng tài liệu
  void _openTodaySession(TodaySessionModel session) {
    if (session.pdfUrl == null || session.pdfUrl!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('Bài học này chưa có tài liệu PDF đính kèm.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF15193B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Nếu có callback điều phối từ MainNavigationScreen -> Kích hoạt mở theo luồng Tab Tài liệu
    if (widget.onOpenSessionInDocumentTab != null) {
      widget.onOpenSessionInDocumentTab!(session);
      return;
    }

    // Fallback nếu chạy màn hình đơn lập (ví dụ trong widget test)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectDetailScreen(
          subjectId: session.subjectId,
          subjectName: session.subjectName,
          initialOpenLessonId: session.lessonId,
          initialOpenPdfUrl: session.pdfUrl,
          initialOpenTitle: 'Bài ${session.lessonNo}. ${session.lessonTitle}',
          initialOpenLastPosition: session.lastPosition,
          initialOpenReadingSeconds: session.readingSeconds,
          initialOpenIsRead: session.status == 'COMPLETED' || session.progressPercent >= 100.0,
        ),
      ),
    ).then((_) {
      refreshDashboard();
    });
  }

  /// Hàm mở xem lại bài học trực tiếp từ mục "Đã học"
  void _openRecentLesson(RecentLessonModel item) {
    if (item.pdfUrl == null || item.pdfUrl!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('Tài liệu của bài học này hiện đang được cập nhật.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF15193B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final fullUrl = UrlHelper.getFullPdfUrl(item.pdfUrl!);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          title: item.lessonTitle,
          pdfUrl: fullUrl,
          lessonId: item.lessonId,
          initialIsRead: item.progressPercent >= 100.0,
          initialReadingSeconds: 0,
          initialLastPosition: item.lastPosition,
        ),
      ),
    ).then((_) {
      refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFBFBFD),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final dashboard = _controller.dashboard;

            return AppRefreshIndicator(
              onRefresh: () => _controller.loadDashboard(isRefresh: true),
              child: SingleChildScrollView(
                physics: AppRefreshIndicator.alwaysScrollPhysics,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: _controller.errorMessage != null && dashboard == null
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                              const SizedBox(height: 12),
                              Text(
                                _controller.errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFF8FAFC) : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _controller.loadDashboard(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF15193B),
                                  foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. THANH TIÊU ĐỀ NGƯỜI DÙNG (TOP HEADER)
                          HomeTopHeader(dashboard: dashboard),
                          const SizedBox(height: 24),

                          // 2. KHỐI "PHIÊN HỌC HÔM NAY" (HERO CARD)
                          _buildTodaySessionSection(dashboard, isDark),
                          const SizedBox(height: 26),

                          // 3. KHỐI "ĐÃ HỌC" (RECENT LESSONS)
                          if (dashboard != null && dashboard.recentLessons.isNotEmpty) ...[
                            RecentLessonsSection(
                              recentLessons: dashboard.recentLessons,
                              onLessonTap: _openRecentLesson,
                            ),
                            const SizedBox(height: 26),
                          ],
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Widget Thẻ "Phiên học hôm nay"
  Widget _buildTodaySessionSection(HomeDashboardModel? dashboard, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHIÊN HỌC HÔM NAY',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF7E8B9B),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),

        if (_controller.isLoading && dashboard == null)
          // Khung Shimmer Loading khi đang tải dữ liệu lần đầu
          Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? const Color(0xFF38BDF8) : const Color(0xFF15193B),
              ),
            ),
          )
        else if (dashboard?.todaySession != null)
          // Hiển thị Thẻ Hero Phiên học hôm nay (tái sử dụng TodaySessionCard)
          TodaySessionCard(
            session: dashboard!.todaySession!,
            onActionPressed: () {
              _openTodaySession(dashboard.todaySession!);
            },
          )
        else
          // Trường hợp dự phòng nếu hệ thống chưa nạp dữ liệu bài học nào có PDF
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Hiện chưa có dữ liệu bài học có tài liệu PDF trong hệ thống.',
              style: TextStyle(
                color: isDark ? const Color(0xFFF8FAFC) : Colors.black87,
              ),
            ),
          ),
      ],
    );
  }
}
