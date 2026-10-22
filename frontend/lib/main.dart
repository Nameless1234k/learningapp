import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/user_session.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.init();
  runApp(const LearningApp());
}

class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Tắt hoàn toàn hiệu ứng "xanh màn hình" (splash/highlight/hover) khi click vùng trống ở Web
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        // Cấu hình theme mặc định cho ứng dụng
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // AuthWrapper tự động duy trì phiên đăng nhập khi F5 hoặc mở lại ứng dụng
      home: const AuthWrapper(
        requiredRole: 'USER',
        authenticatedScreen: MainNavigationScreen(),
        unauthenticatedScreen: LoginScreen(),
      ),
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG ở góc phải màn hình
    );
  }
}
