import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/theme_service.dart';
import 'services/user_session.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.init();
  await ThemeService.init(); // Nạp trạng thái Dark / Light Mode từ bộ nhớ máy
  runApp(const LearningApp());
}

class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: 'Learning App',
          themeMode: currentThemeMode,
          // Tắt hoạt ảnh lerp 200ms mặc định của Flutter để chuyển theme tức thì, loại bỏ hoàn toàn giật/khựng
          themeAnimationDuration: Duration.zero,

          // 1. GIAO DIỆN SÁNG (LIGHT THEME)
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF15193B),
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF15193B),
              secondary: Color(0xFF2563EB),
              surface: Colors.white,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),

          // 2. GIAO DIỆN TỐI (DARK THEME)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF38BDF8),
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
            cardColor: const Color(0xFF1E293B),               // Slate 800
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF38BDF8),
              secondary: Color(0xFF38BDF8),
              surface: Color(0xFF1E293B),
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),

          // AuthWrapper tự động duy trì phiên đăng nhập khi F5 hoặc mở lại ứng dụng
          home: const AuthWrapper(
            requiredRole: 'USER',
            authenticatedScreen: MainNavigationScreen(),
            unauthenticatedScreen: LoginScreen(),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
