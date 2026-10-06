package com.learningapp.api.entity

import jakarta.persistence.*
import java.time.LocalDateTime
import java.util.UUID

/**
 * =========================================================================================
 * [GIẢI THÍCH DÀNH CHO NGƯỜI HỌC CÓ NỀN TẢNG JAVA / PYTHON]:
 *
 * Thực thể PasswordResetOtp:
 * - Đại diện cho bảng 'password_reset_otps' trong cơ sở dữ liệu.
 * - Lưu trữ lịch sử các mã xác thực OTP dùng để khôi phục mật khẩu.
 * - Mỗi bản ghi liên kết với một User (qua user_id), lưu mã OTP đã băm, thời gian hết hạn,
 *   trạng thái đã sử dụng (is_used) và số lần thử sai (attempt_count).
 * =========================================================================================
 */
@Entity
@Table(name = "password_reset_otps")
data class PasswordResetOtp(
    // Khóa chính: UUID tự sinh ngẫu nhiên
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    val id: UUID? = null,

    // Khóa ngoại liên kết tới người dùng (UUID của User trong bảng users)
    @Column(name = "user_id", nullable = false)
    val userId: UUID,

    // Mã OTP đã được băm (BCrypt Hash), đảm bảo an toàn tuyệt đối
    @Column(name = "otp_hash", nullable = false)
    var otpHash: String,

    // Đánh dấu mã này đã được dùng để xác thực chưa (true = đã dùng, không cho dùng lại)
    @Column(name = "is_used", nullable = false)
    var isUsed: Boolean = false,

    // Đếm số lần người dùng nhập sai mã (dùng để chặn brute-force nếu vượt quá ngưỡng)
    @Column(name = "attempt_count", nullable = false)
    var attemptCount: Int = 0,

    // Thời điểm mã hết hạn (thường là 1 phút sau khi tạo)
    @Column(name = "expires_at", nullable = false)
    var expiresAt: LocalDateTime,

    // Thời điểm tạo mã trong Database
    @Column(name = "created_at", nullable = false, updatable = false)
    var createdAt: LocalDateTime = LocalDateTime.now()
)
