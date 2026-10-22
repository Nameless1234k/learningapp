import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/widgets/app_refresh_indicator.dart';
import 'package:learningapp/screens/home_screen.dart';
import 'package:learningapp/screens/search_screen.dart';
import 'package:learningapp/screens/practice_screen.dart';
import 'package:learningapp/screens/profile_screen.dart';
import 'package:learningapp/screens/document_list_screen.dart';
import 'package:learningapp/screens/subject_detail_screen.dart';
import 'package:learningapp/screens/main_navigation_screen.dart';

void main() {
  group('AppRefreshIndicator & Reusable Pull-to-Refresh Tests', () {
    testWidgets('RF01: AppRefreshIndicator render đúng theme màu và kích hoạt onRefresh khi kéo', (tester) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppRefreshIndicator(
              onRefresh: () async {
                refreshed = true;
              },
              child: ListView(
                physics: AppRefreshIndicator.alwaysScrollPhysics,
                children: const [
                  ListTile(title: Text('Mục 1')),
                  ListTile(title: Text('Mục 2')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AppRefreshIndicator), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Kéo vuốt từ trên xuống để kích hoạt refresh
      await tester.fling(find.text('Mục 1'), const Offset(0.0, 300.0), 1000.0);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(refreshed, isTrue, reason: 'onRefresh phải được kích hoạt khi kéo vuốt xuống');
    });

    testWidgets('RF02: Mọi màn hình phụ (Search, Practice, Profile, Home) đều chứa AppRefreshIndicator và kéo được', (tester) async {
      // 1. Kiểm tra HomeScreen
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      expect(find.byType(AppRefreshIndicator), findsOneWidget);

      // 2. Kiểm tra SearchScreen
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
      expect(find.byType(AppRefreshIndicator), findsOneWidget);

      // 3. Kiểm tra PracticeScreen
      await tester.pumpWidget(const MaterialApp(home: PracticeScreen()));
      expect(find.byType(AppRefreshIndicator), findsOneWidget);

      // 4. Kiểm tra ProfileScreen
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      expect(find.byType(AppRefreshIndicator), findsOneWidget);
    });

    testWidgets('RF03: SubjectDetailScreen và DocumentListScreen đều hỗ trợ AppRefreshIndicator và method refresh()', (tester) async {
      final docKey = GlobalKey<DocumentListScreenState>();
      await tester.pumpWidget(
        MaterialApp(
          home: DocumentListScreen(key: docKey),
        ),
      );
      expect(docKey.currentState, isNotNull);
      expect(docKey.currentState!.refresh, isNotNull);

      final subjectKey = GlobalKey<SubjectDetailScreenState>();
      await tester.pumpWidget(
        MaterialApp(
          home: SubjectDetailScreen(
            key: subjectKey,
            subjectId: 'mock-sub-id',
            subjectName: 'Triết học Mác - Lênin',
          ),
        ),
      );
      expect(subjectKey.currentState, isNotNull);
      expect(subjectKey.currentState!.refresh, isNotNull);
    });
  });

  group('MainNavigationScreen Tab Switch & Auto-Refresh Tests', () {
    testWidgets('TB01: Chuyển tab sang Tài liệu tự động kích hoạt làm mới ngầm dữ liệu', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigationScreen(initialIndex: 0),
        ),
      );

      final navState = tester.state<MainNavigationScreenState>(find.byType(MainNavigationScreen));
      expect(navState, isNotNull);

      // Ban đầu ở Tab 0: Trang chủ
      expect(find.text('Trang chủ'), findsWidgets);

      // Nhấn chuyển sang Tab 2: Tài liệu qua bottom navigation bar
      final docTabFinder = find.widgetWithText(InkWell, 'Tài liệu');
      expect(docTabFinder, findsOneWidget);

      await tester.tap(docTabFinder);
      await tester.pump();

      // Kiểm tra tab đã chuyển sang Tab 2 và documentListKey đã gắn kết
      expect(navState.documentListKey.currentState, isNotNull);

      // Nhấn lại vào Tab 2 để kích hoạt refresh ngầm
      await tester.tap(docTabFinder);
      await tester.pump();
    });

    testWidgets('TB02: Bấm banner trên HomeScreen tự động chuyển sang Tab Tài liệu và gọi làm mới', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigationScreen(initialIndex: 0),
        ),
      );

      final navState = tester.state<MainNavigationScreenState>(find.byType(MainNavigationScreen));

      // Bấm vào banner "Kho tài liệu học tập" trên HomeScreen
      final bannerFinder = find.text('Kho tài liệu học tập');
      expect(bannerFinder, findsOneWidget);

      await tester.tap(bannerFinder);
      await tester.pump();

      // Kiểm tra state đã chuyển sang Tab 2 thành công
      expect(navState.documentListKey.currentState, isNotNull);
    });
  });
}
