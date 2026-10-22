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
// =========================================================================================

class SubjectDetailScreen extends StatefulWidget {
  final String subjectId; // Mã định danh UUID của môn học
  final String subjectName; // Tên môn học để hiển thị trên Header (vd: Triết học Mác - Lênin)

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
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

  /// Hàm công khai hỗ trợ làm mới danh sách bài học từ bên ngoài hoặc qua cử chỉ kéo
  Future<void> refresh({bool silent = false}) => _loadLessons(silent: silent);

  @override
  void initState() {
    super.initState();
    // Gọi API nạp danh sách bài học ngay khi mở màn hình
    _loadLessons();
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
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD), // Màu nền xám trắng tinh tế
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. PHẦN HEADER: Nút quay lại '<', Tên môn học và Phụ đề tiến độ
            _buildHeader(),

            const SizedBox(height: 12),

            // 2. PHẦN BODY: Danh sách bài học hoặc trạng thái Lỗi / Đang cập nhật
            Expanded(
              child: _buildBodyContent(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng thanh Header phía trên giống thiết kế Adobe XD Screen 14
  Widget _buildHeader() {
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
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Color(0xFF15193B),
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
                  _subjectDetail?.subjectName ?? widget.subjectName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15193B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalLessonsStr · $progressStr',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
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

  // Widget xây dựng nội dung bài học
  Widget _buildBodyContent() {
    // Trường hợp 1: Đang tải dữ liệu từ máy chủ
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF15193B),
        ),
      );
    }

    // Trường hợp 2: Gặp lỗi kết nối mạng
    if (_errorMessage != null) {
      return AppRefreshIndicator(
        onRefresh: () => _loadLessons(silent: false),
        child: SingleChildScrollView(
          physics: AppRefreshIndicator.alwaysScrollPhysics,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24.0),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadLessons(silent: false),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15193B)),
                  child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Trường hợp 3: Luồng rẽ nhánh 3.2 - Môn học chưa có tài liệu / bài học
    if (_subjectDetail == null || _subjectDetail!.lessons.isEmpty) {
      return AppRefreshIndicator(
        onRefresh: () => _loadLessons(silent: false),
        child: SingleChildScrollView(
          physics: AppRefreshIndicator.alwaysScrollPhysics,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15193B).withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories_outlined,
                    size: 54,
                    color: Color(0xFF15193B),
                  ),
                ),
                const SizedBox(height: 20),
                // Thông báo chính xác theo đặc tả Use Case trong file docx:
                const Text(
                  'Hệ thống đang cập nhật tài liệu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15193B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tài liệu cho môn học này đang được chuẩn bị và sẽ sớm được cập nhật.\nVuốt xuống để làm mới.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Trường hợp 4: Hiển thị danh sách các bài học (Screen 14 Adobe XD)
    return AppRefreshIndicator(
      onRefresh: () => _loadLessons(silent: false),
      child: ListView.builder(
        physics: AppRefreshIndicator.alwaysScrollPhysics,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        itemCount: _subjectDetail!.lessons.length,
        itemBuilder: (context, index) {
          final lesson = _subjectDetail!.lessons[index];
          return _buildLessonCard(lesson);
        },
      ),
    );
  }

  // Widget vẽ từng thẻ Bài học bo tròn đẹp mắt
  Widget _buildLessonCard(LessonItem lesson) {
    // Trạng thái chuỗi: hiển thị thời gian học viên thực tế đã đọc từ database (ví dụ: "1 phút · đã đọc")
    final readStatusText = lesson.isRead ? 'đã đọc' : 'chưa đọc';
    final int displayMinutes = lesson.readingMinutes > 0
        ? lesson.readingMinutes
        : (lesson.isRead ? 1 : 0);
    final durationText = '$displayMinutes phút';

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15193B).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        title: Text(
          lesson.title.trim().isNotEmpty
              ? 'Bài ${lesson.lessonNo}. ${lesson.title}'
              : 'Bài ${lesson.lessonNo}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF15193B),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 15,
                color: Color(0xFF8E8E93),
              ),
              const SizedBox(width: 4),
              Text(
                '$durationText · $readStatusText',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        trailing: lesson.isRead
            ? const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 24,
              )
            : const Icon(
                Icons.chevron_right,
                color: Color(0xFF15193B),
                size: 24,
              ),
        onTap: () {
          // =====================================================================================
          // [XỬ LÝ MỞ TÀI LIỆU PDF HOÀN TOÀN ĐỘNG TỪ DATABASE]
          // - KHÔNG CÒN GẮN CỨNG tên file PDF trong mã nguồn!
          // - Đọc trực tiếp đường dẫn 'lesson.pdfUrl' do API trả về từ bảng 'documents'.
          // =====================================================================================

          // Trường hợp 1: Bài học này chưa được đính kèm tài liệu PDF
          if (!_controller.hasPdfDocument(lesson.pdfUrl)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hệ thống đang cập nhật tài liệu cho "${lesson.title}"!',
                        style: const TextStyle(fontSize: 14),
                      ),
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
