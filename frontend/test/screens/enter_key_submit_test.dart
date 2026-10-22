import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/screens/login_screen.dart';
import 'package:learningapp/screens/register_screen.dart';
import 'package:learningapp/screens/forgot_password_screen.dart';
import 'package:learningapp/screens/reset_password_screen.dart';
import 'package:learningapp/widgets/custom_text_field.dart';

void main() {
  group('Enter Key (onSubmitted) UI Tests', () {
    testWidgets('CustomTextField forwards onSubmitted callback on enter/submit', (tester) async {
      String submittedValue = '';
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (val) {
                submittedValue = val;
              },
            ),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      await tester.enterText(textFieldFinder, 'my_input_value');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, 'my_input_value');
    });

    testWidgets('LoginScreen password field has TextInputAction.done and triggers submission', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final customTextFields = find.byType(CustomTextField);
      expect(customTextFields, findsNWidgets(2));

      // First field: Email (TextInputAction.next)
      final emailWidget = tester.widget<CustomTextField>(customTextFields.at(0));
      expect(emailWidget.textInputAction, TextInputAction.next);

      // Second field: Password (TextInputAction.done)
      final passwordWidget = tester.widget<CustomTextField>(customTextFields.at(1));
      expect(passwordWidget.textInputAction, TextInputAction.done);
      expect(passwordWidget.onSubmitted, isNotNull);
    });

    testWidgets('RegisterScreen confirm password field has TextInputAction.done and triggers registration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      final customTextFields = find.byType(CustomTextField);
      expect(customTextFields, findsNWidgets(6));

      // Last field (Confirm Password) has TextInputAction.done and onSubmitted
      final confirmPasswordWidget = tester.widget<CustomTextField>(customTextFields.last);
      expect(confirmPasswordWidget.textInputAction, TextInputAction.done);
      expect(confirmPasswordWidget.onSubmitted, isNotNull);
    });

    testWidgets('ForgotPasswordScreen email field has TextInputAction.done and triggers send OTP', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      );

      final customTextField = find.byType(CustomTextField);
      expect(customTextField, findsOneWidget);

      final emailWidget = tester.widget<CustomTextField>(customTextField);
      expect(emailWidget.textInputAction, TextInputAction.done);
      expect(emailWidget.onSubmitted, isNotNull);
    });

    testWidgets('ResetPasswordScreen confirm password field has TextInputAction.done and triggers reset', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordScreen(email: 'test@gmail.com'),
        ),
      );

      final customTextFields = find.byType(CustomTextField);
      expect(customTextFields, findsNWidgets(2));

      final confirmPasswordWidget = tester.widget<CustomTextField>(customTextFields.last);
      expect(confirmPasswordWidget.textInputAction, TextInputAction.done);
      expect(confirmPasswordWidget.onSubmitted, isNotNull);
    });
  });
}
