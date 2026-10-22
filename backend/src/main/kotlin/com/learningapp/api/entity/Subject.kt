package com.learningapp.api.entity

import jakarta.persistence.*
import java.time.LocalDateTime
import java.util.UUID

/**
 * =========================================================================================
 * [TÊN FILE]: Subject.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/entity/
 * [TẦNG KIẾN TRÚC]: Entity (Thực thể ánh xạ Cơ sở dữ liệu)
 * [BẢNG TƯƠNG ỨNG]: 'subjects' trong PostgreSQL
 *
 * [CHỨC NĂNG CHÍNH]:
 * - Đại diện cho danh mục các môn học chính trị (Triết học, KTCT, CNXHKH...).
 * - Đã lược bỏ cột 'description' theo yêu cầu tinh gọn cấu trúc database.
 * =========================================================================================
 */
@Entity
@Table(name = "subjects")
data class Subject(
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    val id: UUID? = null,

    // Mã định danh ngắn của môn học (duy nhất: TRIET_HOC, CNXHKH, KTCT...)
    @Column(name = "code", nullable = false, unique = true, length = 30)
    var code: String,

    // Tên hiển thị đầy đủ của môn học (vd: "Triết học Mác - Lênin")
    @Column(name = "name", nullable = false, length = 200)
    var name: String,

    // Thứ tự hiển thị môn học trong danh sách
    @Column(name = "display_order", nullable = false)
    var displayOrder: Int = 0,

    // Thời điểm tạo môn học trong hệ thống
    @Column(name = "created_at", nullable = false, updatable = false)
    var createdAt: LocalDateTime = LocalDateTime.now()
)
