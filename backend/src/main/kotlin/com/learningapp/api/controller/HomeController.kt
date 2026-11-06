package com.learningapp.api.controller

import com.learningapp.api.constant.ApiEndpoints
import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.service.HomeService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.util.UUID

/**
 * =========================================================================================
 * [TÊN FILE]: HomeController.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/controller/
 * [TẦNG KIẾN TRÚC]: Controller (REST API Controller - Pattern MVC)
 * [MỤC ĐÍCH]: Cung cấp API dữ liệu cho màn hình Trang chủ (Screen 1):
 * - Endpoint: GET /api/home/dashboard?userId={userId}
 * - Phục vụ thẻ "Phiên học hôm nay", tự động phân nhánh người dùng mới/cũ,
 *   tính % tiến độ và trả về danh sách "Đã học".
 * =========================================================================================
 */
@RestController
@RequestMapping(ApiEndpoints.Home.BASE)
@CrossOrigin(origins = ["*"])
class HomeController(
    private val homeService: HomeService
) {

    @GetMapping(ApiEndpoints.Home.DASHBOARD)
    fun getDashboard(
        @RequestParam userId: UUID
    ): ResponseEntity<*> {
        return try {
            val response = homeService.getHomeDashboard(userId)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(
                ApiResponse(false, e.message ?: "Lỗi lấy dữ liệu trang chủ")
            )
        }
    }
}
