import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/admin/controllers/admin_document_controller.dart';
import 'package:learningapp/admin/controllers/admin_user_controller.dart';
import 'package:learningapp/admin/models/admin_lesson_model.dart';
import 'package:learningapp/admin/models/admin_subject_model.dart';
import 'package:learningapp/admin/models/admin_user_model.dart';

void main() {
  group('AdminUserController Unit Tests (MVC)', () {
    late AdminUserController userController;

    setUp(() {
      userController = AdminUserController();
    });

    test('TC-CTRL-01: Khởi tạo ban đầu với các giá trị mặc định chuẩn', () {
      expect(userController.allUsers, isEmpty);
      expect(userController.selectedIds, isEmpty);
      expect(userController.selectedRoleFilter, 'Tất cả');
      expect(userController.isLoading, isFalse);
      expect(userController.errorMessage, isNull);
    });

    test('TC-CTRL-02: filteredUsers tự động sắp xếp Admin lên đầu và User theo ngày tạo tăng dần', () {
      final admin = AdminUserModel(
        id: 'admin_1',
        lastName: 'Admin',
        firstName: 'Master',
        fullName: 'Admin Master',
        email: 'admin@school.com',
        role: 'ADMIN',
        isActive: true,
        createdAt: '2026-10-20 10:00:00',
      );
      final userLate = AdminUserModel(
        id: 'user_late',
        lastName: 'Tran',
        firstName: 'Van B',
        fullName: 'Tran Van B',
        email: 'b@gmail.com',
        role: 'USER',
        isActive: true,
        createdAt: '2026-10-15 10:00:00',
      );
      final userEarly = AdminUserModel(
        id: 'user_early',
        lastName: 'Nguyen',
        firstName: 'Van A',
        fullName: 'Nguyen Van A',
        email: 'a@gmail.com',
        role: 'USER',
        isActive: true,
        createdAt: '2026-10-01 10:00:00',
      );

      // Thêm danh sách vào controller
      userController.allUsers.addAll([userLate, admin, userEarly]);

      final sorted = userController.filteredUsers;
      expect(sorted.length, 3);
      expect(sorted[0].id, 'admin_1'); // Vị trí 1: ADMIN
      expect(sorted[1].id, 'user_early'); // Vị trí 2: Ngày tạo sớm nhất (2026-10-01)
      expect(sorted[2].id, 'user_late'); // Vị trí 3: Ngày tạo muộn hơn (2026-10-15)
    });

    test('TC-CTRL-03: Lọc người dùng theo Role chính xác', () {
      final admin = AdminUserModel(
        id: 'ad_1',
        lastName: 'A',
        firstName: 'Admin',
        fullName: 'Admin',
        email: 'ad@a.com',
        role: 'ADMIN',
        isActive: true,
        createdAt: '2026-10-10',
      );
      final user = AdminUserModel(
        id: 'us_1',
        lastName: 'U',
        firstName: 'User',
        fullName: 'User',
        email: 'us@a.com',
        role: 'USER',
        isActive: true,
        createdAt: '2026-10-11',
      );

      userController.allUsers.addAll([admin, user]);

      userController.setRoleFilter('User');
      expect(userController.filteredUsers.length, 1);
      expect(userController.filteredUsers.first.role, 'USER');

      userController.setRoleFilter('Admin');
      expect(userController.filteredUsers.length, 1);
      expect(userController.filteredUsers.first.role, 'ADMIN');

      userController.setRoleFilter('Tất cả');
      expect(userController.filteredUsers.length, 2);
    });

    test('TC-CTRL-04: validSelectedNonAdminIds bảo vệ không cho phép chọn Admin để khóa/xóa', () {
      final admin = AdminUserModel(
        id: 'admin_safe',
        lastName: 'Root',
        firstName: 'Admin',
        fullName: 'Root Admin',
        email: 'root@admin.com',
        role: 'ADMIN',
        isActive: true,
        createdAt: '2026-10-01',
      );
      final user1 = AdminUserModel(
        id: 'user_1',
        lastName: 'Hoc',
        firstName: 'Vien',
        fullName: 'Hoc Vien',
        email: 'hv@edu.com',
        role: 'USER',
        isActive: true,
        createdAt: '2026-10-02',
      );

      userController.allUsers.addAll([admin, user1]);

      // Chọn cả Admin và User1
      userController.toggleSelect('admin_safe');
      userController.toggleSelect('user_1');

      // Danh sách hợp lệ chỉ được chứa user_1
      final validIds = userController.validSelectedNonAdminIds;
      expect(validIds, contains('user_1'));
      expect(validIds, isNot(contains('admin_safe')));
    });

    test('TC-CTRL-05: lockSelectedUsers ném ngoại lệ khi cố tình khóa tài khoản Quản trị viên', () async {
      final admin = AdminUserModel(
        id: 'admin_only',
        lastName: 'Root',
        firstName: 'Admin',
        fullName: 'Root Admin',
        email: 'root@admin.com',
        role: 'ADMIN',
        isActive: true,
        createdAt: '2026-10-01',
      );
      userController.allUsers.add(admin);
      userController.toggleSelect('admin_only');

      expect(
        () => userController.lockSelectedUsers(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AdminDocumentController Unit Tests (MVC)', () {
    late AdminDocumentController docController;

    setUp(() {
      docController = AdminDocumentController();
    });

    test('TC-CTRL-06: Khởi tạo mặc định ở Tab Bài học (0)', () {
      expect(docController.selectedSubTab, 0);
      expect(docController.isLessonTab, isTrue);
      expect(docController.lessons, isEmpty);
      expect(docController.subjects, isEmpty);
      expect(docController.selectedItemIds, isEmpty);
    });

    test('TC-CTRL-07: sortSubjects sắp xếp chuẩn xác theo displayOrder', () {
      final sub2 = AdminSubjectModel(id: 's2', code: 'C2', name: 'Môn 2', displayOrder: 2, createdAt: '');
      final sub1 = AdminSubjectModel(id: 's1', code: 'C1', name: 'Môn 1', displayOrder: 1, createdAt: '');
      final sub3 = AdminSubjectModel(id: 's3', code: 'C3', name: 'Môn 3', displayOrder: 3, createdAt: '');

      final list = [sub2, sub3, sub1];
      docController.sortSubjects(list);

      expect(list[0].displayOrder, 1);
      expect(list[1].displayOrder, 2);
      expect(list[2].displayOrder, 3);
    });

    test('TC-CTRL-08: sortLessons sắp xếp 2 cấp: Cấp 1 theo thứ tự môn, Cấp 2 theo số bài', () {
      final subs = [
        AdminSubjectModel(id: 'sub_triet', code: 'TRIET', name: 'Triết', displayOrder: 1, createdAt: ''),
        AdminSubjectModel(id: 'sub_cnxh', code: 'CNXH', name: 'CNXH', displayOrder: 2, createdAt: ''),
      ];

      final lessonCnxh1 = AdminLessonModel(
        id: 'l_c1',
        subjectId: 'sub_cnxh',
        subjectName: 'CNXH',
        subjectCode: 'CNXH',
        subjectDisplayOrder: 2,
        lessonNo: 1,
        title: 'Bài 1 CNXH',
        createdAt: '',
      );
      final lessonTriet2 = AdminLessonModel(
        id: 'l_t2',
        subjectId: 'sub_triet',
        subjectName: 'Triết',
        subjectCode: 'TRIET',
        subjectDisplayOrder: 1,
        lessonNo: 2,
        title: 'Bài 2 Triết',
        createdAt: '',
      );
      final lessonTriet1 = AdminLessonModel(
        id: 'l_t1',
        subjectId: 'sub_triet',
        subjectName: 'Triết',
        subjectCode: 'TRIET',
        subjectDisplayOrder: 1,
        lessonNo: 1,
        title: 'Bài 1 Triết',
        createdAt: '',
      );

      final lessons = [lessonCnxh1, lessonTriet2, lessonTriet1];
      docController.sortLessons(lessons, subs);

      expect(lessons[0].id, 'l_t1'); // Triết, Bài 1
      expect(lessons[1].id, 'l_t2'); // Triết, Bài 2
      expect(lessons[2].id, 'l_c1'); // CNXH, Bài 1
    });

    test('TC-CTRL-09: toggleItem và toggleSelectAll cập nhật chính xác danh sách được chọn', () {
      docController.toggleItem('item_1');
      expect(docController.selectedItemIds, contains('item_1'));

      docController.toggleItem('item_1');
      expect(docController.selectedItemIds, isNot(contains('item_1')));

      docController.lessons.addAll([
        AdminLessonModel(id: 'l1', subjectId: 's1', subjectName: '', subjectCode: '', lessonNo: 1, title: '', createdAt: ''),
        AdminLessonModel(id: 'l2', subjectId: 's1', subjectName: '', subjectCode: '', lessonNo: 2, title: '', createdAt: ''),
      ]);

      docController.toggleSelectAll(true);
      expect(docController.selectedItemIds.length, 2);

      docController.toggleSelectAll(false);
      expect(docController.selectedItemIds, isEmpty);
    });
  });
}
