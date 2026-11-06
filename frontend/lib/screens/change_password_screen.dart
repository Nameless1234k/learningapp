import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';

// =========================================================================================
// [TÊN FILE: change_password_screen.dart]
// [VỊ TRÍ]: lib/screens/change_password_screen.dart
// [MỤC ĐÍCH]: Màn hình Đổi mật khẩu 
// - Ô nhập: Mật khẩu cũ, Mật khẩu mới, Xác nhận mật khẩu mới
// - Nút bấm: "Xác nhận" và "Hủy"
// - Hỗ trợ cả Light Mode và Dark Mode
// =========================================================================================

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _profileController = ProfileController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    // Chuyển toàn bộ kiểm tra dữ liệu và gọi API cho ProfileController (chuẩn MVC)
    final error = await _profileController.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      _showSnackBar(error, isError: true);
    } else {
      _showSnackBar('Đổi mật khẩu thành công!', isError: false);
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF15193B);
    final inputBorderColor = isDark ? const Color(0xFF475569) : const Color(0xFFE8D7C8);
    final inputBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF15193B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Tiêu đề lớn "Đổi mật khẩu"
              Center(
                child: Text(
                  'Đổi mật khẩu',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // 1. Ô Mật khẩu cũ
              _buildPasswordField(
                label: 'Mật khẩu cũ',
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                onToggleObscure: () => setState(() => _obscureOld = !_obscureOld),
                isDark: isDark,
                borderColor: inputBorderColor,
                bgColor: inputBgColor,
              ),
              const SizedBox(height: 24),

              // 2. Ô Mật khẩu mới
              _buildPasswordField(
                label: 'Mật khẩu mới',
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                isDark: isDark,
                borderColor: inputBorderColor,
                bgColor: inputBgColor,
              ),
              const SizedBox(height: 24),

              // 3. Ô Xác nhận mật khẩu mới
              _buildPasswordField(
                label: 'Xác nhận mật\nkhẩu mới',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                isDark: isDark,
                borderColor: inputBorderColor,
                bgColor: inputBgColor,
              ),

              const SizedBox(height: 80),

              // Nút "Xác nhận"
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Xác nhận',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Nút "Hủy"
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFE8D7C8),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF15193B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    required bool isDark,
    required Color borderColor,
    required Color bgColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label bên trái
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Input bo tròn bên phải
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF15193B),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9E9E9E),
                  ),
                  onPressed: onToggleObscure,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
