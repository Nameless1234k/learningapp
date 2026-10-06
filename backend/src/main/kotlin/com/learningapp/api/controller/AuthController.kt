package com.learningapp.api.controller

import com.learningapp.api.constant.ApiEndpoints
import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.auth.*
import com.learningapp.api.service.AuthService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

/**
 * =========================================================================================
 * [GIẢI THÍCH DÀNH CHO NGƯỜI HỌC CÓ NỀN TẢNG JAVA / PYTHON]:
 *
 * 1. @RestController:
 *    - Là sự kết hợp của @Controller + @ResponseBody trong Spring Boot (Java).
 *    - Tương tự như Blueprint / Router trong Python Flask / FastAPI.
 *    - Mọi dữ liệu mà các hàm bên trong trả về sẽ được tự động chuyển đổi thành chuỗi JSON (Serialization).
 *
 * 2. @RequestMapping(ApiEndpoints.Auth.BASE):
 *    - Khai báo tiền tố đường dẫn chung cho toàn bộ các API trong file này, ở đây là "/api/auth".
 *    - Giống như prefix="/api/auth" khi include router trong FastAPI (Python).
 *
 * 3. @CrossOrigin(origins = ["*"]):
 *    - Cho phép chia sẻ tài nguyên giữa các nguồn khác nhau (Cross-Origin Resource Sharing).
 *    - Nhờ có annotation này, ứng dụng Frontend (Flutter Web, Mobile, React...) mới có thể gọi được API
 *      mà không bị trình duyệt chặn vì chính sách bảo mật CORS.
 *
 * 4. Constructor Injection trong Kotlin:
 *    - Cú pháp: "class AuthController(private val authService: AuthService)"
 *    - Trong Java: bạn phải khai báo "private final AuthService authService;" và viết thêm hàm dựng @Autowired.
 *    - Trong Kotlin: viết ngay trên đầu class cực kỳ ngắn gọn và tự động khởi tạo dependency injection.
 * =========================================================================================
 */
@RestController
@RequestMapping(ApiEndpoints.Auth.BASE)
@CrossOrigin(origins = ["*"])
class AuthController(private val authService: AuthService) {

    /**
     * API ĐĂNG KÝ TÀI KHOẢN MỚI
     * Đường dẫn: POST /api/auth/register
     *
     * @param request: Dữ liệu JSON từ client được tự động ép kiểu thành đối tượng RegisterRequest (@RequestBody)
     * @return: ResponseEntity chứa dữ liệu AuthResponse (nếu thành công) hoặc ApiResponse lỗi (nếu thất bại)
     */
    @PostMapping(ApiEndpoints.Auth.REGISTER)
    fun register(@RequestBody request: RegisterRequest): ResponseEntity<*> {
        return try {
            // Gọi tầng Service để xử lý nghiệp vụ băm mật khẩu và lưu vào Database
            val response = authService.register(request)
            // Trả về HTTP 200 OK kèm Token đăng nhập
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            // Nếu có lỗi (ví dụ trùng email), trả về HTTP 400 Bad Request kèm thông báo
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi đăng ký"))
        }
    }

    /**
     * API ĐĂNG NHẬP
     * Đường dẫn: POST /api/auth/login
     *
     * @param request: Chứa email và mật khẩu người dùng nhập
     */
    @PostMapping(ApiEndpoints.Auth.LOGIN)
    fun login(@RequestBody request: LoginRequest): ResponseEntity<*> {
        return try {
            // Kiểm tra mật khẩu khớp BCrypt và sinh JWT Token
            val response = authService.login(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi đăng nhập"))
        }
    }

    /**
     * API YÊU CẦU GỬI MÃ OTP QUÊN MẬT KHẨU
     * Đường dẫn: POST /api/auth/forgot-password
     *
     * @param request: Chứa email cần khôi phục
     */
    @PostMapping(ApiEndpoints.Auth.FORGOT_PASSWORD)
    fun forgotPassword(@RequestBody request: ForgotPasswordRequest): ResponseEntity<ApiResponse> {
        return try {
            // Sinh mã OTP 6 số, lưu vào bảng password_reset_otps và gửi email
            val response = authService.forgotPassword(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi gửi OTP"))
        }
    }

    /**
     * API XÁC THỰC MÃ OTP
     * Đường dẫn: POST /api/auth/verify-otp
     *
     * @param request: Chứa email và chuỗi mã 6 chữ số người dùng nhập
     */
    @PostMapping(ApiEndpoints.Auth.VERIFY_OTP)
    fun verifyOtp(@RequestBody request: VerifyOtpRequest): ResponseEntity<ApiResponse> {
        return try {
            // Kiểm tra mã OTP còn hạn không, đúng mã không và đánh dấu đã sử dụng (isUsed = true)
            val response = authService.verifyOtp(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi xác thực OTP"))
        }
    }

    /**
     * API ĐẶT LẠI MẬT KHẨU MỚI
     * Đường dẫn: POST /api/auth/reset-password
     *
     * @param request: Chứa email và mật khẩu mới
     */
    @PostMapping(ApiEndpoints.Auth.RESET_PASSWORD)
    fun resetPassword(@RequestBody request: ResetPasswordRequest): ResponseEntity<ApiResponse> {
        return try {
            // Kiểm tra xem user này đã xác thực OTP thành công gần đây chưa, sau đó băm mật khẩu mới
            val response = authService.resetPassword(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi đổi mật khẩu"))
        }
    }
}
