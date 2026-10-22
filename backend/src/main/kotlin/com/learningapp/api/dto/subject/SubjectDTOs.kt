package com.learningapp.api.dto.subject

/**
 * =========================================================================================
 * [TÊN FILE]: SubjectDTOs.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/dto/subject/
 * [TẦNG KIẾN TRÚC]: Data Transfer Object (DTO)
 *
 * [CHỨC NĂNG CHÍNH]:
 * - Định nghĩa cấu trúc JSON trả về cho Client (Flutter App) cho màn hình Môn học (Screen 9)
 *   và màn hình Chi tiết bài học (Screen 14).
 * - Giúp che giấu cấu trúc bảng Entity thật của Database và chỉ gửi những thông tin cần thiết.
 * - Đã loại bỏ trường 'description' theo yêu cầu tinh gọn cấu trúc dữ liệu.
 *
 * [LIÊN KẾT VỚI]:
 * - SubjectService.kt: Gom dữ liệu từ Entity và đóng gói vào các DTO này.
 * - SubjectController.kt: Trả các DTO này về cho HTTP response.
 * - Flutter lesson_model.dart & subject_model.dart: Hứng JSON này để hiển thị UI.
 * =========================================================================================
 */

/**
 * Thông tin của 1 môn học kèm tiến độ học của người dùng (Screen 9 - Danh sách môn học)
 */
data class SubjectProgressResponse(
    val id: String,                 // Mã UUID định danh môn học
    val code: String,               // Mã môn: "TRIET_HOC", "CNXHKH"...
    val name: String,               // Tên hiển thị môn: "Triết học Mác - Lênin"
    val progressPercent: Double,    // Phần trăm tiến độ hoàn thành (vd: 50.0%)
    val nextLesson: String?,        // Tên bài học tiếp theo cần học
    val totalLessons: Int,          // Tổng số bài học của môn
    val completedLessons: Int       // Số bài học người dùng đã hoàn thành
)

/**
 * Phản hồi danh sách môn học tổng thể (Screen 9)
 */
data class SubjectListResponse(
    val totalSubjects: Int,                       // Tổng số môn học trong hệ thống
    val readSubjects: Int,                        // Số môn học người dùng đã bắt đầu học
    val subjects: List<SubjectProgressResponse>   // Danh sách chi tiết từng môn
)

/**
 * Thông tin của 1 bài học (Screen 14 - Chi tiết bài học)
 */
data class LessonItemResponse(
    val id: String,                 // Mã UUID bài học
    val lessonNo: Int,              // Số thứ tự bài (vd: 1, 2, 3...)
    val title: String,              // Tiêu đề/chủ đề bài học (Lấy từ bảng lessons)
    val estimatedMinutes: Int,      // Thời lượng đọc ước tính (phút)
    val status: String,             // Trạng thái: "NOT_STARTED", "IN_PROGRESS", "COMPLETED"
    val isRead: Boolean,            // true nếu đã đọc, false nếu chưa đọc
    val pdfUrl: String? = null,     // Đường dẫn tải file PDF thực tế từ bảng documents (KHÔNG CÒN HARDCODE)
    val readingMinutes: Int = 0,    // Thời gian thực tế học viên đã đọc tính bằng phút
    val readingSeconds: Int = 0,    // Tổng số giây thực tế học viên đã đọc tích lũy
    val lastPosition: Int = 1       // Trang tài liệu lớn nhất học viên đã đọc
)

/**
 * Chi tiết toàn bộ môn học và danh sách bài học (Screen 14)
 */
data class SubjectDetailResponse(
    val subjectId: String,                  // Mã UUID môn học
    val subjectName: String,                // Tên môn học
    val totalLessons: Int,                  // Tổng số bài học
    val progressPercent: Double,            // Phần trăm hoàn thành môn học
    val lessons: List<LessonItemResponse>   // Danh sách tất cả bài học thuộc môn
)

/**
 * Yêu cầu tự động cập nhật tiến độ bài học (Screen 14 / PdfViewer)
 */
data class UpdateLessonProgressRequest(
    val pageNumber: Int = 1,          // Trang hiện tại đang đọc
    val totalPages: Int = 1,          // Tổng số trang của file tài liệu
    val secondsSpent: Int = 0,        // Số giây đọc tích lũy tổng cộng
    val durationSeconds: Int? = null  // Hoặc số giây đọc thêm của riêng phiên này
)

/**
 * Kết quả trả về sau khi cập nhật tiến độ tự động
 */
data class LessonProgressResponse(
    val lessonId: String,
    val status: String,               // "IN_PROGRESS", "COMPLETED"
    val isRead: Boolean,              // true nếu đã đọc
    val progressPercent: Double,      // 100.0 nếu đã hoàn thành
    val lastPosition: Int,            // Trang tài liệu đã ghi nhận (lớn nhất)
    val subjectProgressPercent: Double,// % tiến độ mới của môn học
    val readingMinutes: Int = 0,      // Thời gian thực tế đã đọc tính bằng phút
    val readingSeconds: Int = 0       // Tổng số giây thực tế đã đọc
)

