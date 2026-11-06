import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/screens/search_screen.dart';

void main() {
  testWidgets('SearchScreen renders properly in Light Mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        themeMode: ThemeMode.light,
        home: SearchScreen(),
      ),
    );

    expect(find.text('Tra cứu'), findsOneWidget);
    expect(find.text('Tính năng Tra cứu'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFF5F7FA));
  });

  testWidgets('SearchScreen renders properly in Dark Mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        home: const SearchScreen(),
      ),
    );

    expect(find.text('Tra cứu'), findsOneWidget);
    expect(find.text('Tính năng Tra cứu'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFF0F172A));

    final titleText = tester.widget<Text>(find.text('Tra cứu'));
    expect(titleText.style?.color, const Color(0xFFF8FAFC));

    final iconWidget = tester.widget<Icon>(find.byIcon(Icons.search_rounded));
    expect(iconWidget.color, const Color(0xFF38BDF8));
  });
}
