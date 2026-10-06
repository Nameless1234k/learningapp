package com.learningapp.api.controller

import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.auth.*
import com.learningapp.api.service.AuthService
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.http.HttpStatus

/**
 * =========================================================================================
 * [GIẢI THÍCH CHO NGƯỜI HỌC CÓ NỀN TẢNG JAVA / PYTHON]:
 *
 * Controller trong mô hình MVC:
 * - Tiếp nhận các yêu cầu HTTP (GET, POST, PUT, DELETE) từ Frontend.
 * - Gọi tầng Service để xử lý nghiệp vụ.
 * - Trả về mã phản hồi HTTP (200 OK, 400 Bad Request, 500 Internal Server Error) kèm dữ liệu JSON.
 *
 * Bài test này kiểm tra:
 * - Controller có gọi đúng hàm trong AuthService không?
 * - Khi Service thành công thì Controller có trả về HTTP 200 (OK) không?
 * - Khi Service quăng lỗi thì Controller có bắt lỗi và trả về HTTP 400 (Bad Request) không?
 * =========================================================================================
 */
@ExtendWith(MockitoExtension::class)
class AuthControllerTest {

    // [MOCK SERVICE]: Giả lập AuthService để Controller không phụ thuộc vào logic thực tế
    @Mock
    private lateinit var authService: AuthService

    // [@InjectMocks]: Tự động đưa mock AuthService vào AuthController
    @InjectMocks
    private lateinit var authController: AuthController

    @Test
    @DisplayName("TC01 - Endpoint Register trả về HTTP 200 khi đăng ký thành công")
    fun testRegister_Success() {
        // Chuẩn bị dữ liệu đầu vào
        val request = RegisterRequest("Van A", "Nguyen", "test@example.com", null, "12345678")
        val mockResponse = AuthResponse("mock_token", "user_1", "test@example.com", "Nguyen Van A")

        // Khi controller gọi authService.register -> trả về mockResponse
        `when`(authService.register(request)).thenReturn(mockResponse)

        // Thực thi hàm trong Controller
        val result = authController.register(request)

        // Kiểm tra mã trạng thái HTTP là 200 (OK)
        assertEquals(HttpStatus.OK, result.statusCode)
        assertEquals(mockResponse, result.body)
    }

    @Test
    @DisplayName("TC02 - Endpoint Register trả về HTTP 400 khi Service báo lỗi")
    fun testRegister_Failure_ReturnsBadRequest() {
        val request = RegisterRequest("Van A", "Nguyen", "duplicate@example.com", null, "12345678")

        // Giả lập Service quăng ngoại lệ do trùng email
        `when`(authService.register(request)).thenThrow(IllegalArgumentException("Email này đã được sử dụng!"))

        val result = authController.register(request)

        // Kiểm tra mã trạng thái HTTP là 400 (Bad Request)
        assertEquals(HttpStatus.BAD_REQUEST, result.statusCode)
        assertTrue(result.body is ApiResponse)
        val body = result.body as ApiResponse
        assertFalse(body.success)
        assertEquals("Email này đã được sử dụng!", body.message)
    }

    @Test
    @DisplayName("TC03 - Endpoint Login trả về HTTP 200 khi đăng nhập thành công")
    fun testLogin_Success() {
        val request = LoginRequest("test@example.com", "12345678")
        val mockResponse = AuthResponse("mock_token", "user_1", "test@example.com", "Nguyen Van A")

        `when`(authService.login(request)).thenReturn(mockResponse)

        val result = authController.login(request)

        assertEquals(HttpStatus.OK, result.statusCode)
        assertEquals(mockResponse, result.body)
    }

    @Test
    @DisplayName("TC04 - Endpoint Login trả về HTTP 400 khi sai tài khoản hoặc mật khẩu")
    fun testLogin_Failure_ReturnsBadRequest() {
        val request = LoginRequest("test@example.com", "wrong_pass")

        `when`(authService.login(request)).thenThrow(IllegalArgumentException("Tài khoản hoặc mật khẩu không chính xác!"))

        val result = authController.login(request)

        assertEquals(HttpStatus.BAD_REQUEST, result.statusCode)
        val body = result.body as ApiResponse
        assertFalse(body.success)
        assertEquals("Tài khoản hoặc mật khẩu không chính xác!", body.message)
    }

    @Test
    @DisplayName("TC05 - Endpoint Forgot Password trả về HTTP 200 khi gửi OTP thành công")
    fun testForgotPassword_Success() {
        val request = ForgotPasswordRequest("test@example.com")
        val mockResponse = ApiResponse(true, "Mã xác thực đã được gửi tới email của bạn.")

        `when`(authService.forgotPassword(request)).thenReturn(mockResponse)

        val result = authController.forgotPassword(request)

        assertEquals(HttpStatus.OK, result.statusCode)
        assertEquals(mockResponse, result.body)
    }

    @Test
    @DisplayName("TC06 - Endpoint Verify OTP trả về HTTP 200 khi xác thực OTP thành công")
    fun testVerifyOtp_Success() {
        val request = VerifyOtpRequest("test@example.com", "123456")
        val mockResponse = ApiResponse(true, "Xác thực mã OTP thành công.")

        `when`(authService.verifyOtp(request)).thenReturn(mockResponse)

        val result = authController.verifyOtp(request)

        assertEquals(HttpStatus.OK, result.statusCode)
        assertEquals(mockResponse, result.body)
    }

    @Test
    @DisplayName("TC07 - Endpoint Reset Password trả về HTTP 200 khi đổi mật khẩu thành công")
    fun testResetPassword_Success() {
        val request = ResetPasswordRequest("test@example.com", "new_pass_123")
        val mockResponse = ApiResponse(true, "Đổi mật khẩu thành công.")

        `when`(authService.resetPassword(request)).thenReturn(mockResponse)

        val result = authController.resetPassword(request)

        assertEquals(HttpStatus.OK, result.statusCode)
        assertEquals(mockResponse, result.body)
    }
}
