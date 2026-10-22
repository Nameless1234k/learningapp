package com.learningapp.api.service

import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.auth.*
import com.learningapp.api.entity.PasswordResetOtp
import com.learningapp.api.entity.User
import com.learningapp.api.repository.PasswordResetOtpRepository
import com.learningapp.api.repository.UserRepository
import com.learningapp.api.util.JwtUtil
import org.springframework.mail.SimpleMailMessage
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import java.time.LocalDateTime
import kotlin.random.Random

// =========================================================================================
// [GIẢI THÍCH CHO NGƯỜI HỌC CÓ NỀN TẢNG JAVA / PYTHON]:
//
// 1. @Service là gì?
//    - Trong mô hình MVC (Model-View-Controller) kết hợp Layered Architecture của Spring Boot:
//      Service là tầng trung gian nắm giữ TOÀN BỘ NGHIỆP VỤ (Business Logic).
//    - Controller chỉ nhận yêu cầu và trả về kết quả, còn tính toán, kiểm tra, gọi Database,
//      mã hóa mật khẩu... đều phải nằm ở Service.
//
// 2. Các dependency được Inject vào AuthService:
//    - userRepository: Tương tác với bảng 'users' trong Database.
//    - otpRepository: Tương tác với bảng 'password_reset_otps' trong Database.
//    - passwordEncoder: Công cụ mã hóa 1 chiều BCrypt (giúp bảo mật mật khẩu người dùng).
//    - jwtUtil: Tiện ích tạo và giải mã token JWT (dùng để xác thực phiên đăng nhập).
//    - mailSender: Thư viện gửi email chính thức của Spring Boot (JavaMail).
// =========================================================================================

@Service
class AuthService(
    private val userRepository: UserRepository,
    private val otpRepository: PasswordResetOtpRepository,
    private val passwordEncoder: PasswordEncoder,
    private val jwtUtil: JwtUtil,
    private val mailSender: JavaMailSender
) {

    // Biểu thức chính quy (Regex) kiểm tra định dạng email chuẩn ở phía máy chủ
    private val emailRegex = "^[A-Za-z0-9._%+-]+@gmail\\.com$".toRegex()

    /**
     * CHỨC NĂNG 1: ĐĂNG KÝ TÀI KHOẢN (REGISTER)
     * Các bước:
     * 1. Kiểm tra định dạng email hợp lệ (Regex).
     * 2. Kiểm tra email đã có người đăng ký chưa.
     * 3. Băm mật khẩu bằng BCrypt (không bao giờ lưu mật khẩu gốc dạng plain text).
     * 4. Lưu thông tin User mới vào Database.
     * 5. Tạo JWT Token và trả về thông tin đăng nhập thành công.
     */
    fun register(request: RegisterRequest): AuthResponse {
        val trimmedEmail = request.email.trim()

        // 1. Kiểm tra định dạng email
        if (!emailRegex.matches(trimmedEmail)) {
            throw IllegalArgumentException("Email không đúng định dạng!")
        }

        // 2. Kiểm tra trùng lặp email
        val existingUser = userRepository.findByEmail(trimmedEmail)
        if (existingUser != null) {
            // Ném ngoại lệ (tương tự 'raise ValueError(...)' trong Python)
            throw IllegalArgumentException("Email này đã được sử dụng!")
        }

        // 3. Băm mật khẩu bằng thuật toán BCrypt an toàn
        val encodedPassword = passwordEncoder.encode(request.password)

        // 4. Khởi tạo thực thể User (Entity) để chuẩn bị lưu vào Database (mặc định role = USER)
        val newUser = User(
            firstName = request.firstName,
            lastName = request.lastName,
            email = trimmedEmail,
            phone = request.phone,
            passwordHash = encodedPassword,
            isActive = true,
            role = "USER"
        )
        // Lưu vào cơ sở dữ liệu qua UserRepository
        val savedUser = userRepository.save(newUser)

        // 5. Tạo chuỗi mã JWT Token từ email
        val token = jwtUtil.generateToken(savedUser.email)

        // Trả về đối tượng DTO chứa token và thông tin cá nhân
        return AuthResponse(
            token = token,
            userId = savedUser.id.toString(),
            email = savedUser.email,
            fullName = "${savedUser.lastName} ${savedUser.firstName}",
            role = savedUser.role
        )
    }

    /**
     * CHỨC NĂNG 2: ĐĂNG NHẬP (LOGIN)
     * Các bước:
     * 1. Tìm tài khoản theo email trong Database.
     * 2. Kiểm tra tài khoản có bị khóa không (is_active = false).
     * 3. So khớp mật khẩu người dùng nhập với mật khẩu đã băm (passwordEncoder.matches).
     * 4. Sinh token JWT và trả về thông tin người dùng.
     */
    fun login(request: LoginRequest): AuthResponse {
        // Toán tử elvis ?: trong Kotlin: nếu vế trái null thì thực hiện vế phải (giống 'if not user: raise ...')
        val user = userRepository.findByEmail(request.email.trim())
            ?: throw IllegalArgumentException("Tài khoản hoặc mật khẩu không chính xác!")

        // Kiểm tra trạng thái tài khoản: nếu đã bị admin khóa (is_active = false)
        if (!user.isActive) {
            throw IllegalArgumentException("tài khoản của bạn đã bị khóa vui lòng liên hệ với admin để biết rõ chi tiết")
        }

        // Kiểm tra mật khẩu (hàm matches tự động băm mật khẩu nhập vào và so với hash trong DB)
        if (!passwordEncoder.matches(request.password, user.passwordHash)) {
            throw IllegalArgumentException("Tài khoản hoặc mật khẩu không chính xác!")
        }

        // Tạo JWT Token đăng nhập
        val token = jwtUtil.generateToken(user.email)

        return AuthResponse(
            token = token,
            userId = user.id.toString(),
            email = user.email,
            fullName = "${user.lastName} ${user.firstName}",
            role = user.role
        )
    }

    /**
     * CHỨC NĂNG 3: QUÊN MẬT KHẨU & GỬI OTP (FORGOT PASSWORD)
     * Các bước:
     * 1. Kiểm tra tài khoản có tồn tại trong hệ thống không.
     * 2. Sinh ngẫu nhiên mã số gồm 6 chữ số (từ 100000 đến 999999).
     * 3. Băm mã OTP bằng BCrypt và lưu vào bảng 'password_reset_otps' kèm thời gian hết hạn (1 phút).
     * 4. Gửi mã OTP vào hộp thư email của người dùng.
     */
    fun forgotPassword(request: ForgotPasswordRequest): ApiResponse {
        val trimmedEmail = request.email.trim()
        if (!emailRegex.matches(trimmedEmail)) {
            throw IllegalArgumentException("Email không đúng định dạng!")
        }

        val user = userRepository.findByEmail(trimmedEmail)
            ?: throw IllegalArgumentException("Tài khoản không tồn tại")

        // Sinh mã OTP ngẫu nhiên từ 100000 đến 999999 (tham số until trong Kotlin là độc quyền nên để 1000000)
        val otpCode = Random.nextInt(100000, 1000000).toString()

        // Băm mã OTP trước khi lưu vào DB để chống lộ mã nếu DB bị rò rỉ
        val otpHash = passwordEncoder.encode(otpCode)

        // Thiết lập thời gian hiệu lực là 1 phút kể từ thời điểm hiện tại
        val otp = PasswordResetOtp(
            userId = user.id!!,
            otpHash = otpHash,
            expiresAt = LocalDateTime.now().plusMinutes(1)
        )
        otpRepository.save(otp)

        // Gửi email chứa mã OTP đến người dùng
        try {
            val message = SimpleMailMessage()
            message.setFrom("ngkhanhkk@gmail.com") // Người gửi đã cấu hình trong application.properties
            message.setTo(user.email)
            message.subject = "Mã xác thực quên mật khẩu"
            message.text = "Mã OTP của bạn là: $otpCode. Mã có hiệu lực trong 1 phút."
            mailSender.send(message)
            println("[EMAIL SERVICE]: Đã gửi mã OTP thành công tới: ${user.email}")
        } catch (e: Exception) {
            // Khi môi trường dev không có internet hoặc mail server lỗi, ghi log để dev vẫn lấy được mã test
            println("[EMAIL SERVICE LỖI]: Không gửi được mail: ${e.message}. Mã OTP dự phòng là: $otpCode")
        }

        return ApiResponse(true, "Mã xác thực đã được gửi tới email của bạn.")
    }

    /**
     * CHỨC NĂNG 4: XÁC THỰC MÃ OTP (VERIFY OTP)
     * Các bước:
     * 1. Tìm user theo email.
     * 2. Lấy mã OTP mới nhất được tạo cho user đó.
     * 3. Kiểm tra mã đã dùng chưa, đã hết hạn chưa.
     * 4. So khớp mã người dùng nhập với hash trong DB.
     * 5. Đánh dấu mã OTP là đã sử dụng (isUsed = true).
     */
    fun verifyOtp(request: VerifyOtpRequest): ApiResponse {
        val user = userRepository.findByEmail(request.email.trim())
            ?: throw IllegalArgumentException("Tài khoản không tồn tại")

        // Lấy danh sách OTP của user, sắp xếp mới nhất lên đầu
        val otps = otpRepository.findByUserIdOrderByCreatedAtDesc(user.id!!)
        if (otps.isEmpty()) {
            throw IllegalArgumentException("Không tìm thấy mã xác thực.")
        }
        val latestOtp = otps.first()

        // Kiểm tra nếu mã này đã từng được sử dụng để đổi mật khẩu rồi
        if (latestOtp.isUsed) {
            throw IllegalArgumentException("Mã OTP này đã được sử dụng.")
        }

        // Kiểm tra thời gian hết hạn (sau 1 phút)
        if (LocalDateTime.now().isAfter(latestOtp.expiresAt)) {
            throw IllegalArgumentException("Mã OTP đã hết hạn.")
        }

        // Kiểm tra mã người dùng nhập có khớp với mã được lưu không
        if (!passwordEncoder.matches(request.otp, latestOtp.otpHash)) {
            latestOtp.attemptCount += 1
            otpRepository.save(latestOtp)
            throw IllegalArgumentException("Mã OTP không hợp lệ.")
        }

        // Đánh dấu mã này đã được xác thực thành công
        latestOtp.isUsed = true
        otpRepository.save(latestOtp)

        return ApiResponse(true, "Xác thực mã OTP thành công.")
    }

    /**
     * CHỨC NĂNG 5: ĐẶT LẠI MẬT KHẨU MỚI (RESET PASSWORD)
     * Các bước:
     * 1. Kiểm tra tài khoản có tồn tại không.
     * 2. Kiểm tra xem user có mã OTP nào đã xác thực thành công (isUsed = true) trong 15 phút qua không.
     *    (Chống trường hợp kẻ xấu gọi thẳng API đổi mật khẩu mà bỏ qua bước OTP).
     * 3. Băm mật khẩu mới bằng BCrypt và cập nhật vào Database.
     */
    fun resetPassword(request: ResetPasswordRequest): ApiResponse {
        val user = userRepository.findByEmail(request.email.trim())
            ?: throw IllegalArgumentException("Tài khoản không tồn tại")

        // Tìm OTP đã xác thực thành công trong vòng 15 phút gần nhất
        val otps = otpRepository.findByUserIdOrderByCreatedAtDesc(user.id!!)
        val recentlyVerifiedOtp = otps.find { 
            it.isUsed && it.createdAt.isAfter(LocalDateTime.now().minusMinutes(15))
        }

        if (recentlyVerifiedOtp == null) {
            throw IllegalArgumentException("Yêu cầu không hợp lệ. Vui lòng xác thực mã OTP trước khi đổi mật khẩu.")
        }

        // Cập nhật mật khẩu mới đã băm
        user.passwordHash = passwordEncoder.encode(request.newPassword)
        user.updatedAt = LocalDateTime.now()
        userRepository.save(user)

        // Vô hiệu hóa OTP sau khi đổi mật khẩu thành công để không bị dùng lại
        recentlyVerifiedOtp.expiresAt = LocalDateTime.now().minusMinutes(1)
        otpRepository.save(recentlyVerifiedOtp)

        return ApiResponse(true, "Đổi mật khẩu thành công.")
    }
}