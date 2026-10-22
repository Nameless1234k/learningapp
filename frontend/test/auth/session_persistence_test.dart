import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/services/user_session.dart';
import 'package:learningapp/widgets/auth_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    UserSession.currentUserId = null;
    UserSession.currentToken = null;
    UserSession.currentEmail = null;
    UserSession.currentFullName = null;
    UserSession.currentRole = null;
  });

  group('UserSession Persistence & Storage Tests', () {
    test('TC-AUTH-01: UserSession khởi tạo trống khi chưa đăng nhập', () async {
      await UserSession.init();

      expect(UserSession.isLoggedIn, isFalse);
      expect(UserSession.isAdmin, isFalse);
      expect(UserSession.isUser, isFalse);
      expect(UserSession.currentUserId, isNull);
      expect(UserSession.currentToken, isNull);
    });

    test('TC-AUTH-02: saveSession() lưu trữ dữ liệu vào cả RAM và SharedPreferences', () async {
      await UserSession.saveSession(
        userId: 'user_123',
        token: 'token_abc',
        email: 'test@example.com',
        fullName: 'Nguyen Van A',
        role: 'USER',
      );

      expect(UserSession.isLoggedIn, isTrue);
      expect(UserSession.isUser, isTrue);
      expect(UserSession.isAdmin, isFalse);
      expect(UserSession.currentUserId, 'user_123');
      expect(UserSession.currentToken, 'token_abc');
      expect(UserSession.currentEmail, 'test@example.com');
      expect(UserSession.currentFullName, 'Nguyen Van A');
      expect(UserSession.currentRole, 'USER');

      // Kiểm tra trong SharedPreferences thực tế
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_session_user_id'), 'user_123');
      expect(prefs.getString('user_session_token'), 'token_abc');
      expect(prefs.getString('user_session_email'), 'test@example.com');
      expect(prefs.getString('user_session_full_name'), 'Nguyen Van A');
      expect(prefs.getString('user_session_role'), 'USER');
    });

    test('TC-AUTH-03: Mô phỏng F5 / mở lại app: RAM bị xóa nhưng nạp lại đầy đủ từ SharedPreferences', () async {
      // 1. Lưu phiên đăng nhập
      await UserSession.saveSession(
        userId: 'admin_456',
        token: 'admin_token_jwt',
        email: 'admin@system.com',
        fullName: 'Super Admin',
        role: 'ADMIN',
      );

      // 2. Mô phỏng reload trang F5 (xóa sạch toàn bộ biến tĩnh trong RAM của Dart VM)
      UserSession.currentUserId = null;
      UserSession.currentToken = null;
      UserSession.currentEmail = null;
      UserSession.currentFullName = null;
      UserSession.currentRole = null;
      expect(UserSession.isLoggedIn, isFalse);

      // 3. Ứng dụng khởi động lại và gọi UserSession.init()
      await UserSession.init();

      // 4. Xác nhận dữ liệu được khôi phục nguyên vẹn
      expect(UserSession.isLoggedIn, isTrue);
      expect(UserSession.isAdmin, isTrue);
      expect(UserSession.isUser, isFalse);
      expect(UserSession.currentUserId, 'admin_456');
      expect(UserSession.currentToken, 'admin_token_jwt');
      expect(UserSession.currentEmail, 'admin@system.com');
      expect(UserSession.currentFullName, 'Super Admin');
      expect(UserSession.currentRole, 'ADMIN');
    });

    test('TC-AUTH-04: clear() xóa sạch phiên làm việc ở cả RAM và SharedPreferences khi Đăng xuất', () async {
      await UserSession.saveSession(
        userId: 'user_999',
        token: 'token_999',
        email: 'logout@example.com',
        fullName: 'User Logout',
        role: 'USER',
      );
      expect(UserSession.isLoggedIn, isTrue);

      // Thực hiện đăng xuất
      await UserSession.clear();

      // Kiểm tra RAM
      expect(UserSession.isLoggedIn, isFalse);
      expect(UserSession.currentUserId, isNull);
      expect(UserSession.currentToken, isNull);
      expect(UserSession.currentRole, isNull);

      // Kiểm tra SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_session_user_id'), isNull);
      expect(prefs.getString('user_session_token'), isNull);
      expect(prefs.getString('user_session_role'), isNull);
    });
  });

  group('AuthWrapper Route Guard & Reload Protection Widget Tests', () {
    const unauthKey = Key('unauthenticated_screen');
    const authKey = Key('authenticated_screen');

    const testUnauthWidget = Scaffold(
      key: unauthKey,
      body: Text('Login Screen'),
    );

    const testAuthWidget = Scaffold(
      key: authKey,
      body: Text('Main Screen Dashboard'),
    );

    testWidgets('TC-AUTH-05: Khi chưa đăng nhập, AuthWrapper điều hướng về màn hình Login', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthWrapper(
            authenticatedScreen: testAuthWidget,
            unauthenticatedScreen: testUnauthWidget,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(unauthKey), findsOneWidget);
      expect(find.byKey(authKey), findsNothing);
    });

    testWidgets('TC-AUTH-06: Khi đã đăng nhập (USER), AuthWrapper Mobile tự động mở Main Screen sau F5', (tester) async {
      // Giả lập phiên làm việc đã được lưu trong LocalStorage từ trước
      SharedPreferences.setMockInitialValues({
        'user_session_user_id': 'user_001',
        'user_session_token': 'jwt_user_001',
        'user_session_email': 'student@school.edu',
        'user_session_full_name': 'Hoc Vien A',
        'user_session_role': 'USER',
      });
      await UserSession.init();

      await tester.pumpWidget(
        const MaterialApp(
          home: AuthWrapper(
            authenticatedScreen: testAuthWidget,
            unauthenticatedScreen: testUnauthWidget,
            requiredRole: 'USER',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Xác nhận duy trì phiên đăng nhập không bị đăng xuất
      expect(find.byKey(authKey), findsOneWidget);
      expect(find.byKey(unauthKey), findsNothing);
    });

    testWidgets('TC-AUTH-07: Tài khoản USER truy cập Admin sẽ bị AuthWrapper Role Guard chặn', (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_session_user_id': 'user_002',
        'user_session_token': 'jwt_user_002',
        'user_session_role': 'USER',
      });
      await UserSession.init();

      await tester.pumpWidget(
        const MaterialApp(
          home: AuthWrapper(
            authenticatedScreen: testAuthWidget,
            unauthenticatedScreen: testUnauthWidget,
            requiredRole: 'ADMIN',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Bị chặn vì không phải ADMIN
      expect(find.byKey(unauthKey), findsOneWidget);
      expect(find.byKey(authKey), findsNothing);
    });

    testWidgets('TC-AUTH-08: Tài khoản ADMIN truy cập Web Admin được cấp quyền vào Dashboard sau F5', (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_session_user_id': 'admin_001',
        'user_session_token': 'jwt_admin_001',
        'user_session_role': 'ADMIN',
      });
      await UserSession.init();

      await tester.pumpWidget(
        const MaterialApp(
          home: AuthWrapper(
            authenticatedScreen: testAuthWidget,
            unauthenticatedScreen: testUnauthWidget,
            requiredRole: 'ADMIN',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(authKey), findsOneWidget);
      expect(find.byKey(unauthKey), findsNothing);
    });
  });
}
