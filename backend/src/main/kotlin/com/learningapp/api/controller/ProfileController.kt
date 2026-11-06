package com.learningapp.api.controller

import com.learningapp.api.constant.ApiEndpoints
import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.profile.*
import com.learningapp.api.service.ProfileService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping(ApiEndpoints.UserProfile.BASE)
@CrossOrigin(origins = ["*"])
class ProfileController(
    private val profileService: ProfileService
) {

    /**
     * Lấy thông tin cá nhân: GET /api/user/profile?userId={id}
     */
    @GetMapping(ApiEndpoints.UserProfile.PROFILE)
    fun getProfile(@RequestParam userId: UUID): ResponseEntity<*> {
        return try {
            val profile = profileService.getProfile(userId)
            ResponseEntity.ok(profile)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi tải thông tin cá nhân"))
        }
    }

    /**
     * Cập nhật thông tin cá nhân (Họ, Tên, SĐT): PUT /api/user/profile?userId={id}
     */
    @PutMapping(ApiEndpoints.UserProfile.PROFILE)
    fun updateProfile(
        @RequestParam userId: UUID,
        @RequestBody request: UpdateProfileRequest
    ): ResponseEntity<*> {
        return try {
            val updated = profileService.updateProfile(userId, request)
            ResponseEntity.ok(updated)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi cập nhật thông tin"))
        }
    }

    /**
     * Đổi mật khẩu: PUT /api/user/change-password?userId={id}
     */
    @PutMapping(ApiEndpoints.UserProfile.CHANGE_PASSWORD)
    fun changePassword(
        @RequestParam userId: UUID,
        @RequestBody request: ChangePasswordRequest
    ): ResponseEntity<ApiResponse> {
        return try {
            val response = profileService.changePassword(userId, request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi đổi mật khẩu"))
        }
    }

    /**
     * Lấy cài đặt Sáng / Tối và Thông báo: GET /api/user/settings?userId={id}
     */
    @GetMapping(ApiEndpoints.UserProfile.SETTINGS)
    fun getSettings(@RequestParam userId: UUID): ResponseEntity<*> {
        return try {
            val settings = profileService.getSettings(userId)
            ResponseEntity.ok(settings)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi tải cài đặt"))
        }
    }

    /**
     * Cập nhật cài đặt Sáng / Tối (Switch toggle) hoặc Thông báo: PUT /api/user/settings?userId={id}
     */
    @PutMapping(ApiEndpoints.UserProfile.SETTINGS)
    fun updateSettings(
        @RequestParam userId: UUID,
        @RequestBody request: UpdateSettingsRequest
    ): ResponseEntity<*> {
        return try {
            val updated = profileService.updateSettings(userId, request)
            ResponseEntity.ok(updated)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi cập nhật cài đặt"))
        }
    }

    /**
     * Lấy thống kê trắc nghiệm theo Screen 22: GET /api/user/statistics?userId={id}
     * - Trả về hasData = false khi chưa làm bài trắc nghiệm nào
     */
    @GetMapping(ApiEndpoints.UserProfile.STATISTICS)
    fun getStatistics(@RequestParam userId: UUID): ResponseEntity<*> {
        return try {
            val stats = profileService.getStatistics(userId)
            ResponseEntity.ok(stats)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi tải thống kê"))
        }
    }
}
