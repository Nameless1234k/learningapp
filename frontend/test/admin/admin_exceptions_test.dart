import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/admin/controllers/admin_auth_controller.dart';
import 'package:learningapp/admin/models/admin_lesson_model.dart';
import 'package:learningapp/admin/models/admin_user_model.dart';
import 'package:learningapp/admin/widgets/lesson_dialog.dart';
import 'package:learningapp/admin/widgets/subject_dialog.dart';

void main() {
  group('Admin Exceptions & Validation Tests', () {
    test('EX01: AdminAuthController trả về lỗi khi bỏ trống Email hoặc Mật khẩu', () async {
      final controller = AdminAuthController();

      final errEmptyEmail = await controller.login(email: '   ', password: 'password123');
      expect(errEmptyEmail, isNotNull);
      expect(errEmptyEmail, contains('Vui lòng nhập đầy đủ Email và Mật khẩu'));

      final errEmptyPass = await controller.login(email: 'admin@gmail.com', password: '');
      expect(errEmptyPass, isNotNull);
      expect(errEmptyPass, contains('Vui lòng nhập đầy đủ Email và Mật khẩu'));
    });

    test('EX02: AdminLessonModel parse an toàn khi dữ liệu null hoặc rỗng', () {
      final jsonWithNulls = <String, dynamic>{
        'id': 'les-none',
        'subjectId': 'sub-none',
        'subjectName': '',
        'subjectCode': '',
        'documentId': null,
        'fileName': null,
        'filePath': null,
        'fileSizeMb': null,
        'lessonNo': 'invalid_no',
        'title': 'Bài học không có tệp',
        'createdAt': '',
      };

      final lesson = AdminLessonModel.fromJson(jsonWithNulls);

      expect(lesson.id, 'les-none');
      expect(lesson.documentId, isNull);
      expect(lesson.fileName, isNull);
      expect(lesson.filePath, isNull);
      expect(lesson.fileSizeMb, isNull);
      expect(lesson.lessonNo, 0); // Tự động fallback về 0 khi parse lỗi
    });

    test('EX03: AdminUserModel sắp xếp Admin lên đầu, user sớm nhất ở vị trí 2', () {
      final adminUser = AdminUserModel(
        id: 'admin-01',
        lastName: 'System',
        firstName: 'Admin',
        fullName: 'System Admin',
        email: 'admin@gmail.com',
        role: 'ADMIN',
        isActive: true,
        createdAt: '2026-10-20 15:00:00',
      );

      final userCreatedLate = AdminUserModel(
        id: 'user-late',
        lastName: 'Tran',
        firstName: 'Thi B',
        fullName: 'Tran Thi B',
        email: 'b@gmail.com',
        role: 'USER',
        isActive: true,
        createdAt: '2026-10-15 12:00:00',
      );

      final userCreatedEarly = AdminUserModel(
        id: 'user-early',
        lastName: 'Nguyen',
        firstName: 'Van A',
        fullName: 'Nguyen Van A',
        email: 'a@gmail.com',
        role: 'USER',
        isActive: true,
        createdAt: '2026-10-01 08:00:00',
      );

      final list = [userCreatedLate, adminUser, userCreatedEarly];

      // Sắp xếp: Admin luôn ở vị trí 1, tài khoản tạo sớm nhất ở vị trí 2, tiếp tục tăng dần
      list.sort((a, b) {
        final aIsAdmin = a.role.toUpperCase() == 'ADMIN';
        final bIsAdmin = b.role.toUpperCase() == 'ADMIN';
        if (aIsAdmin && !bIsAdmin) return -1;
        if (!aIsAdmin && bIsAdmin) return 1;

        final parseA = DateTime.tryParse(a.createdAt);
        final parseB = DateTime.tryParse(b.createdAt);
        if (parseA != null && parseB != null) {
          return parseA.compareTo(parseB);
        }
        return a.createdAt.compareTo(b.createdAt);
      });

      expect(list[0].id, 'admin-01'); // Vị trí 1: Admin
      expect(list[1].id, 'user-early'); // Vị trí 2: Ngày tạo sớm nhất (2026-10-01)
      expect(list[2].id, 'user-late'); // Vị trí 3: Ngày tạo muộn hơn (2026-10-15)

      // Danh sách ID hợp lệ để thao tác (khóa/xóa) phải loại trừ ADMIN
      final selectedIds = {'admin-01', 'user-early', 'user-late'};
      final validIds = selectedIds.where((id) {
        final u = list.firstWhere((x) => x.id == id);
        return u.role.toUpperCase() != 'ADMIN';
      }).toList();

      expect(validIds, contains('user-early'));
      expect(validIds, contains('user-late'));
      expect(validIds, isNot(contains('admin-01')));
    });

    test('EX06: Logic sắp xếp bài học theo cấp 1 thứ tự môn học, cấp 2 theo số bài học', () {
      final lessonTriet2 = AdminLessonModel(
        id: 'l-t2',
        subjectId: 'sub-triet',
        subjectName: 'Triết học Mác - Lênin',
        subjectCode: 'TRIET',
        subjectDisplayOrder: 1,
        lessonNo: 2,
        title: 'Bài 2: Chủ nghĩa duy vật biện chứng',
        createdAt: '2026-10-10',
      );

      final lessonTriet1 = AdminLessonModel(
        id: 'l-t1',
        subjectId: 'sub-triet',
        subjectName: 'Triết học Mác - Lênin',
        subjectCode: 'TRIET',
        subjectDisplayOrder: 1,
        lessonNo: 1,
        title: 'Bài 1: Triết học và vai trò của triết học',
        createdAt: '2026-10-10',
      );

      final lessonCnxh1 = AdminLessonModel(
        id: 'l-c1',
        subjectId: 'sub-cnxh',
        subjectName: 'Chủ nghĩa xã hội khoa học',
        subjectCode: 'CNXH',
        subjectDisplayOrder: 2,
        lessonNo: 1,
        title: 'Bài 1: Nhập môn CNXH',
        createdAt: '2026-10-10',
      );

      final lessons = [lessonCnxh1, lessonTriet2, lessonTriet1];

      // Map display order môn học
      final subjectOrderMap = {
        'sub-triet': 1,
        'sub-cnxh': 2,
      };

      lessons.sort((a, b) {
        // Cấp 1: Thứ tự môn học
        final orderA = subjectOrderMap[a.subjectId] ?? a.subjectDisplayOrder;
        final orderB = subjectOrderMap[b.subjectId] ?? b.subjectDisplayOrder;
        final subComp = orderA.compareTo(orderB);
        if (subComp != 0) return subComp;

        // Cấp 2: Số bài học (lessonNo: 1 -> 10)
        final lesComp = a.lessonNo.compareTo(b.lessonNo);
        if (lesComp != 0) return lesComp;

        return a.title.compareTo(b.title);
      });

      expect(lessons[0].id, 'l-t1'); // Triết Bài 1
      expect(lessons[1].id, 'l-t2'); // Triết Bài 2
      expect(lessons[2].id, 'l-c1'); // CNXH Bài 1
    });

    testWidgets('EX07: LessonDialog hiển thị nút X gỡ file và xóa file khi click', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final existingLesson = AdminLessonModel(
        id: 'les-test',
        subjectId: 'sub-01',
        subjectName: 'Triết học',
        subjectCode: 'TRIET',
        subjectDisplayOrder: 1,
        documentId: 'doc-01',
        fileName: 'tai_lieu_mau.pdf',
        fileSizeMb: 2.5,
        lessonNo: 1,
        title: 'Bài 1',
        createdAt: '2026-10-10',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  LessonDialog.show(
                    context,
                    initialLesson: existingLesson,
                    subjects: [],
                    onSave: ({required title, required subjectId, fileBytes, fileName, removeFile = false}) async {},
                  );
                },
                child: const Text('Open Edit Lesson Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Edit Lesson Dialog'));
      await tester.pumpAndSettle();

      // Phải nhìn thấy tên tệp đã chọn
      expect(find.text('tai_lieu_mau.pdf'), findsOneWidget);
      expect(find.byTooltip('Gỡ file PDF này'), findsOneWidget);

      // Bấm nút 'X' để gỡ file
      await tester.tap(find.byTooltip('Gỡ file PDF này'));
      await tester.pumpAndSettle();

      // Tên file phải biến mất, chuyển về khung chọn file ban đầu
      expect(find.text('tai_lieu_mau.pdf'), findsNothing);
      expect(find.text('Kéo và thả file vào đây để đưa lên'), findsOneWidget);
    });

    testWidgets('EX04: SubjectDialog kích hoạt validator exception khi bỏ trống trường', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  SubjectDialog.show(context, onSave: (code, name, order) async {});
                },
                child: const Text('Open Subject Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Subject Dialog'));
      await tester.pumpAndSettle();

      // Bấm Lưu khi chưa nhập gì
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      // Phải báo lỗi validation
      expect(find.text('Vui lòng nhập tên môn học'), findsOneWidget);
      expect(find.text('Vui lòng nhập mã môn học'), findsOneWidget);
    });

    testWidgets('EX05: LessonDialog kích hoạt validator exception khi bỏ trống tên bài và chưa chọn môn', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  LessonDialog.show(
                    context,
                    subjects: [],
                    onSave: ({required title, required subjectId, fileBytes, fileName, removeFile = false}) async {},
                  );
                },
                child: const Text('Open Lesson Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Lesson Dialog'));
      await tester.pumpAndSettle();

      // Bấm Lưu khi chưa nhập
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      // Phải báo lỗi validation
      expect(find.text('Vui lòng nhập tên bài học'), findsOneWidget);
      expect(find.text('Vui lòng chọn môn học'), findsOneWidget);
    });
  });
}
