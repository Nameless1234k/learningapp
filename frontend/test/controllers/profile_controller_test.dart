import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/controllers/profile_controller.dart';

void main() {
  group('ProfileController Tests - Cập nhật dữ liệu người dùng (Update Profile)', () {
    final controller = ProfileController();

    test('TC01: Cập nhật thất bại khi để trống Tên (giống Đăng ký)', () async {
      final result = await controller.updateProfile(
        firstName: '',
        lastName: 'Nguyen',
        phone: '0912345678',
      );
      expect(result, 'Vui lòng nhập đầy đủ thông tin');
    });

    test('TC02: Cập nhật thất bại khi để trống Họ và tên đệm (giống Đăng ký)', () async {
      final result = await controller.updateProfile(
        firstName: 'Van A',
        lastName: '',
        phone: '0912345678',
      );
      expect(result, 'Vui lòng nhập đầy đủ thông tin');
    });

    test('TC03: Cập nhật thất bại khi số điện thoại không hợp lệ', () async {
      final result1 = await controller.updateProfile(
        firstName: 'Van A',
        lastName: 'Nguyen',
        phone: '1234', // Ít hơn 9 số
      );
      expect(result1, 'Số điện thoại không hợp lệ (9 - 11 chữ số)!');

      final result2 = await controller.updateProfile(
        firstName: 'Van A',
        lastName: 'Nguyen',
        phone: '0912345678999', // Nhiều hơn 11 số
      );
      expect(result2, 'Số điện thoại không hợp lệ (9 - 11 chữ số)!');

      final result3 = await controller.updateProfile(
        firstName: 'Van A',
        lastName: 'Nguyen',
        phone: 'abc1234567', // Chứa ký tự chữ
      );
      expect(result3, 'Số điện thoại không hợp lệ (9 - 11 chữ số)!');
    });
  });

  group('ProfileController Tests - Đổi mật khẩu (Change Password)', () {
    final controller = ProfileController();

    test('TC04: Đổi mật khẩu thất bại khi để trống bất kỳ trường nào', () async {
      final result1 = await controller.changePassword(
        oldPassword: '',
        newPassword: 'Password@123',
        confirmPassword: 'Password@123',
      );
      expect(result1, 'Vui lòng nhập đầy đủ thông tin');

      final result2 = await controller.changePassword(
        oldPassword: 'OldPassword@123',
        newPassword: '',
        confirmPassword: 'Password@123',
      );
      expect(result2, 'Vui lòng nhập đầy đủ thông tin');

      final result3 = await controller.changePassword(
        oldPassword: 'OldPassword@123',
        newPassword: 'Password@123',
        confirmPassword: '',
      );
      expect(result3, 'Vui lòng nhập đầy đủ thông tin');
    });

    test('TC05: Đổi mật khẩu thất bại khi mật khẩu mới ít hơn 8 ký tự (giống Đăng ký)', () async {
      final result = await controller.changePassword(
        oldPassword: 'OldPassword@123',
        newPassword: 'short',
        confirmPassword: 'short',
      );
      expect(result, 'Mật khẩu phải dài ít nhất 8 ký tự');
    });

    test('TC06: Đổi mật khẩu thất bại khi mật khẩu xác nhận không khớp (giống Đăng ký)', () async {
      final result = await controller.changePassword(
        oldPassword: 'OldPassword@123',
        newPassword: 'Password@123',
        confirmPassword: 'DifferentPassword@123',
      );
      expect(result, 'Mật khẩu xác nhận không khớp');
    });

    test('TC07: Đổi mật khẩu thất bại khi mật khẩu mới trùng mật khẩu cũ', () async {
      final result = await controller.changePassword(
        oldPassword: 'Password@123',
        newPassword: 'Password@123',
        confirmPassword: 'Password@123',
      );
      expect(result, 'Mật khẩu mới không được trùng với mật khẩu cũ!');
    });
  });
}
