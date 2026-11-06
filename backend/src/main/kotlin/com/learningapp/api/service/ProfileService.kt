package com.learningapp.api.service

import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.profile.*
import com.learningapp.api.entity.UserSetting
import com.learningapp.api.repository.UserRepository
import com.learningapp.api.repository.UserSettingRepository
import com.learningapp.api.util.ValidationUtil
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime
import java.util.UUID

@Service
class ProfileService(
    private val userRepository: UserRepository,
    private val userSettingRepository: UserSettingRepository,
    private val passwordEncoder: PasswordEncoder
) {

    /**
     * Lấy thông tin cá nhân của người dùng
     */
    fun getProfile(userId: UUID): UserProfileResponse {
        val user = userRepository.findById(userId).orElseThrow {
            IllegalArgumentException("Người dùng không tồn tại!")
        }
        val fullName = "${user.lastName} ${user.firstName}".trim()
        return UserProfileResponse(
            id = user.id ?: userId,
            firstName = user.firstName,
            lastName = user.lastName,
            fullName = fullName,
            email = user.email,
            phone = user.phone,
            role = user.role
        )
    }

    /**
     * Cập nhật thông tin cá nhân (Họ, Tên, Số điện thoại)
     */
    @Transactional
    fun updateProfile(userId: UUID, request: UpdateProfileRequest): UserProfileResponse {
        val user = userRepository.findById(userId).orElseThrow {
            IllegalArgumentException("Người dùng không tồn tại!")
        }

        // Tận dụng 1 dòng kiểm tra Họ, Tên và 1 dòng kiểm tra Số điện thoại giống phần Đăng ký
        ValidationUtil.validateNames(request.firstName, request.lastName)
        ValidationUtil.validatePhone(request.phone)

        user.firstName = request.firstName.trim()
        user.lastName = request.lastName.trim()
        user.phone = request.phone?.trim()
        user.updatedAt = LocalDateTime.now()

        val savedUser = userRepository.save(user)
        val fullName = "${savedUser.lastName} ${savedUser.firstName}".trim()

        return UserProfileResponse(
            id = savedUser.id ?: userId,
            firstName = savedUser.firstName,
            lastName = savedUser.lastName,
            fullName = fullName,
            email = savedUser.email,
            phone = savedUser.phone,
            role = savedUser.role
        )
    }

    /**
     * Đổi mật khẩu tài khoản
     */
    @Transactional
    fun changePassword(userId: UUID, request: ChangePasswordRequest): ApiResponse {
        val user = userRepository.findById(userId).orElseThrow {
            IllegalArgumentException("Người dùng không tồn tại!")
        }

        // Tận dụng kiểm tra dữ liệu bằng các hàm chung (Mật khẩu tối thiểu 8 ký tự, xác nhận trùng khớp)
        ValidationUtil.validateRequired(
            "oldPassword" to request.oldPassword,
            "newPassword" to request.newPassword,
            "confirmPassword" to request.confirmPassword
        )
        ValidationUtil.validatePassword(request.newPassword)
        ValidationUtil.validatePasswordMatch(request.newPassword, request.confirmPassword)

        if (!passwordEncoder.matches(request.oldPassword, user.passwordHash)) {
            throw IllegalArgumentException("Mật khẩu hiện tại không chính xác!")
        }
        if (passwordEncoder.matches(request.newPassword, user.passwordHash)) {
            throw IllegalArgumentException("Mật khẩu mới không được trùng với mật khẩu cũ!")
        }

        user.passwordHash = passwordEncoder.encode(request.newPassword)
        user.updatedAt = LocalDateTime.now()
        userRepository.save(user)

        return ApiResponse(success = true, message = "Đổi mật khẩu thành công!")
    }

    /**
     * Lấy cài đặt giao diện (Dark mode) và thông báo của người dùng
     */
    fun getSettings(userId: UUID): UserSettingsDTO {
        val setting = userSettingRepository.findById(userId).orElseGet {
            userSettingRepository.save(
                UserSetting(
                    userId = userId,
                    darkMode = false
                )
            )
        }
        return UserSettingsDTO(
            darkMode = setting.darkMode,
            notificationEnabled = setting.notificationEnabled
        )
    }

    /**
     * Cập nhật cài đặt giao diện Sáng / Tối hoặc Thông báo
     */
    @Transactional
    fun updateSettings(userId: UUID, request: UpdateSettingsRequest): UserSettingsDTO {
        val setting = userSettingRepository.findById(userId).orElseGet {
            UserSetting(
                userId = userId,
                darkMode = false
            )
        }

        if (request.darkMode != null) {
            setting.darkMode = request.darkMode
        }
        if (request.notificationEnabled != null) {
            setting.notificationEnabled = request.notificationEnabled
        }
        setting.updatedAt = LocalDateTime.now()

        val saved = userSettingRepository.save(setting)
        return UserSettingsDTO(
            darkMode = saved.darkMode,
            notificationEnabled = saved.notificationEnabled
        )
    }

    /**
     * Lấy thống kê trắc nghiệm theo môn học:
     * - Khi chưa làm câu nào (mặc định hiện tại): trả về hasData = false
     * - Sau này khi kích hoạt phần trắc nghiệm: sẽ tính toán điểm và trả về hasData = true
     */
    fun getStatistics(userId: UUID): UserStatisticsResponse {
        // Kiểm tra xem user có tồn tại không
        if (!userRepository.existsById(userId)) {
            throw IllegalArgumentException("Người dùng không tồn tại!")
        }

        // Mặc định hiện tại theo yêu cầu: chưa làm câu trắc nghiệm nào -> trả về Chưa có thống kê
        return UserStatisticsResponse(
            hasData = false,
            totalQuestions = 0,
            message = "Chưa có thống kê",
            description = "Bạn chưa hoàn thành câu hỏi trắc nghiệm nào. Hãy làm bài luyện tập để theo dõi điểm số tại đây nhé!",
            subjectScores = emptyList()
        )
    }
}
