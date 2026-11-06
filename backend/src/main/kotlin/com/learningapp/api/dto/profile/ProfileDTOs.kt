package com.learningapp.api.dto.profile

import java.util.UUID

/**
 * Thông tin chi tiết cá nhân trả về cho Client
 */
data class UserProfileResponse(
    val id: UUID,
    val firstName: String,
    val lastName: String,
    val fullName: String,
    val email: String,
    val phone: String?,
    val role: String
)

/**
 * Yêu cầu cập nhật thông tin cá nhân (Họ, Tên, Số điện thoại)
 */
data class UpdateProfileRequest(
    val firstName: String,
    val lastName: String,
    val phone: String?
)

/**
 * Yêu cầu đổi mật khẩu
 */
data class ChangePasswordRequest(
    val oldPassword: String,
    val newPassword: String,
    val confirmPassword: String
)

/**
 * DTO thiết lập người dùng (Dark mode, Thông báo)
 */
data class UserSettingsDTO(
    val darkMode: Boolean,
    val notificationEnabled: Boolean
)

/**
 * Yêu cầu cập nhật thiết lập (Dark mode, Thông báo)
 */
data class UpdateSettingsRequest(
    val darkMode: Boolean? = null,
    val notificationEnabled: Boolean? = null
)

/**
 * DTO Thống kê bài trắc nghiệm (theo Screen 22):
 * - Khi chưa làm câu nào: hasData = false, hiển thị "Chưa có thống kê"
 * - Khi đã làm câu nào: hasData = true, vẽ biểu đồ 5 cột môn học
 */
data class UserStatisticsResponse(
    val hasData: Boolean = false,
    val totalQuestions: Int = 0,
    val message: String = "Chưa có thống kê",
    val description: String = "Bạn chưa hoàn thành câu hỏi trắc nghiệm nào. Hãy làm bài luyện tập để theo dõi điểm số tại đây nhé!",
    val subjectScores: List<SubjectScoreDTO> = emptyList()
)

data class SubjectScoreDTO(
    val subjectCode: String,
    val subjectName: String,
    val score: Double
)
