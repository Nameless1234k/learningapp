import 'package:flutter/material.dart';
import '../controllers/register_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/input_label.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final RegisterController _registerController = RegisterController();
  bool _isLoading = false;

  // [MỤC ĐÍCH FILE]: Giao diện hoàn toàn, quản lý các TextController, trạng thái loading và hiển thị SnackBar.
  // Tuyệt đối không chứa logic gọi API ở đây.

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _register() async {
    // 1. Tự Screen quản lý UI trạng thái Loading
    setState(() { _isLoading = true; });

    // 2. Chuyển thông tin cho Controller (Logic) xử lý
    // Nếu số điện thoại rỗng, truyền null xuống dưới
    String phoneInput = _phoneController.text.trim();
    
    String? errorMessage = await _registerController.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: phoneInput.isEmpty ? null : phoneInput,
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    if (!mounted) return;

    // 3. Tắt trạng thái Loading
    setState(() { _isLoading = false; });

    // 4. View tự quyết định việc hiển thị
    if (errorMessage != null) {
      // Có lỗi -> Hiển thị SnackBar đỏ
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      // Thành công -> Hiển thị SnackBar xanh và chuyển trang
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Đăng ký thành công"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context); // Quay lại màn hình Đăng Nhập
    }
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
                'Đăng kí',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tạo tài khoản để bắt đầu học',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              
              const InputLabel(text: 'Họ và tên đệm'),
              CustomTextField(
                controller: _lastNameController,
                hintText: 'VD: Nguyễn Văn',
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),
              
              const InputLabel(text: 'Tên chính'),
              CustomTextField(
                controller: _firstNameController,
                hintText: 'VD: A',
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),
              
              const InputLabel(text: 'Email'),
              CustomTextField(
                controller: _emailController,
                hintText: 'VD: username@gmail.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                textInputAction: TextInputAction.next,
              ),
              
              const InputLabel(text: 'Số điện thoại'),
              CustomTextField(
                controller: _phoneController,
                hintText: 'VD: 0123456789',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                textInputAction: TextInputAction.next,
              ),
              
              const InputLabel(text: 'Nhập mật khẩu'),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Tối thiểu 8 kí tự',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                textInputAction: TextInputAction.next,
              ),
              
              const InputLabel(text: 'Xác nhận mật khẩu'),
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Tối thiểu 8 kí tự',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _register(),
              ),
              
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Đăng kí',
                onPressed: _register,
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Đã có tài khoản? ',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
