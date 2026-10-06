import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/screens/verify_otp_screen.dart';
import 'package:learningapp/widgets/otp_code_input.dart';

void main() {
  testWidgets('OTP screen displays six individual digit input fields with identical layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: VerifyOtpScreen(email: 'test@example.com')),
    );

    // Kiểm tra có đúng 6 ô TextField riêng lẻ
    expect(find.byType(TextField), findsNWidgets(6));
    expect(find.text('Bước 2/3'), findsOneWidget);
    expect(find.text('Nhập mã xác thực'), findsOneWidget);
    expect(find.text('Gửi lại mã'), findsOneWidget);
  });

  testWidgets('Entering digits in individual boxes joins them and advances focus', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpCodeInput(controller: controller, focusNode: focusNode),
        ),
      ),
    );

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(6));

    // Nhập lần lượt 6 số vào 6 ô
    for (int i = 0; i < 6; i++) {
      await tester.enterText(textFields.at(i), '${i + 1}');
      await tester.pump();
    }

    // Kết quả nối chuỗi phải là '123456'
    expect(controller.text, '123456');
    for (int i = 1; i <= 6; i++) {
      expect(find.text('$i'), findsOneWidget);
    }
  });

  testWidgets('Can edit and overwrite any box individually and update combined string', (
    tester,
  ) async {
    final controller = TextEditingController(text: '123456');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpCodeInput(controller: controller, focusNode: focusNode),
        ),
      ),
    );

    expect(find.text('4'), findsOneWidget);

    final textFields = find.byType(TextField);
    // Nhấp vào ô thứ 4 (index 3) để ghi đè số thành '9'
    await tester.tap(textFields.at(3));
    await tester.pump();

    await tester.enterText(textFields.at(3), '9');
    await tester.pump();

    // Chuỗi ghép lại đã đổi từ '123456' thành '123956'
    expect(controller.text, '123956');
    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('Can delete digit in any box using backspace and clear it', (
    tester,
  ) async {
    final controller = TextEditingController(text: '123456');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpCodeInput(controller: controller, focusNode: focusNode),
        ),
      ),
    );

    final textFields = find.byType(TextField);
    await tester.tap(textFields.at(2));
    await tester.pump();

    // Xóa số ở ô thứ 3 (index 2, số '3') bằng phím xóa (text rỗng)
    await tester.enterText(textFields.at(2), '');
    await tester.pump();

    expect(controller.text, '12456');
  });

  testWidgets('Pressing backspace key on empty box jumps to previous box and deletes it', (
    tester,
  ) async {
    final controller = TextEditingController(text: '12');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpCodeInput(controller: controller, focusNode: focusNode),
        ),
      ),
    );

    final textFields = find.byType(TextField);
    // Focus vào ô thứ 3 (index 2 - đang rỗng)
    await tester.tap(textFields.at(2));
    await tester.pump();

    // Bấm phím Backspace trên bàn phím
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    // Ô thứ 2 (index 1) đã bị xóa số '2', chuỗi còn lại '1'
    expect(controller.text, '1');
  });

  testWidgets('Entering a digit automatically requests focus on adjacent box', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpCodeInput(controller: controller, focusNode: focusNode),
        ),
      ),
    );

    final textFields = find.byType(TextField);
    await tester.tap(textFields.at(0));
    await tester.pump();

    await tester.enterText(textFields.at(0), '5');
    await tester.pump();

    // Ô tiếp theo (index 1) phải được focus tự động
    final focusNode1 = tester.widget<TextField>(textFields.at(1)).focusNode;
    expect(focusNode1?.hasFocus, isTrue);
  });

  testWidgets('OTP countdown expires after 60 seconds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: VerifyOtpScreen(email: 'test@example.com')),
    );

    expect(find.text('Mã OTP hết hạn sau 01:00'), findsOneWidget);
    await tester.pump(const Duration(seconds: 60));

    expect(find.text('Mã OTP đã hết hạn'), findsOneWidget);
  });
}
