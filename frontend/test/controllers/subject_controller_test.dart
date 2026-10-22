import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/models/subject_model.dart';
import 'package:learningapp/models/lesson_model.dart';
import 'package:learningapp/services/user_session.dart';
import 'package:learningapp/controllers/subject_controller.dart';
import 'package:learningapp/utils/url_helper.dart';

// =========================================================================================
// [TÊN FILE: subject_controller_test.dart]
// [VỊ TRÍ]: test/controllers/subject_controller_test.dart
// [MỤC ĐÍCH]: Kiểm thử đơn vị (Unit Test) cho các Model môn học và bài học.
// Đảm bảo dữ liệu JSON từ Backend được bóc tách chính xác thành các Object trong Flutter.
// =========================================================================================

void main() {
  group('SubjectModel Tests (Screen 9)', () {
    test('TC01 - Parse SubjectItem từ JSON thành công', () {
      final json = {
        'id': 'sub-1',
        'code': 'TRIET_HOC',
        'name': 'Triết học Mác - Lênin',
        'description': 'Môn học cơ bản',
        'progressPercent': 50.0,
        'nextLesson': 'Bài tiếp theo: Bài 3-Hai nguyên lí...',
        'totalLessons': 8,
        'completedLessons': 4,
      };

      final item = SubjectItem.fromJson(json);

      expect(item.id, 'sub-1');
      expect(item.code, 'TRIET_HOC');
      expect(item.name, 'Triết học Mác - Lênin');
      expect(item.progressPercent, 50.0);
      expect(item.nextLesson, 'Bài tiếp theo: Bài 3-Hai nguyên lí...');
      expect(item.totalLessons, 8);
      expect(item.completedLessons, 4);
    });

    test('TC02 - Parse SubjectListModel từ JSON danh sách môn học', () {
      final json = {
        'totalSubjects': 5,
        'readSubjects': 4,
        'subjects': [
          {
            'id': 'sub-1',
            'code': 'TRIET_HOC',
            'name': 'Triết học Mác - Lênin',
            'progressPercent': 50.0,
            'totalLessons': 8,
            'completedLessons': 4,
          },
          {
            'id': 'sub-2',
            'code': 'KTCT',
            'name': 'Kinh tế chính trị Mác - Lênin',
            'progressPercent': 0.0,
            'totalLessons': 6,
            'completedLessons': 0,
          }
        ]
      };

      final listModel = SubjectListModel.fromJson(json);

      expect(listModel.totalSubjects, 5);
      expect(listModel.readSubjects, 4);
      expect(listModel.subjects.length, 2);
      expect(listModel.subjects[0].name, 'Triết học Mác - Lênin');
      expect(listModel.subjects[1].name, 'Kinh tế chính trị Mác - Lênin');
    });
  });

  group('LessonModel Tests (Screen 14)', () {
    test('TC03 - Parse LessonItem từ JSON thành công', () {
      final json = {
        'id': 'les-1',
        'lessonNo': 1,
        'title': 'Khái lược về Triết học',
        'description': 'Nội dung bài 1',
        'estimatedMinutes': 18,
        'status': 'COMPLETED',
        'isRead': true,
      };

      final lesson = LessonItem.fromJson(json);

      expect(lesson.id, 'les-1');
      expect(lesson.lessonNo, 1);
      expect(lesson.title, 'Khái lược về Triết học');
      expect(lesson.estimatedMinutes, 18);
      expect(lesson.status, 'COMPLETED');
      expect(lesson.isRead, true);
    });

    test('TC04 - Parse SubjectDetailModel từ JSON chi tiết bài học', () {
      final json = {
        'subjectId': 'sub-1',
        'subjectName': 'Triết học Mác – Lênin',
        'totalLessons': 8,
        'progressPercent': 50.0,
        'lessons': [
          {
            'id': 'les-1',
            'lessonNo': 1,
            'title': 'Bài 1',
            'estimatedMinutes': 18,
            'status': 'COMPLETED',
            'isRead': true,
          },
          {
            'id': 'les-2',
            'lessonNo': 2,
            'title': 'Bài 2',
            'estimatedMinutes': 0,
            'status': 'NOT_STARTED',
            'isRead': false,
          }
        ]
      };

      final detail = SubjectDetailModel.fromJson(json);

      expect(detail.subjectId, 'sub-1');
      expect(detail.subjectName, 'Triết học Mác – Lênin');
      expect(detail.totalLessons, 8);
      expect(detail.progressPercent, 50.0);
      expect(detail.lessons.length, 2);
      expect(detail.lessons[0].isRead, true);
      expect(detail.lessons[1].isRead, false);
    });
  });

  group('UserSession Tests', () {
    test('TC05 - Lưu và xóa phiên người dùng hoạt động đúng', () {
      UserSession.clear();
      expect(UserSession.isLoggedIn, false);

      UserSession.saveSession(
        userId: 'user-uuid-123',
        token: 'jwt-token-xyz',
        email: 'test@gmail.com',
        fullName: 'Nguyen Van A',
      );

      expect(UserSession.isLoggedIn, true);
      expect(UserSession.currentUserId, 'user-uuid-123');
      expect(UserSession.currentToken, 'jwt-token-xyz');
      expect(UserSession.currentEmail, 'test@gmail.com');
      expect(UserSession.currentFullName, 'Nguyen Van A');

      UserSession.clear();
      expect(UserSession.isLoggedIn, false);
      expect(UserSession.currentUserId, null);
    });
  });

  group('UrlHelper & SubjectController URL Tests', () {
    test('TC06 - UrlHelper tạo serverOrigin chuẩn xác', () {
      expect(UrlHelper.serverOrigin, isNotEmpty);
      expect(UrlHelper.serverOrigin.endsWith('/api'), isFalse);
    });

    test('TC07 - UrlHelper chuẩn hóa đường dẫn PDF tuyệt đối chính xác', () {
      // 1. Link http sẵn
      expect(
        UrlHelper.getFullPdfUrl('http://example.com/test.pdf'),
        'http://example.com/test.pdf',
      );

      // 2. Link có sẵn tiền tố /api
      const apiPath = '/api/documents/doc-123/file';
      final resolvedUrl = UrlHelper.getFullPdfUrl(apiPath);
      expect(resolvedUrl, contains('/api/documents/doc-123/file'));
      expect(resolvedUrl.contains('/api/api/'), isFalse);

      // 3. Link tương đối không có /api
      const relativePath = 'documents/doc-456/file';
      final resolvedRelative = UrlHelper.getFullPdfUrl(relativePath);
      expect(resolvedRelative, contains('/api/documents/doc-456/file'));
    });

    test('TC08 - SubjectController hasPdfDocument & resolvePdfUrl hoạt động chuẩn MVC', () {
      final controller = SubjectController();

      // Kiểm tra hasPdfDocument
      expect(controller.hasPdfDocument(null), isFalse);
      expect(controller.hasPdfDocument(''), isFalse);
      expect(controller.hasPdfDocument('   '), isFalse);
      expect(controller.hasPdfDocument('/api/documents/1/file'), isTrue);

      // Kiểm tra resolvePdfUrl
      final resolved = controller.resolvePdfUrl('/api/documents/1/file');
      expect(resolved, contains('/api/documents/1/file'));
      expect(resolved.contains('/api/api/'), isFalse);
    });
  });
}
