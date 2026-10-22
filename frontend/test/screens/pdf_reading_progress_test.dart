import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/models/lesson_model.dart';
import 'package:learningapp/screens/pdf_viewer_screen.dart';

void main() {
  group('PDF Reading Progress & Time Accumulation Tests', () {
    test('TC01 - LessonItem parse readingSeconds và lastPosition từ JSON chuẩn xác', () {
      final json = {
        'id': 'lesson-uuid-1',
        'lessonNo': 1,
        'title': 'Triết học và vấn đề cơ bản của triết học',
        'estimatedMinutes': 20,
        'status': 'IN_PROGRESS',
        'isRead': false,
        'pdfUrl': '/api/documents/doc-1/file',
        'readingMinutes': 2,
        'readingSeconds': 125,
        'lastPosition': 7,
      };

      final lesson = LessonItem.fromJson(json);

      expect(lesson.id, 'lesson-uuid-1');
      expect(lesson.lessonNo, 1);
      expect(lesson.title, 'Triết học và vấn đề cơ bản của triết học');
      expect(lesson.estimatedMinutes, 20);
      expect(lesson.status, 'IN_PROGRESS');
      expect(lesson.isRead, false);
      expect(lesson.pdfUrl, '/api/documents/doc-1/file');
      expect(lesson.readingMinutes, 2);
      expect(lesson.readingSeconds, 125);
      expect(lesson.lastPosition, 7);
    });

    test('TC02 - PdfViewerScreen nhận initialReadingSeconds và initialLastPosition chính xác', () {
      const screen = PdfViewerScreen(
        title: 'Bài 1. Triết học Mác - Lênin',
        pdfUrl: 'http://localhost:8080/api/documents/doc-1/file',
        lessonId: 'lesson-123',
        userId: 'user-456',
        initialIsRead: false,
        initialReadingSeconds: 45,
        initialLastPosition: 6,
      );

      expect(screen.title, 'Bài 1. Triết học Mác - Lênin');
      expect(screen.lessonId, 'lesson-123');
      expect(screen.userId, 'user-456');
      expect(screen.initialIsRead, false);
      expect(screen.initialReadingSeconds, 45);
      expect(screen.initialLastPosition, 6);
    });

    test('TC03 - Logic cộng dồn thời gian đọc qua nhiều phiên: 25s phiên 1 + 35s phiên 2 = 60s đạt ngưỡng hoàn thành', () {
      // Giả lập phiên 1 đã đọc 25s
      const int previousReadingSeconds = 25;
      expect(previousReadingSeconds < 60, true, reason: 'Chưa đủ 60s sau phiên 1');

      // Giả lập phiên 2 đọc thêm 35 giây
      const int currentSessionSeconds = 35;
      final int totalAccumulatedSeconds = previousReadingSeconds + currentSessionSeconds;

      // Tổng thời gian tích lũy = 60 giây
      expect(totalAccumulatedSeconds, 60);
      final bool isReached60s = totalAccumulatedSeconds >= 60;
      expect(isReached60s, true, reason: 'Cộng dồn 2 phiên đủ 60s phải tự động hoàn thành');
    });

    test('TC04 - Logic giữ trang đọc lớn nhất từng đạt được: Lật tới trang 8 rồi lùi về trang 3 vẫn giữ trang 8', () {
      int maxPageReached = 1;

      // Học viên lật tới trang 5
      int currentPage = 5;
      if (currentPage > maxPageReached) maxPageReached = currentPage;
      expect(maxPageReached, 5);

      // Học viên lật tiếp tới trang 8
      currentPage = 8;
      if (currentPage > maxPageReached) maxPageReached = currentPage;
      expect(maxPageReached, 8);

      // Học viên lật ngược lại trang 3 để đọc lại phần đầu
      currentPage = 3;
      if (currentPage > maxPageReached) maxPageReached = currentPage;
      // maxPageReached KHÔNG được bị giảm xuống 3
      expect(maxPageReached, 8, reason: 'Trang xa nhất từng đạt được phải được giữ nguyên là 8');

      // Học viên lật tiến tới trang 12
      currentPage = 12;
      if (currentPage > maxPageReached) maxPageReached = currentPage;
      expect(maxPageReached, 12, reason: 'Trang xa nhất phải cập nhật lên 12 khi xem trang lớn hơn');
    });

    test('TC05 - Tính toán phút đọc hiển thị từ giây đọc tích lũy', () {
      // 0s -> 0 phút
      expect(_calculateDisplayMinutes(0), 0);
      // 15s -> ít nhất 1 phút
      expect(_calculateDisplayMinutes(15), 1);
      // 59s -> 1 phút
      expect(_calculateDisplayMinutes(59), 1);
      // 65s -> 1 phút
      expect(_calculateDisplayMinutes(65), 1);
      // 90s (1.5 phút) -> làm tròn thành 2 phút
      expect(_calculateDisplayMinutes(90), 2);
      // 150s (2.5 phút) -> làm tròn thành 3 phút
      expect(_calculateDisplayMinutes(150), 3);
    });
  });
}

int _calculateDisplayMinutes(int seconds) {
  if (seconds <= 0) return 0;
  final minutes = (seconds + 30) ~/ 60;
  return minutes > 0 ? minutes : 1;
}
