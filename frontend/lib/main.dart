import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
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
      // Đặt màn hình khởi chạy là LoginScreen
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG ở góc phải màn hình
    );
  }
}
