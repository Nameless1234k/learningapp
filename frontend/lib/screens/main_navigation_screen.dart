import 'package:flutter/material.dart';
import '../models/home_dashboard_model.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'document_list_screen.dart';
import 'practice_screen.dart';
import 'profile_screen.dart';
import 'subject_detail_screen.dart';

// =========================================================================================
// [TÊN FILE: main_navigation_screen.dart]
// [VỊ TRÍ]: lib/screens/main_navigation_screen.dart
// [MÔ HÌNH KIẾN TRÚC]: MVC (Màn hình điều phối Navigation chính):
// - Quản lý IndexedStack cho 5 màn hình tương ứng 5 Tabs.
// - Tái sử dụng View Component AppBottomNavBar.
// - Tự động đồng bộ và nạp lại ngầm dữ liệu Trang chủ và Danh sách tài liệu khi chuyển tab.
// - Luồng Tài liệu chuẩn (Môn học -> Bài học -> PDF):
//   Khi bấm "Vào học" / "Tiếp tục học" từ Trang chủ, ứng dụng chuyển sang Tab Tài liệu và
//   mở Bài học, để khi học viên thoát PDF sẽ ra Bài học, và thoát Bài học sẽ ra đúng Môn học!
// =========================================================================================

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  /// GlobalKey quản lý state màn hình Trang chủ để kích hoạt làm mới Phiên học hôm nay khi chuyển tab
  final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey<HomeScreenState>();

  /// GlobalKey quản lý state màn hình Danh sách tài liệu để kích hoạt làm mới khi chuyển tab
  final GlobalKey<DocumentListScreenState> documentListKey = GlobalKey<DocumentListScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _screens = [
      // Tab 0: Trang chủ (kèm callback chuyển sang luồng Tài liệu khi học)
      HomeScreen(
        key: homeScreenKey,
        onSwitchTab: _switchToTab,
        onOpenSessionInDocumentTab: _openTodaySessionInDocumentTab,
      ),
      // Tab 1: Tra cứu
      const SearchScreen(),
      // Tab 2: Tài liệu (Screen 9 - Danh sách môn học)
      DocumentListScreen(key: documentListKey),
      // Tab 3: Luyện tập
      const PracticeScreen(),
      // Tab 4: Cá nhân
      const ProfileScreen(),
    ];
  }

  /// Chuyển tab và tự động đồng bộ/làm mới dữ liệu mới nhất
  void _switchToTab(int index) {
    final prevIndex = _currentIndex;
    setState(() {
      _currentIndex = index;
    });
    _triggerTabRefresh(prevIndex, index);
  }

  /// Kích hoạt làm mới ngầm khi chuyển vào tab tương ứng
  void _triggerTabRefresh(int prevIndex, int newIndex) {
    // Nếu chuyển từ Tab 2 (Tài liệu) sang bất kỳ tab nào, hoặc chuyển vào Tab 0 (Trang chủ):
    // Tự động làm mới ngầm Phiên học hôm nay để lưu và phản ánh vị trí đọc mới nhất
    if (prevIndex == 2 || newIndex == 0) {
      homeScreenKey.currentState?.refreshDashboard();
    }
    if (newIndex == 2) {
      // Khi học viên bấm vào Tab 2 (Tài liệu): tự động làm mới ngầm dữ liệu danh sách môn học mới nhất
      documentListKey.currentState?.refresh(silent: true);
    }
  }

  /// Khi học viên bấm "Vào học" hoặc "Tiếp tục học" từ Trang chủ:
  /// Chuyển sang luồng Tài liệu (Tab 2 - Môn học), sau đó mở Trang bài học (SubjectDetailScreen)
  /// để khi thoát PDF -> sẽ ra đúng Trang bài học, và khi thoát Bài học -> sẽ ra đúng Trang môn học!
  void _openTodaySessionInDocumentTab(TodaySessionModel session) {
    // 1. Chuyển sang Tab 2 (Tài liệu / Danh sách môn học)
    _switchToTab(2);

    // 2. Mở SubjectDetailScreen lên trên màn hình Môn học
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
      // Khi học viên bấm nút "<--" trên SubjectDetailScreen để quay về DocumentListScreen (Môn học):
      // Tự động làm mới ngầm cả Trang chủ và Danh sách tài liệu
      homeScreenKey.currentState?.refreshDashboard();
      documentListKey.currentState?.refresh(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack giúp giữ nguyên trạng thái (State) của các tab, không bị tải lại từ đầu
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // Thanh điều hướng đáy tái sử dụng (AppBottomNavBar)
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _switchToTab,
      ),
    );
  }
}
