import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/admin/models/admin_user_model.dart';
import 'package:learningapp/admin/models/admin_subject_model.dart';
import 'package:learningapp/admin/models/admin_lesson_model.dart';
import 'package:learningapp/admin/controllers/admin_auth_controller.dart';
import 'package:learningapp/admin/widgets/delete_confirm_dialog.dart';
import 'package:learningapp/admin/widgets/subject_dialog.dart';

void main() {
  group('Admin Models Tests', () {
    test('TC01 - Parse AdminUserModel từ JSON thành công', () {
      final json = {
        'id': 'u-123',
        'lastName': 'Nguyen',
        'firstName': 'An',
        'fullName': 'Nguyen An',
        'email': 'an@gmail.com',
        'phone': '0912345678',
        'role': 'ADMIN',
        'isActive': true,
        'createdAt': '2026-10-20 10:00:00',
      };

      final user = AdminUserModel.fromJson(json);

      expect(user.id, 'u-123');
      expect(user.fullName, 'Nguyen An');
      expect(user.email, 'an@gmail.com');
      expect(user.role, 'ADMIN');
      expect(user.isActive, true);
    });

    test('TC02 - Parse AdminSubjectModel từ JSON thành công', () {
      final json = {
        'id': 'sub-456',
        'code': 'TRIET_HOC',
        'name': 'Triết học Mác - Lênin',
        'displayOrder': 1,
        'createdAt': '2026-10-20 10:00:00',
      };

      final subject = AdminSubjectModel.fromJson(json);

      expect(subject.id, 'sub-456');
      expect(subject.code, 'TRIET_HOC');
      expect(subject.name, 'Triết học Mác - Lênin');
      expect(subject.displayOrder, 1);
    });

    test('TC03 - Parse AdminLessonModel từ JSON thành công', () {
      final json = {
        'id': 'les-789',
        'subjectId': 'sub-456',
        'subjectName': 'Triết học Mác - Lênin',
        'subjectCode': 'TRIET_HOC',
        'documentId': 'doc-001',
        'fileName': 'bai1.pdf',
        'filePath': '/api/documents/files/TRIET_HOC/bai1.pdf',
        'lessonNo': 1,
        'title': 'Bài 1: Khái lược Triết học',
        'createdAt': '2026-10-20 10:00:00',
      };

      final lesson = AdminLessonModel.fromJson(json);

      expect(lesson.id, 'les-789');
      expect(lesson.title, 'Bài 1: Khái lược Triết học');
      expect(lesson.subjectCode, 'TRIET_HOC');
      expect(lesson.fileName, 'bai1.pdf');
      expect(lesson.lessonNo, 1);
    });
  });

  group('Admin Auth Controller Tests', () {
    test('TC04 - Đăng nhập thất bại khi bỏ trống Email hoặc Mật khẩu', () async {
      final controller = AdminAuthController();

      final res1 = await controller.login(email: '', password: '123');
      expect(res1, contains('Vui lòng nhập đầy đủ'));

      final res2 = await controller.login(email: 'admin@gmail.com', password: '');
      expect(res2, contains('Vui lòng nhập đầy đủ'));
    });
  });

  group('Admin Dialogs Widget Tests', () {
    testWidgets('TC05 - DeleteConfirmDialog hiển thị đúng tiêu đề, nội dung và nút hủy/xác nhận', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await DeleteConfirmDialog.show(
                    context,
                    title: 'Xóa tài khoản',
                    message: 'Bạn có chắc chắn muốn xóa 1 tài khoản đã chọn?\nThao tác này không thể hoàn tác.',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Xóa tài khoản'), findsOneWidget);
      expect(find.text('Bạn có chắc chắn muốn xóa 1 tài khoản đã chọn?\nThao tác này không thể hoàn tác.'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Xác nhận xóa'), findsOneWidget);

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('TC06 - SubjectDialog kiểm tra tính hợp lệ của trường nhập', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  SubjectDialog.show(
                    context,
                    onSave: (code, name, order) async {},
                  );
                },
                child: const Text('Open Subject Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Subject Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Thêm môn học'), findsOneWidget);

      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập tên môn học'), findsOneWidget);
      expect(find.text('Vui lòng nhập mã môn học'), findsOneWidget);
    });
  });
}
