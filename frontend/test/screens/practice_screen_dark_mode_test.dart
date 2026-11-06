import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/screens/practice_screen.dart';

void main() {
  testWidgets('PracticeScreen renders properly in Light Mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        themeMode: ThemeMode.light,
        home: PracticeScreen(),
      ),
    );

    expect(find.text('Luyện tập'), findsOneWidget);
    expect(find.text('Luyện tập trắc nghiệm'), findsOneWidget);
    expect(find.byIcon(Icons.checklist_rounded), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFF5F7FA));
  });

  testWidgets('PracticeScreen renders properly in Dark Mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        home: const PracticeScreen(),
      ),
    );

    expect(find.text('Luyện tập'), findsOneWidget);
    expect(find.text('Luyện tập trắc nghiệm'), findsOneWidget);
    expect(find.byIcon(Icons.checklist_rounded), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFF0F172A));

    final titleText = tester.widget<Text>(find.text('Luyện tập'));
    expect(titleText.style?.color, const Color(0xFFF8FAFC));

    final iconWidget = tester.widget<Icon>(find.byIcon(Icons.checklist_rounded));
    expect(iconWidget.color, const Color(0xFF38BDF8));
  });
}
