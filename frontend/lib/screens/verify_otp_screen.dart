import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/verify_otp_controller.dart';
import '../widgets/primary_button.dart';
import '../widgets/otp_code_input.dart';
import 'reset_password_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  const VerifyOtpScreen({super.key, required this.email});

  @override
  VerifyOtpScreenState createState() => VerifyOtpScreenState();
}

class VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  final VerifyOtpController _verifyOtpController = VerifyOtpController();
  bool _isLoading = false;
  int _secondsRemaining = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    // 1. Lấy chuỗi OTP được ghép từ các ô riêng lẻ
    final otp = _otpController.text.trim();

    // 2. Kiểm tra đủ 6 số trước khi gửi cho hệ thống
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Vui lòng nhập đủ 6 chữ số"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // 3. Gửi chuỗi OTP lên hệ thống để xác thực
    _runOtpAction(
      action: () => _verifyOtpController.verifyOtp(widget.email, otp),
      onSuccess: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(email: widget.email),
          ),
        );
      },
    );
  }

  Future<void> _resendOtp() async {
    await _runOtpAction(
      action: () => _verifyOtpController.resendOtp(widget.email),
      onSuccess: () {
        setState(() => _secondsRemaining = 60);
        _otpController.clear();
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã gửi lại mã xác thực!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Future<void> _runOtpAction({
    required Future<String?> Function() action,
    required VoidCallback onSuccess,
  }) async {
    setState(() => _isLoading = true);
    final errorMessage = await action();
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
    onSuccess();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        }
        if (_secondsRemaining == 0) {
          timer.cancel();
        }
      });
    });
  }

  String get _countdownText {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
                'Bước 2/3',
                style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Nhập mã xác thực',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Mã gồm 6 chữ số vừa được gửi tới email của bạn.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              OtpCodeInput(
                controller: _otpController,
                focusNode: _otpFocusNode,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _secondsRemaining == 0
                      ? 'Mã OTP đã hết hạn'
                      : 'Mã OTP hết hạn sau $_countdownText',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _secondsRemaining == 0
                        ? Colors.redAccent
                        : const Color(0xFF15193B),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'Xác thực',
                onPressed: _verifyOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _resendOtp,
                  child: const Text(
                    'Gửi lại mã',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
