package com.learningapp.api.util

import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.util.*
import javax.crypto.SecretKey

/**
 * =========================================================================================
 * [TÊN FILE]: JwtUtil.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/util/
 * [MỤC ĐÍCH]: Xử lý ký số và xác thực JSON Web Token (JWT):
 * - Thời gian sống: Tối đa 24 giờ (86,400,000 ms).
 * - Cơ chế In-Memory Ephemeral Boot Secret:
 *   + Mỗi khi Backend khởi động, một mã phiên chạy ngẫu nhiên (sessionBootSecret) được tạo trong RAM.
 *   + Khi Backend chạy liên tục: Khóa giữ nguyên, JWT duy trì bình thường.
 *   + Khi tắt Backend hoặc Khởi động lại: Khóa RAM biến mất và được sinh mới, lập tức vô hiệu hóa
 *     toàn bộ JWT cũ mà KHÔNG cần tốn bộ nhớ Database/Redis, và KHÔNG gây nặng bộ nhớ cho điện thoại!
 * =========================================================================================
 */
@Component
class JwtUtil {

    // Thời gian hết hạn của Token (mặc định tối đa 24 giờ = 86,400,000 milliseconds)
    @Value("\${app.security.jwt.expiration:86400000}")
    private var expirationMs: Long = 86400000

    // Khóa ký phiên chạy ngẫu nhiên trong bộ nhớ RAM
    private val sessionBootSecret: String = UUID.randomUUID().toString() + UUID.randomUUID().toString()

    // Khởi tạo khóa ký điện tử HMAC-SHA256 từ sessionBootSecret
    private val key: SecretKey by lazy {
        Keys.hmacShaKeyFor(sessionBootSecret.toByteArray())
    }

    /**
     * Hàm sinh JWT Token từ email của người dùng (tối đa 24h)
     */
    fun generateToken(email: String): String {
        val now = Date()
        val expiryDate = Date(now.time + expirationMs)

        return Jwts.builder()
            .subject(email)
            .issuedAt(now)
            .expiration(expiryDate)
            .signWith(key)
            .compact()
    }

    /**
     * Kiểm tra tính hợp lệ của Token:
     * - Trả về false nếu token đã hết hạn (> 24h) hoặc được cấp từ phiên chạy trước của Backend.
     */
    fun validateToken(token: String): Boolean {
        return try {
            val claims = Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .payload
            !claims.expiration.before(Date())
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Trích xuất Email từ Token nếu hợp lệ
     */
    fun extractEmail(token: String): String? {
        return try {
            Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .payload
                .subject
        } catch (e: Exception) {
            null
        }
    }
}
