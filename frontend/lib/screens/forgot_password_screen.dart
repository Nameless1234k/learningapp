import 'package:flutter/material.dart';
import '../controllers/forgot_password_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/input_label.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final ForgotPasswordController _forgotPasswordController = ForgotPasswordController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    final errorMessage = await _forgotPasswordController.sendOtp(
      _emailController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyOtpScreen(email: _emailController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Khôi phục truy cập',
                style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Quên mật khẩu',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nhập email đã đăng ký, chúng tôi sẽ gửi mã xác thực gồm 6 chữ số.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              const InputLabel(text: 'Email'),
              CustomTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'VD: username@gmail.com',
                prefixIcon: Icons.email_outlined,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _sendOtp(),
              ),
              
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Gửi mã xác thực',
                onPressed: _sendOtp,
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE6C6), // Light orange background
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Không nhận được email? Kiểm tra mục spam hoặc thử lại sau 60 giây.',
                  style: TextStyle(
                    color: Color(0xFFD66922), // Dark orange text
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Nhớ ra mật khẩu? ',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Quay lại',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
