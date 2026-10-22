import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/input_label.dart';
import 'main_navigation_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginController _loginController = LoginController();
  bool _isLoading = false;

  // [MỤC ĐÍCH FILE]: Giao diện thuần túy, quản lý các TextController, trạng thái loading UI, hiển thị thông báo.
  // Mọi tương tác UI (SnackBar, Chuyển trang) bắt buộc phải nằm ở đây, không nằm trong Controller.

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    // 1. Tự Screen bật trạng thái Loading
    setState(() { _isLoading = true; });

    // 2. Chuyển cho Controller xử lý logic mạng
    String? errorMessage = await _loginController.login(
      email: _emailController.text.trim(), 
      password: _passwordController.text.trim(),
    );

    if (!mounted) return; // Nếu màn hình đã bị đóng thì ngừng xử lý

    // 3. Tắt trạng thái Loading
    setState(() { _isLoading = false; });

    // 4. Quyết định hành động UI dựa trên kết quả Logic
    if (errorMessage != null) {
      // Có lỗi -> Hiển thị SnackBar đỏ
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      // Thành công -> Chuyển sang Màn hình chính có Bottom Navigation Bar (mặc định mở Tab Trang chủ)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Nền xanh xám nhạt cực sang
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Gradient & Logo
              const AuthHeader(
                title: 'Đăng nhập',
                subtitle: 'Tiếp tục hành trình học tập của bạn',
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const InputLabel(text: 'Email của bạn'),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'ví dụ: username@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        if (_passwordController.text.isNotEmpty) {
                          _login();
                        } else {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    const InputLabel(text: 'Mật khẩu'),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Nhập mật khẩu',
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                    ),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            color: Color(0xFF15193B),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    PrimaryButton(
                      text: 'Đăng nhập ngay',
                      onPressed: _login,
                      isLoading: _isLoading,
                    ),
                    
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Chưa có tài khoản? ',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                          },
                          child: const Text(
                            'Đăng ký miễn phí',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15193B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
