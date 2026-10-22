package com.learningapp.api.service

import com.learningapp.api.dto.auth.*
import com.learningapp.api.entity.PasswordResetOtp
import com.learningapp.api.entity.User
import com.learningapp.api.repository.PasswordResetOtpRepository
import com.learningapp.api.repository.UserRepository
import com.learningapp.api.util.JwtUtil
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.anyString
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.mail.SimpleMailMessage
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.security.crypto.password.PasswordEncoder
import java.time.LocalDateTime
import java.util.UUID

/**
 * =========================================================================================
 * [GIẢI THÍCH CHO NGƯỜI HỌC CÓ NỀN TẢNG JAVA / PYTHON]:
 *
 * 1. @ExtendWith(MockitoExtension::class):
 *    - Trong Java JUnit 5: Tương tự như @RunWith(MockitoJUnitRunner.class) trong JUnit 4.
 *    - Mục đích: Khởi tạo các đối tượng giả lập (Mock) được đánh dấu @Mock.
 *
 * 2. Mocking là gì?
 *    - Giống unittest.mock (MagicMock) trong Python hoặc Mockito trong Java.
 *    - Khi test Service, ta không muốn gọi trực tiếp Database thật hay Mail Server thật.
 *    - Ta tạo các "Mock" đại diện cho Database và Mail, quy định trước kết quả trả về khi hàm được gọi.
 * =========================================================================================
 */
@ExtendWith(MockitoExtension::class)
class AuthServiceTest {

    // [MOCK CÁC DEPENDENCY]: Tạo các đối tượng giả lập, không kết nối Database hay Network thật
    @Mock
    private lateinit var userRepository: UserRepository

    @Mock
    private lateinit var otpRepository: PasswordResetOtpRepository

    @Mock
    private lateinit var passwordEncoder: PasswordEncoder

    @Mock
    private lateinit var jwtUtil: JwtUtil

    @Mock
    private lateinit var mailSender: JavaMailSender

    // [@InjectMocks]: Tự động tiêm (inject) các mock ở trên vào AuthService để kiểm thử logic
    @InjectMocks
    private lateinit var authService: AuthService

    // Biến mẫu dùng chung cho các bài test
    private lateinit var sampleUser: User
    private val userId: UUID = UUID.randomUUID()

    /**
     * [@BeforeEach]: Hàm này chạy TRƯỚC MỖI bài test (tương tự setUp() trong Python unittest).
     * Dùng để khởi tạo lại dữ liệu ban đầu cho sạch sẽ, không ảnh hưởng giữa các test case.
     */
    @BeforeEach
    fun setUp() {
        sampleUser = User(
            id = userId,
            firstName = "Van A",
            lastName = "Nguyen",
            email = "test@gmail.com",
            phone = "0123456789",
            passwordHash = "hashed_password_123"
        )
    }

    // =====================================================================================
    // NHÓM TEST CASE 1: ĐĂNG KÝ TÀI KHOẢN (REGISTER)
    // =====================================================================================

    @Test
    @DisplayName("TC01 - Đăng ký thành công khi email chưa tồn tại trong hệ thống")
    fun testRegister_Success() {
        // 1. Arrange (Chuẩn bị dữ liệu đầu vào)
        val request = RegisterRequest(
            firstName = "Van A",
            lastName = "Nguyen",
            email = "test@gmail.com",
            phone = "0123456789",
            password = "Password@123"
        )

        // Quy định hành vi của Mock (trong Python: mock_user_repo.findByEmail.return_value = None)
        `when`(userRepository.findByEmail(request.email)).thenReturn(null)
        `when`(passwordEncoder.encode(request.password)).thenReturn("hashed_password_123")
        `when`(userRepository.save(any(User::class.java))).thenReturn(sampleUser)
        `when`(jwtUtil.generateToken(sampleUser.email)).thenReturn("mocked_jwt_token")

        // 2. Act (Thực thi hàm cần test trong Service)
        val response = authService.register(request)

        // 3. Assert (Kiểm tra kết quả - giống assert trong Python / Java)
        assertNotNull(response) // Kết quả trả về không được null
        assertEquals("mocked_jwt_token", response.token) // Token phải khớp với mã giả lập
        assertEquals("test@gmail.com", response.email) // Email khớp với user
        assertEquals("Nguyen Van A", response.fullName) // Họ tên ghép đúng định dạng

        // Verify: Đảm bảo hàm save vào DB đã được gọi đúng 1 lần
        verify(userRepository, times(1)).save(any(User::class.java))
    }

    @Test
    @DisplayName("TC02 - Đăng ký thất bại khi email đã được đăng ký trước đó")
    fun testRegister_DuplicateEmail_ThrowsException() {
        // 1. Arrange: Chuẩn bị email đã tồn tại trong DB
        val request = RegisterRequest(
            firstName = "Van B",
            lastName = "Tran",
            email = "test@gmail.com",
            phone = null,
            password = "Password@123"
        )
        // Khi tìm email trong DB thì trả về sampleUser (đã có sẵn)
        `when`(userRepository.findByEmail(request.email)).thenReturn(sampleUser)

        // 2 & 3. Act & Assert: Kỳ vọng hàm quăng ra ngoại lệ IllegalArgumentException
        val exception = assertThrows(IllegalArgumentException::class.java) {
            authService.register(request)
        }

        // Kiểm tra thông điệp lỗi tiếng Việt thông báo đúng
        assertEquals("Email này đã được sử dụng!", exception.message)

        // Đảm bảo không có lệnh save nào được lưu vào DB
        verify(userRepository, never()).save(any(User::class.java))
    }

    @Test
    @DisplayName("TC02B - Đăng ký thất bại khi định dạng email sai (ví dụ: @gmailcom, @mail.com, user@gmailcom)")
    fun testRegister_InvalidEmail_ThrowsException() {
        val invalidEmails = listOf("@gmailcom", "@mail.com", "user@gmailcom", "user@", "plain_text")

        for (invalidEmail in invalidEmails) {
            val request = RegisterRequest(
                firstName = "Van A",
                lastName = "Nguyen",
                email = invalidEmail,
                phone = null,
                password = "Password@123"
            )

            val exception = assertThrows(IllegalArgumentException::class.java) {
                authService.register(request)
            }
            assertEquals("Email không đúng định dạng!", exception.message)
        }

        // Đảm bảo không bao giờ lưu user có email sai vào DB
        verify(userRepository, never()).save(any(User::class.java))
    }

    // =====================================================================================
    // NHÓM TEST CASE 2: ĐĂNG NHẬP (LOGIN)
    // =====================================================================================

    @Test
    @DisplayName("TC03 - Đăng nhập thành công với email và mật khẩu chính xác")
    fun testLogin_Success() {
        val request = LoginRequest(email = "test@gmail.com", password = "Password@123")

        // Mock tìm thấy user và mật khẩu khớp BCrypt
        `when`(userRepository.findByEmail(request.email)).thenReturn(sampleUser)
        `when`(passwordEncoder.matches("Password@123", "hashed_password_123")).thenReturn(true)
        `when`(jwtUtil.generateToken(sampleUser.email)).thenReturn("jwt_login_token")

        val response = authService.login(request)

        assertNotNull(response)
        assertEquals("jwt_login_token", response.token)
        assertEquals(userId.toString(), response.userId)
    }

    @Test
    @DisplayName("TC04 - Đăng nhập thất bại khi sai mật khẩu")
    fun testLogin_WrongPassword_ThrowsException() {
        val request = LoginRequest(email = "test@gmail.com", password = "WrongPassword")

        `when`(userRepository.findByEmail(request.email)).thenReturn(sampleUser)
        // Mock mật khẩu không khớp
        `when`(passwordEncoder.matches("WrongPassword", "hashed_password_123")).thenReturn(false)

        val exception = assertThrows(IllegalArgumentException::class.java) {
            authService.login(request)
        }
        assertEquals("Tài khoản hoặc mật khẩu không chính xác!", exception.message)
    }

    @Test
    @DisplayName("TC04B - Đăng nhập thất bại khi tài khoản bị khóa (is_active = false)")
    fun testLogin_UserInactive_ThrowsException() {
        val inactiveUser = sampleUser.copy(isActive = false)
        val request = LoginRequest(email = "test@gmail.com", password = "Password@123")

        `when`(userRepository.findByEmail(request.email)).thenReturn(inactiveUser)

        val exception = assertThrows(IllegalArgumentException::class.java) {
            authService.login(request)
        }
        assertEquals("tài khoản của bạn đã bị khóa vui lòng liên hệ với admin để biết rõ chi tiết", exception.message)
    }

    @Test
    @DisplayName("TC05 - Đăng nhập thất bại khi tài khoản email không tồn tại")
    fun testLogin_UserNotFound_ThrowsException() {
        val request = LoginRequest(email = "notfound@gmail.com", password = "Password@123")

        // Mock tìm không thấy user trong DB
        `when`(userRepository.findByEmail("notfound@gmail.com")).thenReturn(null)

        val exception = assertThrows(IllegalArgumentException::class.java) {
            authService.login(request)
        }
        assertEquals("Tài khoản hoặc mật khẩu không chính xác!", exception.message)
    }

    // =====================================================================================
    // NHÓM TEST CASE 3: QUÊN MẬT KHẨU & GỬI OTP (FORGOT PASSWORD)
    // =====================================================================================

    @Test
    @DisplayName("TC06 - Gửi mã OTP thành công khi email tồn tại trong hệ thống")
    fun testForgotPassword_Success() {
        val request = ForgotPasswordRequest(email = "test@gmail.com")

        `when`(userRepository.findByEmail(request.email)).thenReturn(sampleUser)
        `when`(passwordEncoder.encode(anyString())).thenReturn("hashed_otp")
        `when`(otpRepository.save(any(PasswordResetOtp::class.java))).thenAnswer { it.arguments[0] }
        doNothing().`when`(mailSender).send(any(SimpleMailMessage::class.java))

        val response = authService.forgotPassword(request)

        assertTrue(response.success) // success phải là true
        assertEquals("Mã xác thực đã được gửi tới email của bạn.", response.message)

        // Đảm bảo mã OTP được lưu vào Database
        verify(otpRepository, times(1)).save(any(PasswordResetOtp::class.java))
    }

    @Test
    @DisplayName("TC07 - Gửi mã OTP thất bại khi email không tồn tại")
    fun testForgotPassword_UserNotFound_ThrowsException() {
        val request = ForgotPasswordRequest(email = "nonexistent@gmail.com")
        `when`(userRepository.findByEmail(request.email)).thenReturn(null)

        val exception = assertThrows(IllegalArgumentException::class.java) {
            authService.forgotPassword(request)
        }
        assertEquals("Tài khoản không tồn tại", exception.message)
    }

    // =====================================================================================
    // NHÓM TEST CASE 4: XÁC THỰC MÃ OTP (VERIFY OTP)
    // =====================================================================================

    @Test
    @DisplayName("TC08 - Xác thực OTP thành công khi mã đúng và còn hạn")
    fun testVerifyOtp_Success() {
        val request = VerifyOtpRequest(email = "test@gmail.com", otp = "123456")

        // Tạo đối tượng OTP hợp lệ (còn hạn 1 phút, chưa dùng)
        val validOtp = PasswordResetOtp(
            id = UUID.randomUUID(),
            userId = userId,
            otpHash = "hashed_123456",
            isUsed = false,
            attemptCount = 0,
            expiresAt = LocalDateTime.now().plusMinutes(1)
        )

        `when`(userRepository.findByEmail(request.email)).thenReturn(sampleUser)
        `when`(otpRepository.findByUserIdOrderByCreatedAtDesc(userId)).thenReturn(listOf(validOtp))
        `when`(passwordEncoder.matches("123456", "hashed_123456")).thenReturn(true)

        val response = authService.verifyOtp(request)

        assertTrue(response.success)
        assertEquals("Xác thực mã OTP thành công.", response.message)
        assertTrue(validOtp.isUsed) // Sau khi xác thực, OTP phải được chuyển cờ isUsed = true

        verify(otpRepository, times(1)).save(validOtp)
    }

    @Test
    @DisplayName("TC09 - Xác thực OTP thất bại khi nhập sai mã")
    fun testVerifyOtp_WrongCode_ThrowsException() {
        val request = VerifyOtpRequest(email = "test@gmail.com", otp = "999999")

        val validOtp = PasswordResetOtp(
            id = UUID.randomUUID(),
            userId = userId,
            otpHash = "hashed_123456",
            isUsed = false,
            attemptCount = 0,
            expiresAt = LocalDateTime.now().plusMinutes(1)
        )

        `when`(userRepository.findByEmail(request.email)).thenReturn(sampleUser)
        `when`(otpRepository.findByUserIdOrderByCreatedAtDesc(userId)).thenReturn(listOf(validOtp))
        `when`(passwordEncoder.matches("999999", "hashed_123456")).thenReturn(false)

        val exception = assertThrows(IllegalArgumentException::class.java) {
            authService.verifyOtp(request)
        }
        assertEquals("Mã OTP không hợp lệ.", exception.message)
        assertEquals(1, validOtp.attemptCount) // Số lần thử sai tăng lên 1
    }

    @Test
    @DisplayName("TC10 - Xác thực OTP thất bại khi mã đã hết hạn")
    fun testVerifyOtp_Expired_ThrowsException() {
        val request = VerifyOtpRequest(email = "test@gmail.com", otp = "123456")

        // Tạo OTP đã hết hạn từ 5 phút trước
        val expiredOtp = PasswordResetOtp(
            id = UUID.randomUUID(),
            userId = userId,
            otpHash = "hashed_123456",
            isUsed = false,
            attemptCount = 0,
            expiresAt = LocalDateTime.now().minusMinutes(5)
        )

        `when`(userRepository.findByEmail(request.email)).thenReturn(sampleUser)
        `when`(otpRepository.findByUserIdOrderByCreatedAtDesc(userId)).thenReturn(listOf(expiredOtp))

        val exception = assertThrows(IllegalArgumentException::class.java) {
            authService.verifyOtp(request)
        }
        assertEquals("Mã OTP đã hết hạn.", exception.message)
    }

    // =====================================================================================
    // NHÓM TEST CASE 5: ĐẶT LẠI MẬT KHẨU (RESET PASSWORD)
    // =====================================================================================

    @Test
    @DisplayName("TC11 - Đổi mật khẩu thành công sau khi mã OTP đã được xác thực hợp lệ")
    fun testResetPassword_Success() {
        val request = ResetPasswordRequest(email = "test@gmail.com", newPassword = "NewPassword@123")

        // OTP đã được verify thành công (isUsed = true) cách đây 2 phút
        val verifiedOtp = PasswordResetOtp(
            id = UUID.randomUUID(),
            userId = userId,
            otpHash = "hashed_123456",
            isUsed = true,
            expiresAt = LocalDateTime.now().plusMinutes(1),
            createdAt = LocalDateTime.now().minusMinutes(2)
        )

        `when`(userRepository.findByEmail(request.email)).thenReturn(sampleUser)
        `when`(otpRepository.findByUserIdOrderByCreatedAtDesc(userId)).thenReturn(listOf(verifiedOtp))
        `when`(passwordEncoder.encode("NewPassword@123")).thenReturn("new_hashed_password")

        val response = authService.resetPassword(request)

        assertTrue(response.success)
        assertEquals("Đổi mật khẩu thành công.", response.message)
        assertEquals("new_hashed_password", sampleUser.passwordHash)

        verify(userRepository, times(1)).save(sampleUser)
    }

    @Test
    @DisplayName("TC12 - Đổi mật khẩu thất bại khi chưa xác thực mã OTP trước đó")
    fun testResetPassword_WithoutVerifiedOtp_ThrowsException() {
        val request = ResetPasswordRequest(email = "test@gmail.com", newPassword = "NewPassword@123")

        // Danh sách OTP rỗng hoặc chưa từng xác thực thành công
        `when`(userRepository.findByEmail(request.email)).thenReturn(sampleUser)
        `when`(otpRepository.findByUserIdOrderByCreatedAtDesc(userId)).thenReturn(emptyList())

        val exception = assertThrows(IllegalArgumentException::class.java) {
            authService.resetPassword(request)
        }
        assertEquals("Yêu cầu không hợp lệ. Vui lòng xác thực mã OTP trước khi đổi mật khẩu.", exception.message)
    }
}
