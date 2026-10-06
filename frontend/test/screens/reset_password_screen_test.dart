import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/screens/reset_password_screen.dart';

void main() {
  testWidgets('tapping empty space dismisses password field focus', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ResetPasswordScreen(email: 'test@example.com')),
    );

    final passwordField = tester.widget<EditableText>(
      find.byType(EditableText).first,
    );

    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    expect(passwordField.focusNode.hasFocus, isTrue);

    await tester.tap(find.text('Bước 3/3'));
    await tester.pump();

    expect(passwordField.focusNode.hasFocus, isFalse);
  });
}
