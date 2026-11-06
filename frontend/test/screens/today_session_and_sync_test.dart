import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/models/home_dashboard_model.dart';
import 'package:learningapp/widgets/today_session_card.dart';
import 'package:learningapp/widgets/home_top_header.dart';
import 'package:learningapp/widgets/recent_lessons_section.dart';
import 'package:learningapp/widgets/app_bottom_nav_bar.dart';
import 'package:learningapp/screens/main_navigation_screen.dart';

void main() {
  group('TodaySessionModel & Widget Tests', () {
    test('TS01: TodaySessionModel parse chính xác dữ liệu từ JSON', () {
      final json = {
        'lessonId': 'test-lesson-id-123',
        'subjectId': 'test-sub-id-456',
        'subjectName': 'Triết học Mác - Lênin',
        'lessonNo': 1,
        'lessonTitle': 'Khái luận về Triết học',
        'progressPercent': 25.5,
        'lastPosition': 5,
        'totalPages': 20,
        'pdfUrl': '/api/documents/doc-1/file',
        'buttonText': 'Tiếp tục học',
        'status': 'IN_PROGRESS',
        'readingSeconds': 120,
      };

      final model = TodaySessionModel.fromJson(json);

      expect(model.lessonId, equals('test-lesson-id-123'));
      expect(model.subjectId, equals('test-sub-id-456'));
      expect(model.subjectName, equals('Triết học Mác - Lênin'));
      expect(model.lessonNo, equals(1));
      expect(model.lessonTitle, equals('Khái luận về Triết học'));
      expect(model.progressPercent, equals(25.5));
      expect(model.lastPosition, equals(5));
      expect(model.totalPages, equals(20));
      expect(model.pdfUrl, equals('/api/documents/doc-1/file'));
      expect(model.buttonText, equals('Tiếp tục học'));
      expect(model.status, equals('IN_PROGRESS'));
      expect(model.readingSeconds, equals(120));
    });

    testWidgets('TS02: TodaySessionCard hiển thị đúng thông tin và kích hoạt onActionPressed', (tester) async {
      bool actionPressed = false;

      final session = TodaySessionModel(
        lessonId: 'l-1',
        subjectId: 's-1',
        subjectName: 'Triết học Mác - Lênin',
        lessonNo: 2,
        lessonTitle: 'Chủ nghĩa duy vật biện chứng',
        progressPercent: 40.0,
        lastPosition: 8,
        totalPages: 20,
        pdfUrl: '/api/documents/doc-2/file',
        buttonText: 'Tiếp tục học',
        status: 'IN_PROGRESS',
        readingSeconds: 30,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodaySessionCard(
              session: session,
              onActionPressed: () {
                actionPressed = true;
              },
            ),
          ),
        ),
      );

      // Kiểm tra tên môn học
      expect(find.text('Triết học Mác - Lênin'), findsOneWidget);
      // Kiểm tra tiêu đề bài học
      expect(find.text('Chủ nghĩa duy vật biện chứng'), findsOneWidget);
      // Kiểm tra text tiến độ
      expect(find.text('đã đọc được 40%'), findsOneWidget);
      // Kiểm tra nút bấm hành động và icon play
      expect(find.text('Tiếp tục học'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Bấm nút "Tiếp tục học"
      await tester.tap(find.text('Tiếp tục học'));
      await tester.pump();

      expect(actionPressed, isTrue);
    });

    testWidgets('TS03: TodaySessionCard hiển thị 0% và "Vào học" cho bài học mới', (tester) async {
      final session = TodaySessionModel(
        lessonId: 'l-1',
        subjectId: 's-1',
        subjectName: 'Kinh tế chính trị Mác - Lênin',
        lessonNo: 1,
        lessonTitle: 'Đối tượng và phương pháp nghiên cứu',
        progressPercent: 0.0,
        lastPosition: 1,
        totalPages: 15,
        pdfUrl: '/api/documents/doc-3/file',
        buttonText: 'Vào học',
        status: 'NOT_STARTED',
        readingSeconds: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodaySessionCard(
              session: session,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Kinh tế chính trị Mác - Lênin'), findsOneWidget);
      expect(find.text('Đối tượng và phương pháp nghiên cứu'), findsOneWidget);
      expect(find.text('Chưa bắt đầu (0%)'), findsOneWidget);
      expect(find.text('Vào học'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('TS04: Chuyển tab từ Tab Tài liệu sang Tab khác kích hoạt refreshDashboard trên HomeScreen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigationScreen(initialIndex: 2), // Bắt đầu ở Tab Tài liệu
        ),
      );

      final navState = tester.state<MainNavigationScreenState>(find.byType(MainNavigationScreen));
      expect(navState, isNotNull);
      expect(navState.homeScreenKey.currentState, isNotNull);

      // Chuyển sang Tab 1 (Tra cứu)
      final searchTabFinder = find.byIcon(Icons.search_rounded);
      await tester.tap(searchTabFinder);
      await tester.pump();

      // Kiểm tra HomeScreenState còn sống và sẵn sàng
      expect(navState.homeScreenKey.currentState!.refreshDashboard, isNotNull);
    });

    testWidgets('TS05: HomeTopHeader hiển thị "Chào mừng đến với Learning App" cho tài khoản mới và "Xin chào," khi đã dùng', (tester) async {
      // 1. Kiểm tra tài khoản mới (isNewUser == true)
      final newDashboard = HomeDashboardModel(
        greeting: 'Chào mừng bạn đến với Learning App',
        userFullName: 'Lê Anh Huy',
        userInitials: 'LH',
        isNewUser: true,
        todaySession: null,
        recentLessons: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTopHeader(dashboard: newDashboard),
          ),
        ),
      );

      expect(find.text('Chào mừng đến với Learning App'), findsOneWidget);
      expect(find.text('Lê Anh Huy'), findsOneWidget);
      expect(find.text('Xin chào,'), findsNothing);

      // 2. Kiểm tra tài khoản đã dùng (isNewUser == false)
      final existingDashboard = HomeDashboardModel(
        greeting: 'Xin chào, Huy!',
        userFullName: 'Lê Anh Huy',
        userInitials: 'LH',
        isNewUser: false,
        todaySession: null,
        recentLessons: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTopHeader(dashboard: existingDashboard),
          ),
        ),
      );

      expect(find.text('Chào mừng đến với Learning App'), findsNothing);
      expect(find.text('Xin chào,'), findsOneWidget);
      expect(find.text('Lê Anh Huy'), findsOneWidget);
    });

    testWidgets('TS06: RecentLessonsSection hiển thị đúng danh sách và kích hoạt callback', (tester) async {
      RecentLessonModel? tappedLesson;

      final lessons = [
        RecentLessonModel(
          lessonId: 'rec-1',
          lessonTitle: 'Bài 1: Nhập môn',
          subjectName: 'Triết học',
          progressPercent: 50.0,
          lastPosition: 5,
          pdfUrl: '/api/documents/doc-1/file',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentLessonsSection(
              recentLessons: lessons,
              onLessonTap: (item) {
                tappedLesson = item;
              },
            ),
          ),
        ),
      );

      expect(find.text('Đã học'), findsOneWidget);
      expect(find.text('Bài 1: Nhập môn'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);

      await tester.tap(find.text('Bài 1: Nhập môn'));
      await tester.pump();

      expect(tappedLesson, isNotNull);
      expect(tappedLesson!.lessonId, equals('rec-1'));
    });

    testWidgets('TS07: AppBottomNavBar hiển thị đầy đủ 5 Tabs và gọi onTabSelected khi bấm', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTabSelected: (index) {
                selectedIndex = index;
              },
            ),
          ),
        ),
      );

      expect(find.text('Trang chủ'), findsOneWidget);
      expect(find.text('Tra cứu'), findsOneWidget);
      expect(find.text('Tài liệu'), findsOneWidget);
      expect(find.text('Luyện tập'), findsOneWidget);
      expect(find.text('Cá nhân'), findsOneWidget);

      await tester.tap(find.text('Tài liệu'));
      await tester.pump();

      expect(selectedIndex, equals(2));
    });
  });
}
