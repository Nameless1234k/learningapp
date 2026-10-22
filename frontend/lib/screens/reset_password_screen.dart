import 'package:flutter/material.dart';
import '../controllers/reset_password_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/input_label.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ResetPasswordController _resetPasswordController = ResetPasswordController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);
    final errorMessage = await _resetPasswordController.resetPassword(
      widget.email,
      _passwordController.text.trim(),
      _confirmPasswordController.text.trim(),
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

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Đổi mật khẩu thành công"),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    ));
    Navigator.of(context).popUntil((route) => route.isFirst);
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
                'Bước 3/3',
                style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Đặt lại mật khẩu',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Mật khẩu mới sẽ áp dụng cho mọi thiết bị đang đăng nhập.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              const InputLabel(text: 'Mật khẩu mới'),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Tối thiểu 8 kí tự',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                textInputAction: TextInputAction.next,
              ),
              
              const InputLabel(text: 'Nhập lại mật khẩu'),
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Nhập lại mật khẩu',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _resetPassword(),
              ),
              
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Lưu mật khẩu',
                onPressed: _resetPassword,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
