import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/models/home_dashboard_model.dart';
import 'package:learningapp/widgets/home_top_header.dart';
import 'package:learningapp/widgets/today_session_card.dart';
import 'package:learningapp/widgets/recent_lessons_section.dart';

void main() {
  group('Tab 0 - Home Dark Mode & Light Mode Tests', () {
    testWidgets('TodaySessionCard renders correct theme colors in Dark Mode', (tester) async {
      final session = TodaySessionModel(
        subjectId: 'sub-1',
        subjectName: 'Chủ nghĩa Mác - Lênin',
        lessonId: '10',
        lessonNo: 1,
        lessonTitle: 'Triết học Mác - Lênin',
        progressPercent: 45.0,
        buttonText: 'Tiếp tục học',
        lastPosition: 120,
        totalPages: 200,
        readingSeconds: 300,
        status: 'IN_PROGRESS',
        pdfUrl: '/files/sample.pdf',
      );

      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark(),
          home: Scaffold(
            body: TodaySessionCard(
              session: session,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Triết học Mác - Lênin'), findsOneWidget);
      expect(find.text('Chủ nghĩa Mác - Lênin'), findsOneWidget);
      expect(find.text('Tiếp tục học'), findsOneWidget);

      final titleWidget = tester.widget<Text>(find.text('Triết học Mác - Lênin'));
      expect(titleWidget.style?.color, const Color(0xFFF8FAFC));

      final subjectWidget = tester.widget<Text>(find.text('Chủ nghĩa Mác - Lênin'));
      expect(subjectWidget.style?.color, const Color(0xFF38BDF8));
    });

    testWidgets('HomeTopHeader renders correct theme colors in Dark Mode', (tester) async {
      final dashboard = HomeDashboardModel(
        greeting: 'Xin chào,',
        userFullName: 'Nguyen Van A',
        userInitials: 'NA',
        isNewUser: false,
        todaySession: null,
        recentLessons: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark(),
          home: Scaffold(
            body: HomeTopHeader(dashboard: dashboard),
          ),
        ),
      );

      expect(find.text('Xin chào,'), findsOneWidget);
      expect(find.text('Nguyen Van A'), findsOneWidget);
      expect(find.text('NA'), findsOneWidget);

      final greeting = tester.widget<Text>(find.text('Xin chào,'));
      expect(greeting.style?.color, const Color(0xFF94A3B8));

      final name = tester.widget<Text>(find.text('Nguyen Van A'));
      expect(name.style?.color, const Color(0xFFF8FAFC));
    });

    testWidgets('RecentLessonsSection renders correct theme colors in Dark Mode', (tester) async {
      final lessons = [
        RecentLessonModel(
          lessonId: '1',
          lessonTitle: 'Bài 1: Khái luận Triết học',
          subjectName: 'Triết học',
          progressPercent: 100.0,
          lastPosition: 200,
          pdfUrl: '/files/b1.pdf',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark(),
          home: Scaffold(
            body: RecentLessonsSection(
              recentLessons: lessons,
              onLessonTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Đã học'), findsOneWidget);
      expect(find.text('Bài 1: Khái luận Triết học'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);

      final title = tester.widget<Text>(find.text('Đã học'));
      expect(title.style?.color, const Color(0xFFF8FAFC));

      final lessonTitle = tester.widget<Text>(find.text('Bài 1: Khái luận Triết học'));
      expect(lessonTitle.style?.color, const Color(0xFFF8FAFC));
    });
  });
}
