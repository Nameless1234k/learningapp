package com.learningapp.api.util

import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.util.*
import javax.crypto.SecretKey

/**
 * =========================================================================================
 * [GIẢI THÍCH DÀNH CHO NGƯỜI HỌC CÓ NỀN TẢNG JAVA / PYTHON]:
 *
 * 1. @Component là gì?
 *    - Trong Spring Boot, @Component là annotation đánh dấu class này là một thành phần do Spring quản lý.
 *    - Bất kỳ Service nào cần dùng chỉ cần khai báo trong constructor là Spring sẽ tự inject vào.
 *
 * 2. @Value("\${...}") là gì?
 *    - Giống như os.environ.get(...) trong Python.
 *    - Nó đọc giá trị cấu hình từ file 'application.properties' (như mã bí mật jwt.secret, thời gian sống).
 *
 * 3. JWT (JSON Web Token) là gì?
 *    - Một chuỗi mã hóa gồm 3 phần: Header.Payload.Signature.
 *    - Khi đăng nhập thành công, Server ký chuỗi này bằng mã bí mật (secret key) rồi gửi về cho Flutter.
 *    - Khi Flutter gửi token này lên ở các request sau, Server chỉ cần kiểm tra chữ ký là biết user là ai
 *      mà không cần phải tra cứu lại mật khẩu trong DB.
 * =========================================================================================
 */
@Component
class JwtUtil {

    // Đọc chuỗi khóa bí mật từ application.properties
    @Value("\${app.security.jwt.secret}")
    private lateinit var secret: String

    // Thời gian hết hạn của Token (mặc định 86,400,000 milliseconds = 24 giờ)
    @Value("\${app.security.jwt.expiration}")
    private var expirationMs: Long = 86400000

    // Khởi tạo khóa ký điện tử HMAC-SHA (lazy: chỉ khởi tạo lần đầu khi có hàm gọi đến nó)
    private val key: SecretKey by lazy {
        Keys.hmacShaKeyFor(secret.toByteArray())
    }

    /**
     * Hàm sinh JWT Token từ email của người dùng
     *
     * @param email: Định danh của tài khoản
     * @return Chuỗi token đã được ký bảo mật
     */
    fun generateToken(email: String): String {
        val now = Date() // Thời điểm cấp token
        val expiryDate = Date(now.time + expirationMs) // Thời điểm token hết hạn

        return Jwts.builder()
            .subject(email) // Lưu email vào phần payload
            .issuedAt(now) // Ngày phát hành
            .expiration(expiryDate) // Ngày hết hạn
            .signWith(key) // Ký điện tử bằng Secret Key
            .compact() // Đóng gói thành chuỗi String base64url
    }
}
