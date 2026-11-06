import 'package:flutter/material.dart';
import '../controllers/subject_controller.dart';
import '../models/lesson_model.dart';
import '../widgets/app_refresh_indicator.dart';
import 'pdf_viewer_screen.dart';

// =========================================================================================
// [TÊN FILE: subject_detail_screen.dart]
// [VỊ TRÍ]: lib/screens/subject_detail_screen.dart
// [THIẾT KẾ ADOBE XD]: Screen 14 (anh_adobeXD/screen_14.png)
// [ĐẶC TẢ USE CASE]: "Xem tài liệu" - Bước 2:
// - Người dùng kích vào một môn học bất kì. Hệ thống truy vấn bảng lessons, user_lesson_progress
//   và hiển thị ra danh sách bài học, thời gian đã đọc bài học đó và trạng thái bài học.
// - Nhánh rẽ: Nếu môn học chưa có tài liệu, hiển thị "Hệ thống đang cập nhật tài liệu".
// - Nhánh rẽ: Kích nút "<--" thì quay lại trang môn học (Screen 9).
// - Hỗ trợ mở bài đọc trực tiếp từ "Phiên học hôm nay". Khi thoát PDF, người dùng sẽ ở lại
//   đúng trang bài học này chứ không bị văng thẳng về Trang chủ!
// =========================================================================================

class SubjectDetailScreen extends StatefulWidget {
  final String subjectId; // Mã định danh UUID của môn học
  final String subjectName; // Tên môn học để hiển thị trên Header (vd: Triết học Mác - Lênin)
  final String? initialOpenLessonId;
  final String? initialOpenPdfUrl;
  final String? initialOpenTitle;
  final int? initialOpenLastPosition;
  final int? initialOpenReadingSeconds;
  final bool? initialOpenIsRead;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    this.initialOpenLessonId,
    this.initialOpenPdfUrl,
    this.initialOpenTitle,
    this.initialOpenLastPosition,
    this.initialOpenReadingSeconds,
    this.initialOpenIsRead,
  });

  @override
  State<SubjectDetailScreen> createState() => SubjectDetailScreenState();
}

class SubjectDetailScreenState extends State<SubjectDetailScreen> {
  // Khởi tạo Controller điều phối dữ liệu
  final SubjectController _controller = SubjectController();

  // Biến lưu trữ trạng thái chi tiết môn học
  SubjectDetailModel? _subjectDetail;
  bool _isLoading = true; // Trạng thái đang tải từ API
  String? _errorMessage; // Chuỗi lỗi nếu kết nối thất bại
  bool _hasAutoOpened = false;

  /// Hàm công khai hỗ trợ làm mới danh sách bài học từ bên ngoài hoặc qua cử chỉ kéo
  Future<void> refresh({bool silent = false}) => _loadLessons(silent: silent);

  @override
  void initState() {
    super.initState();
    // Gọi API nạp danh sách bài học ngay khi mở màn hình
    _loadLessons();

    // Tự động mở bài đọc PDF nếu chuyển tiếp từ Phiên học hôm nay
    if (widget.initialOpenLessonId != null &&
        widget.initialOpenPdfUrl != null &&
        !_hasAutoOpened) {
      _hasAutoOpened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final fullPdfUrl = _controller.resolvePdfUrl(widget.initialOpenPdfUrl!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              title: widget.initialOpenTitle ?? 'Bài học',
              pdfUrl: fullPdfUrl,
              lessonId: widget.initialOpenLessonId,
              initialIsRead: widget.initialOpenIsRead ?? false,
              initialReadingSeconds: widget.initialOpenReadingSeconds ?? 0,
              initialLastPosition: widget.initialOpenLastPosition ?? 1,
            ),
          ),
        ).then((_) {
          // Khi thoát trình đọc PDF: Học viên ở lại đúng trang bài học này,
          // và tự động nạp lại danh sách bài để cập nhật % tiến độ môn & bài vừa học!
          _loadLessons(silent: true);
        });
      });
    }
  }

  // Hàm gọi Controller để tải bài học (silent = true khi làm mới ngầm lúc quay lại từ PDF)
  Future<void> _loadLessons({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Gọi controller lấy chi tiết bài học
      final detail = await _controller.loadSubjectLessons(widget.subjectId);
      if (!mounted) return;
      setState(() {
        _subjectDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFBFBFD),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. PHẦN HEADER: Nút quay lại '<', Tên môn học và Phụ đề tiến độ
            _buildHeader(isDark),

            const SizedBox(height: 12),

            // 2. PHẦN BODY: Danh sách bài học hoặc trạng thái Lỗi / Đang cập nhật
            Expanded(
              child: _buildBodyContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng thanh Header phía trên giống thiết kế Adobe XD Screen 14
  Widget _buildHeader(bool isDark) {
    // Định dạng % tiến độ thành chuỗi không có số thập phân thừa
    final progressStr = _subjectDetail != null
        ? '${_subjectDetail!.progressPercent.toInt()}%'
        : '0%';
    final totalLessonsStr = _subjectDetail != null
        ? '${_subjectDetail!.totalLessons} bài'
        : '0 bài';

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nút quay lại hình tròn viền mỏng theo Adobe XD: nút "<--"
          InkWell(
            onTap: () {
              // Nhánh rẽ: Kích nút "<--" thì quay lại trang môn học
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.chevron_left,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Tên môn học và Phụ đề tiến độ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subjectName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Đã hoàn thành $progressStr ($totalLessonsStr)',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị nội dung thân màn hình
  Widget _buildBodyContent(bool isDark) {
    // Trạng thái 1: Đang tải dữ liệu từ API
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF15193B),
        ),
      );
    }

    // Trạng thái 2: Gặp lỗi kết nối
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? const Color(0xFFCBD5E1) : Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadLessons(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF15193B),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Trạng thái 3: Môn học chưa có tài liệu/bài học nào
    if (_subjectDetail == null || _subjectDetail!.lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: 56, color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Hệ thống đang cập nhật tài liệu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Vui lòng quay lại sau!',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Trạng thái 4: Hiển thị danh sách bài học dạng thẻ bo tròn
    final lessons = _subjectDetail!.lessons;

    return AppRefreshIndicator(
      onRefresh: () => _loadLessons(silent: false),
      child: ListView.builder(
        physics: AppRefreshIndicator.alwaysScrollPhysics,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return _buildLessonCard(lesson, isDark);
        },
      ),
    );
  }

  // Widget xây dựng thẻ của từng bài học
  Widget _buildLessonCard(LessonItem lesson, bool isDark) {
    // Xác định màu sắc và trạng thái dựa trên isRead
    final isCompleted = lesson.isRead || lesson.status == 'COMPLETED';

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: isDark ? Border.all(color: const Color(0xFF334155), width: 1.2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        // Icon bài học dạng tròn có màu nổi bật bên trái
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? (isCompleted ? const Color(0xFF064E3B) : const Color(0xFF334155))
                : (isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFF0F2F5)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.menu_book_rounded,
            color: isCompleted
                ? (isDark ? const Color(0xFF34D399) : Colors.green.shade600)
                : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF15193B)),
            size: 22,
          ),
        ),
        // Tiêu đề bài học: hiển thị số thứ tự bài và tiêu đề chi tiết
        title: Text(
          'Bài ${lesson.lessonNo}. ${lesson.title}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF15193B),
          ),
        ),
        // Phụ đề: hiển thị thời gian học viên đã đọc thực tế (phút) và trạng thái
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              // Hiển thị thời gian đã đọc thực tế
              if (lesson.readingMinutes > 0) ...[
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.black54,
                ),
                const SizedBox(width: 4),
                Text(
                  'Đã học ${lesson.readingMinutes} phút',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.black54,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Trạng thái Chưa đọc / Đang học / Đã đọc
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? (isCompleted
                          ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                          : (lesson.status == 'IN_PROGRESS'
                              ? const Color(0xFF0C4A6E).withValues(alpha: 0.6)
                              : const Color(0xFF334155)))
                      : (isCompleted
                          ? Colors.green.shade50
                          : (lesson.status == 'IN_PROGRESS' ? Colors.blue.shade50 : Colors.grey.shade100)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCompleted
                      ? 'Đã đọc'
                      : (lesson.status == 'IN_PROGRESS' ? 'Đang học' : 'Chưa đọc'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? (isCompleted
                            ? const Color(0xFF34D399)
                            : (lesson.status == 'IN_PROGRESS'
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF94A3B8)))
                        : (isCompleted
                            ? Colors.green.shade700
                            : (lesson.status == 'IN_PROGRESS' ? Colors.blue.shade700 : Colors.black54)),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Mũi tên dẫn tiếp
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: isDark ? const Color(0xFF64748B) : Colors.black26,
        ),
        // Bấm vào bài học để mở đọc PDF
        onTap: () {
          // Trường hợp 1: Bài học chưa có file PDF đính kèm trong Database
          if (lesson.pdfUrl == null || lesson.pdfUrl!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Hệ thống đang cập nhật tài liệu cho bài học này.'),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF15193B),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }

          // Trường hợp 2: Có link PDF từ Database -> Chuẩn bị URL đầy đủ qua SubjectController
          final fullPdfUrl = _controller.resolvePdfUrl(lesson.pdfUrl!);

          // Điều hướng đến màn hình đọc PDF kèm cơ chế tự động ghi nhận tiến độ
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                title: 'Bài ${lesson.lessonNo}. ${lesson.title}',
                pdfUrl: fullPdfUrl,
                lessonId: lesson.id,
                initialIsRead: lesson.isRead,
                initialReadingSeconds: lesson.readingSeconds,
                initialLastPosition: lesson.lastPosition,
              ),
            ),
          ).then((_) {
            // TỰ ĐỘNG LÀM MỚI (Zero-click refresh):
            // Ngay khi thoát trang đọc PDF quay lại, tự động nạp lại API ngầm để cập nhật % môn và trạng thái bài
            _loadLessons(silent: true);
          });
        },
      ),
    );
  }
}
