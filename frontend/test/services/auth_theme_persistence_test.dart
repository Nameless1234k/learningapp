import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learningapp/services/theme_service.dart';
import 'package:learningapp/services/user_session.dart';
import 'package:learningapp/screens/login_screen.dart';
import 'package:learningapp/widgets/custom_text_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserSession.init();
    await UserSession.clear();
  });

  group('Auth Dark Mode Isolation & User Persistence Tests', () {
    test('Unauthenticated user always gets Light Mode on ThemeService.init()', () async {
      // User is not logged in
      expect(UserSession.isLoggedIn, false);

      await ThemeService.init();
      expect(ThemeService.themeModeNotifier.value, ThemeMode.light);
      expect(ThemeService.isDarkMode, false);
    });

    test('User dark mode preference is saved and restored on re-login', () async {
      // 1. Simulate user logging in
      const userId = 'user_123';
      await UserSession.saveSession(
        token: 'mock-jwt-token',
        userId: userId,
        email: 'user@example.com',
        role: 'USER',
        fullName: 'Test User',
      );
      expect(UserSession.isLoggedIn, true);

      // 2. Load user settings (initially light)
      await ThemeService.loadUserSettings(userId);
      expect(ThemeService.isDarkMode, false);

      // 3. User toggles Dark Mode to true
      await ThemeService.toggleDarkMode(true);
      expect(ThemeService.isDarkMode, true);
      expect(ThemeService.themeModeNotifier.value, ThemeMode.dark);

      // 4. User logs out -> theme must reset to Light Mode immediately
      await UserSession.clear();
      ThemeService.resetToLight();
      expect(UserSession.isLoggedIn, false);
      expect(ThemeService.themeModeNotifier.value, ThemeMode.light);
      expect(ThemeService.isDarkMode, false);

      // 5. User logs back in -> dark mode must be restored!
      await UserSession.saveSession(
        token: 'mock-jwt-token-2',
        userId: userId,
        email: 'user@example.com',
        role: 'USER',
        fullName: 'Test User',
      );
      await ThemeService.loadUserSettings(userId);
      expect(ThemeService.isDarkMode, true);
      expect(ThemeService.themeModeNotifier.value, ThemeMode.dark);
    });

    testWidgets('CustomTextField in LoginScreen has dark text color preventing white-on-white bug', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark, // Even if dark mode was active
          darkTheme: ThemeData.dark(),
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              hintText: 'Nhập email',
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.color, const Color(0xFF15193B));
    });

    testWidgets('LoginScreen renders with light background and visible text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.text('Đăng nhập'), findsWidgets);
      expect(find.text('Email của bạn'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF5F7FA));
    });
  });
}
