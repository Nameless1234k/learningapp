import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import '../services/user_session.dart';
import '../utils/app_validator.dart';
import 'change_password_screen.dart';

// =========================================================================================
// [TÊN FILE: profile_edit_screen.dart]
// [VỊ TRÍ]: lib/screens/profile_edit_screen.dart
// [MỤC ĐÍCH]: Màn hình "Tài khoản cá nhân" thiết kế chuẩn theo screen_24.png:
// - Header: Nút back tròn, tiêu đề "Tài khoản cá nhân", phụ đề "Thiết lập/chỉnh sửa thông tin cá nhân"
// - Form thông tin: Họ, Tên, Email, SĐT
// - 2 nút chức năng: "Lưu" (Primary button) và "Đổi mật khẩu" (Outline button)
// - Hỗ trợ cả Light Mode và Dark Mode
// =========================================================================================

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _profileController = ProfileController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasSavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    // 1. Nạp trước từ cache cục bộ UserSession để giao diện không bị giật
    _emailController.text = UserSession.currentEmail ?? '';
    final fullName = UserSession.currentFullName ?? '';
    if (fullName.isNotEmpty) {
      final parts = fullName.trim().split(' ');
      if (parts.length > 1) {
        _firstNameController.text = parts.last;
        _lastNameController.text = parts.sublist(0, parts.length - 1).join(' ');
      } else {
        _firstNameController.text = fullName;
      }
    }

    // 2. Fetch thông tin mới nhất từ Backend API qua Controller
    try {
      final profile = await _profileController.getProfile();
      if (mounted) {
        setState(() {
          _firstNameController.text = profile.firstName;
          _lastNameController.text = profile.lastName;
          _emailController.text = profile.email;
          _phoneController.text = profile.phone ?? '';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Bảng xác nhận lưu thay đổi thông tin cá nhân (tránh người dùng bấm nhầm)
  Future<bool?> _showConfirmSaveDialog(bool isDark) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Xác nhận lưu thay đổi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF15193B),
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn lưu các thay đổi thông tin cá nhân này không?',
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF15193B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSave() async {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    // 1. Kiểm tra tính hợp lệ sơ bộ trước khi hiển thị bảng xác nhận
    final validationError = AppValidator.validateNames(first, last) ?? AppValidator.validatePhone(phone);
    if (validationError != null) {
      _showSnackBar(validationError, isError: true);
      return;
    }

    // 2. Hiển thị bảng xác nhận lưu để người dùng chắc chắn, không bị bấm nhầm
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await _showConfirmSaveDialog(isDark);
    if (confirmed != true) return;

    // 3. Tiến hành gọi Controller để lưu lên Backend
    setState(() => _isSaving = true);

    final error = await _profileController.updateProfile(
      firstName: first,
      lastName: last,
      phone: phone,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      _showSnackBar(error, isError: true);
    } else {
      _hasSavedChanges = true;
      _showSnackBar('Cập nhật thông tin thành công!', isError: false);
      // Vẫn ở nguyên trong trang thông tin cá nhân theo yêu cầu (không tự động thoát ra ngoài)!
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasSavedChanges);
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF15193B)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ==========================================
                      // 1. HEADER (Back button tròn + Title + Subtitle)
                      // ==========================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nút Back tròn chuẩn Adobe XD
                          InkWell(
                            onTap: () => Navigator.pop(context, _hasSavedChanges),
                            borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: isDark ? Colors.white : const Color(0xFF15193B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title + Subtitle bánh răng
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tài khoản cá nhân',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.settings_outlined,
                                    size: 15,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Thiết lập/chỉnh sửa thông tin cá nhân',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // ==========================================
                    // 2. KHỐI THÔNG TIN CÁ NHÂN
                    // ==========================================
                    Text(
                      'Thông tin cá nhân',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF8C90A4),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Họ và tên đệm
                    _buildInputField(
                      label: 'Họ',
                      controller: _lastNameController,
                      isDark: isDark,
                      borderColor: inputBorderColor,
                      bgColor: inputBgColor,
                    ),
                    const SizedBox(height: 18),

                    // Tên chính
                    _buildInputField(
                      label: 'Tên',
                      controller: _firstNameController,
                      isDark: isDark,
                      borderColor: inputBorderColor,
                      bgColor: inputBgColor,
                    ),
                    const SizedBox(height: 18),

                    // Email (chỉ đọc)
                    _buildInputField(
                      label: 'Email',
                      controller: _emailController,
                      isDark: isDark,
                      readOnly: true,
                      borderColor: inputBorderColor,
                      bgColor: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF9FAFB),
                    ),
                    const SizedBox(height: 18),

                    // Số điện thoại
                    _buildInputField(
                      label: 'SĐT',
                      controller: _phoneController,
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                      borderColor: inputBorderColor,
                      bgColor: inputBgColor,
                    ),

                    const SizedBox(height: 80),

                    // ==========================================
                    // 3. NÚT LƯU & ĐỔI MẬT KHẨU
                    // ==========================================
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Lưu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                          );
                        },
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
                          'Đổi mật khẩu',
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
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required Color borderColor,
    required Color bgColor,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(width: 16),
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
              readOnly: readOnly,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 15,
                color: readOnly
                    ? (isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF))
                    : (isDark ? Colors.white : const Color(0xFF15193B)),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
