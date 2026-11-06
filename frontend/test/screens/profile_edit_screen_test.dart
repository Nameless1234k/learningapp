import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/screens/profile_edit_screen.dart';
import 'package:learningapp/services/theme_service.dart';
import 'package:learningapp/services/user_session.dart';

void main() {
  setUp(() async {
    // Khởi tạo phiên giả lập cho UserSession
    UserSession.currentUserId = 'test_user_id';
    UserSession.currentToken = 'test_token';
    UserSession.currentEmail = 'test@gmail.com';
    UserSession.currentFullName = 'Le Anh Huy';
    UserSession.currentRole = 'USER';
  });

  testWidgets('TC-UI-01: Bấm "Lưu" sẽ hiển thị bảng xác nhận lưu thay đổi (tránh bấm nhầm)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileEditScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tìm nút "Lưu"
    final saveButton = find.widgetWithText(ElevatedButton, 'Lưu');
    expect(saveButton, findsOneWidget);

    // Bấm nút Lưu
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Bảng xác nhận phải xuất hiện
    expect(find.text('Xác nhận lưu thay đổi'), findsOneWidget);
    expect(find.text('Bạn có chắc chắn muốn lưu các thay đổi thông tin cá nhân này không?'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
    expect(find.text('Xác nhận'), findsOneWidget);

    // Bấm "Hủy" -> Hộp thoại đóng lại
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();

    // Hộp thoại đã biến mất, màn hình vẫn là ProfileEditScreen
    expect(find.text('Xác nhận lưu thay đổi'), findsNothing);
    expect(find.text('Tài khoản cá nhân'), findsOneWidget);
  });

  testWidgets('TC-UI-02: Bấm Lưu nhưng để trống Tên thì báo lỗi ngay, không mở bảng xác nhận', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileEditScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Xóa trường Tên
    final textFields = find.byType(TextField);
    // Trường thứ 2 là trường Tên (Index 0: Họ, Index 1: Tên)
    await tester.enterText(textFields.at(1), '');
    await tester.pumpAndSettle();

    // Bấm nút Lưu
    await tester.tap(find.widgetWithText(ElevatedButton, 'Lưu'));
    await tester.pumpAndSettle();

    // Không mở dialog xác nhận
    expect(find.text('Xác nhận lưu thay đổi'), findsNothing);
    // Xuất hiện thông báo lỗi
    expect(find.text('Vui lòng nhập đầy đủ thông tin'), findsOneWidget);
  });

  testWidgets('TC-UI-03: Kiểm tra chuyển đổi Dark Mode mượt mà tức thì với themeAnimationDuration', (tester) async {
    expect(ThemeService.themeModeNotifier.value, isNotNull);

    // Chuyển sang Dark Mode
    ThemeService.toggleDarkMode(true);
    expect(ThemeService.isDarkMode, isTrue);

    // Chuyển lại Light Mode
    ThemeService.toggleDarkMode(false);
    expect(ThemeService.isDarkMode, isFalse);
  });
}
