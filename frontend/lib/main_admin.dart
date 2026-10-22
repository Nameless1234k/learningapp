import 'package:flutter/material.dart';
import 'admin/screens/admin_layout.dart';
import 'admin/screens/admin_login_screen.dart';
import 'services/user_session.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.init();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hệ Thống Quản Trị - Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          primary: const Color(0xFF1D4ED8),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // AuthWrapper bảo vệ trang Admin: Tự động giữ phiên khi F5 nếu là ADMIN
      home: const AuthWrapper(
        requiredRole: 'ADMIN',
        authenticatedScreen: AdminLayout(),
        unauthenticatedScreen: AdminLoginScreen(),
      ),
    );
  }
}
