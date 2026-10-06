package com.learningapp.api.repository

import com.learningapp.api.entity.PasswordResetOtp
import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

/**
 * =========================================================================================
 * [GIẢI THÍCH DÀNH CHO NGƯỜI HỌC CÓ NỀN TẢNG JAVA / PYTHON]:
 *
 * Repository quản lý bảng 'password_reset_otps':
 * - Kế thừa JpaRepository để thừa hưởng các thao tác CRUD (Create, Read, Update, Delete).
 * - Hàm "findByUserIdOrderByCreatedAtDesc(userId)" được Spring Data JPA tự động dịch thành câu lệnh:
 *   "SELECT * FROM password_reset_otps WHERE user_id = ? ORDER BY created_at DESC"
 * - Giúp lấy danh sách OTP của user và xếp bản ghi vừa tạo mới nhất lên đầu danh sách!
 * =========================================================================================
 */
interface PasswordResetOtpRepository : JpaRepository<PasswordResetOtp, UUID> {
    // Lấy danh sách các mã OTP của người dùng theo userId, sắp xếp giảm dần theo thời gian tạo
    fun findByUserIdOrderByCreatedAtDesc(userId: UUID): List<PasswordResetOtp>
}
