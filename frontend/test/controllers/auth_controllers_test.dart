import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/controllers/login_controller.dart';
import 'package:learningapp/controllers/register_controller.dart';
import 'package:learningapp/controllers/forgot_password_controller.dart';
import 'package:learningapp/controllers/verify_otp_controller.dart';
import 'package:learningapp/controllers/reset_password_controller.dart';

/**
 * =========================================================================================
 * [GIẢI THÍCH DÀNH CHO NGƯỜI HỌC CÓ KIẾN THỨC JAVA / PYTHON]:
 *
 * 1. Unit Test trong Flutter (Dart):
 *    - Sử dụng hàm group() để nhóm các test case có liên quan (tương tự test class trong JUnit / TestCase trong Python unittest).
 *    - Sử dụng hàm test() để định nghĩa 1 ca kiểm thử đơn vị (tương tự @Test trong Java hoặc def test_xxx() trong Python).
 *    - Sử dụng hàm expect(actual, expected) để so sánh kết quả (tương tự assertEquals() trong JUnit hoặc assert actual == expected trong Python).
 *
 * 2. Mục đích file kiểm thử này:
 *    - Kiểm tra tính đúng đắn của TẦNG CONTROLLER (Kiểm tra dữ liệu đầu vào - Client Validation).
 *    - Đảm bảo dữ liệu sai không bao giờ bị gửi lên Backend gây lãng phí tài nguyên mạng.
 * =========================================================================================
 */

void main() {
  // =======================================================================================
  // NHÓM 1: KIỂM THỬ LOGIN CONTROLLER
  // =======================================================================================
  group('LoginController Tests', () {
    final controller = LoginController();

    test('TC01: Đăng nhập thất bại khi để trống email hoặc mật khẩu', () async {
      // 1. Act: Gọi hàm login với thông tin trống
      final result1 = await controller.login(email: '', password: 'password123');
      final result2 = await controller.login(email: 'test@example.com', password: '');

      // 2. Assert: Kiểm tra thông báo lỗi trả về đúng như mong đợi
      expect(result1, 'Vui lòng nhập đầy đủ thông tin');
      expect(result2, 'Vui lòng nhập đầy đủ thông tin');
    });
  });

  // =======================================================================================
  // NHÓM 2: KIỂM THỬ REGISTER CONTROLLER
  // =======================================================================================
  group('RegisterController Tests', () {
    final controller = RegisterController();

    test('TC02: Đăng ký thất bại khi thiếu thông tin bắt buộc', () async {
      final result = await controller.register(
        firstName: '',
        lastName: 'Nguyen',
        email: 'test@example.com',
        password: 'Password@123',
        confirmPassword: 'Password@123',
      );
      expect(result, 'Vui lòng nhập đầy đủ thông tin');
    });

    test('TC03A: Đăng ký thất bại khi email thiếu tên trước @ (ví dụ: @gmailcom, @mail.com)', () async {
      // 1. Thử với @gmailcom
      final result1 = await controller.register(
        firstName: 'Van A',
        lastName: 'Nguyen',
        email: '@gmailcom',
        password: 'Password@123',
        confirmPassword: 'Password@123',
      );
      expect(result1, 'Email không đúng định dạng');

      // 2. Thử với @mail.com
      final result2 = await controller.register(
        firstName: 'Van A',
        lastName: 'Nguyen',
        email: '@mail.com',
        password: 'Password@123',
        confirmPassword: 'Password@123',
      );
      expect(result2, 'Email không đúng định dạng');
    });

    test('TC03B: Đăng ký thất bại khi email thiếu tên miền hoặc đuôi mở rộng (user@gmailcom, user@, plain_text)', () async {
      // 1. Thử với user@gmailcom (thiếu dấu chấm tên miền .com)
      final result1 = await controller.register(
        firstName: 'Van A',
        lastName: 'Nguyen',
        email: 'user@gmailcom',
        password: 'Password@123',
        confirmPassword: 'Password@123',
      );
      expect(result1, 'Email không đúng định dạng');

      // 2. Thử với user@ (thiếu toàn bộ phần domain)
      final result2 = await controller.register(
        firstName: 'Van A',
        lastName: 'Nguyen',
        email: 'user@',
        password: 'Password@123',
        confirmPassword: 'Password@123',
      );
      expect(result2, 'Email không đúng định dạng');

      // 3. Thử với chuỗi không có @ (nhập bất kỳ chuỗi chữ)
      final result3 = await controller.register(
        firstName: 'Van A',
        lastName: 'Nguyen',
        email: 'nguyenvanagmail.com',
        password: 'Password@123',
        confirmPassword: 'Password@123',
      );
      expect(result3, 'Email không đúng định dạng');
    });

    test('TC03C: Đăng ký thất bại khi mật khẩu ngắn hơn 8 ký tự (với email hợp lệ: ten@gmail.com)', () async {
      final result = await controller.register(
        firstName: 'Van A',
        lastName: 'Nguyen',
        email: 'ten@gmail.com',
        password: 'short',
        confirmPassword: 'short',
      );
      expect(result, 'Mật khẩu phải dài ít nhất 8 ký tự');
    });

    test('TC04: Đăng ký thất bại khi mật khẩu xác nhận không khớp', () async {
      final result = await controller.register(
        firstName: 'Van A',
        lastName: 'Nguyen',
        email: 'ten@gmail.com',
        password: 'Password@123',
        confirmPassword: 'DifferentPassword@123',
      );
      expect(result, 'Mật khẩu xác nhận không khớp');
    });
  });

  // =======================================================================================
  // NHÓM 3: KIỂM THỬ FORGOT PASSWORD CONTROLLER
  // =======================================================================================
  group('ForgotPasswordController Tests', () {
    final controller = ForgotPasswordController();

    test('TC05: Yêu cầu OTP thất bại khi email trống', () async {
      final result = await controller.sendOtp('');
      expect(result, 'Vui lòng nhập email');
    });
  });

  // =======================================================================================
  // NHÓM 4: KIỂM THỬ VERIFY OTP CONTROLLER
  // =======================================================================================
  group('VerifyOtpController Tests', () {
    final controller = VerifyOtpController();

    test('TC06: Xác thực OTP thất bại khi mã OTP ít hơn 6 chữ số', () async {
      final result = await controller.verifyOtp('test@example.com', '12345');
      expect(result, 'Vui lòng nhập đủ 6 chữ số');
    });

    test('TC07: Gửi lại mã thất bại khi email trống', () async {
      final result = await controller.resendOtp('');
      expect(result, 'Vui lòng cung cấp email');
    });
  });

  // =======================================================================================
  // NHÓM 5: KIỂM THỬ RESET PASSWORD CONTROLLER
  // =======================================================================================
  group('ResetPasswordController Tests', () {
    final controller = ResetPasswordController();

    test('TC08: Đổi mật khẩu thất bại khi thông tin trống', () async {
      final result = await controller.resetPassword('test@example.com', '', '');
      expect(result, 'Vui lòng nhập đầy đủ thông tin');
    });

    test('TC09: Đổi mật khẩu thất bại khi mật khẩu mới dưới 8 ký tự', () async {
      final result = await controller.resetPassword('test@example.com', '1234', '1234');
      expect(result, 'Mật khẩu phải dài ít nhất 8 ký tự');
    });

    test('TC10: Đổi mật khẩu thất bại khi hai mật khẩu không trùng khớp', () async {
      final result = await controller.resetPassword('test@example.com', 'Password@123', 'Password@456');
      expect(result, 'Mật khẩu không khớp');
    });
  });
}
