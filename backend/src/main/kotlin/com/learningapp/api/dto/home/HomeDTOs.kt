package com.learningapp.api.dto.home

/**
 * =========================================================================================
 * [TÊN FILE]: HomeDTOs.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/dto/home/
 * [TẦNG KIẾN TRÚC]: Data Transfer Object (DTO - Pattern MVC)
 * [MỤC ĐÍCH]: Đóng gói dữ liệu hiển thị cho màn hình Trang chủ (Screen 1)
 * =========================================================================================
 */

/**
 * Thông tin chi tiết của thẻ "PHIÊN HỌC HÔM NAY"
 */
data class TodaySessionResponse(
    val lessonId: String,
    val subjectId: String,
    val subjectName: String,
    val lessonNo: Int,
    val lessonTitle: String,
    val progressPercent: Double,      // Phần trăm tiến độ (0 - 100)
    val lastPosition: Int,            // Vị trí trang đọc dở (bắt đầu từ 1)
    val totalPages: Int,              // Tổng số trang tài liệu
    val pdfUrl: String?,              // Đường dẫn tải trực tiếp file PDF
    val buttonText: String,           // Chữ trên nút: "Vào học" hoặc "Tiếp tục học"
    val status: String,               // "NOT_STARTED", "IN_PROGRESS", "COMPLETED"
    val readingSeconds: Int = 0       // Số giây đọc tích lũy
)

/**
 * Thông tin của từng bài học trong danh sách "ĐÃ HỌC"
 */
data class RecentLessonResponse(
    val lessonId: String,
    val lessonTitle: String,
    val subjectName: String,
    val progressPercent: Double,
    val lastPosition: Int,
    val pdfUrl: String?,
    val lastReadAt: String?
)

/**
 * Dữ liệu tổng thể trả về cho Trang chủ (Screen 1)
 */
data class HomeDashboardResponse(
    val greeting: String,             // "Chào mừng bạn đến với Learning App" hoặc "Xin chào, [Tên]!"
    val userFullName: String,         // Họ và tên người dùng
    val userInitials: String,         // Chữ cái viết tắt làm Avatar (vd: "LH")
    val isNewUser: Boolean,           // true nếu tài khoản mới chưa từng học
    val todaySession: TodaySessionResponse?, // Thẻ Phiên học hôm nay
    val recentLessons: List<RecentLessonResponse> // Danh sách bài đã học gần đây
)
