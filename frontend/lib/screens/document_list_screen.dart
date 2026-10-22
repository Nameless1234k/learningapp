import 'package:flutter/material.dart';
import '../controllers/subject_controller.dart';
import '../models/subject_model.dart';
import '../widgets/app_refresh_indicator.dart';
import 'subject_detail_screen.dart';

// =========================================================================================
// [TÊN FILE: document_list_screen.dart]
// [VỊ TRÍ]: lib/screens/document_list_screen.dart
// [THIẾT KẾ ADOBE XD]: Screen 9 (anh_adobeXD/screen_9.png)
// [ĐẶC TẢ USE CASE]: "Xem tài liệu" - Bước 1:
// - Bắt đầu khi người dùng kích vào chữ "Tài liệu" ở bottom bar.
// - Hệ thống truy vấn vào bảng subjects, user_lesson_progress và lấy danh sách môn học và hiển thị % tiến độ.
// - Người dùng kích vào môn học -> Chuyển sang Screen 14 (SubjectDetailScreen).
// =========================================================================================

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => DocumentListScreenState();
}

class DocumentListScreenState extends State<DocumentListScreen> {
  // Khởi tạo Controller xử lý logic
  final SubjectController _subjectController = SubjectController();

  // Biến lưu trữ dữ liệu danh sách môn học
  SubjectListModel? _subjectListData;
  bool _isLoading = true; // Trạng thái đang tải dữ liệu
  String? _errorMessage; // Thông báo lỗi nếu xảy ra sự cố

  /// Hàm công khai hỗ trợ làm mới danh sách môn học từ bên ngoài (khi chuyển tab) hoặc qua cử chỉ kéo
  Future<void> refresh({bool silent = true}) => _fetchSubjects(silent: silent);

  @override
  void initState() {
    super.initState();
    // Tự động gọi API tải danh sách môn học khi mở tab Tài liệu
    _fetchSubjects();
  }

  // Hàm tải dữ liệu môn học từ API Backend (silent = true khi làm mới ngầm)
  Future<void> _fetchSubjects({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final data = await _subjectController.loadSubjects();
      if (!mounted) return;
      setState(() {
        _subjectListData = data;
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
      backgroundColor: const Color(0xFFFBFBFD), // Màu nền xám trắng chuẩn thiết kế
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. PHẦN HEADER: Tiêu đề "Tài liệu", thông tin tổng môn và Chuông thông báo
            _buildTopHeader(),

            const SizedBox(height: 12),

            // 2. PHẦN BODY: Danh sách 5 môn học kèm vòng tròn % tiến độ
            Expanded(
              child: _buildBodyContent(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị Header phía trên theo đúng Screen 9 của Adobe XD
  Widget _buildTopHeader() {
    final totalSubjects = _subjectListData?.totalSubjects ?? 5;
    final readSubjects = _subjectListData?.readSubjects ?? 0;

    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tiêu đề và số môn đã đọc (vd: "5 môn · đã đọc 4/5 môn")
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tài liệu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF15193B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalSubjects môn · đã đọc $readSubjects/$totalSubjects môn',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Icon chuông thông báo có viền tròn bao quanh
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chưa có thông báo mới nào.'),
                  duration: Duration(seconds: 1),
                ),
              );
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
                Icons.notifications_none_rounded,
                color: Color(0xFF15193B),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị nội dung chính: danh sách môn hoặc trạng thái Loading / Error
  Widget _buildBodyContent() {
    // Đang tải dữ liệu
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF15193B)),
      );
    }

    // Báo lỗi kết nối
    if (_errorMessage != null) {
      return AppRefreshIndicator(
        onRefresh: _fetchSubjects,
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
                const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchSubjects,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15193B)),
                  child: const Text('Tải lại', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Danh sách rỗng
    if (_subjectListData == null || _subjectListData!.subjects.isEmpty) {
      return AppRefreshIndicator(
        onRefresh: _fetchSubjects,
        child: SingleChildScrollView(
          physics: AppRefreshIndicator.alwaysScrollPhysics,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32.0),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open_rounded, size: 54, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có môn học nào trong hệ thống.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Vuốt xuống để làm mới.',
                  style: TextStyle(color: Colors.black38, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Hiển thị danh sách các thẻ môn học kèm cử chỉ kéo để làm mới (Pull-to-refresh)
    return AppRefreshIndicator(
      onRefresh: _fetchSubjects,
      child: ListView.builder(
        physics: AppRefreshIndicator.alwaysScrollPhysics,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        itemCount: _subjectListData!.subjects.length,
        itemBuilder: (context, index) {
          final subject = _subjectListData!.subjects[index];
          return _buildSubjectCard(subject);
        },
      ),
    );
  }

  // Widget vẽ từng thẻ Môn học (Card) theo chuẩn thiết kế Screen 9
  Widget _buildSubjectCard(SubjectItem subject) {
    // Lấy bài tiếp theo hoặc hiển thị mặc định
    final nextLessonText = subject.nextLesson ?? 'Chưa bắt đầu học';

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15193B).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Bước 2 đặc tả docx: Kích vào môn học -> Mở Screen 14 (SubjectDetailScreen)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectDetailScreen(
                subjectId: subject.id,
                subjectName: subject.name,
              ),
            ),
          ).then((_) {
            // Khi quay lại từ Screen 14, tự động tải lại để cập nhật % tiến độ mới nhất
            _fetchSubjects(silent: true);
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              // 1. Vòng tròn hiển thị % tiến độ môn học bên trái
              _buildProgressCircle(subject.progressPercent),

              const SizedBox(width: 16),

              // 2. Tên môn học và dòng "Bài tiếp theo: ..."
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15193B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nextLessonText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 3. Mũi tên điều hướng '>' sang màn hình chi tiết
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF15193B),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget vẽ Vòng tròn % tiến độ bo tròn theo Adobe XD Screen 9
  Widget _buildProgressCircle(double percent) {
    final int displayPercent = percent.toInt();
    final double progressValue = (percent / 100.0).clamp(0.0, 1.0);

    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Vòng tròn tiến độ
          CircularProgressIndicator(
            value: progressValue,
            strokeWidth: 4.5,
            backgroundColor: const Color(0xFFE5E7EB), // Màu xám cho phần chưa học
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF15193B)), // Màu xanh đậm cho phần đã học
            strokeCap: StrokeCap.round,
          ),
          // Con số % ở giữa vòng tròn
          Center(
            child: Text(
              '$displayPercent%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF15193B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
