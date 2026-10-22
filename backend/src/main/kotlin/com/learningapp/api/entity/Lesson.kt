package com.learningapp.api.entity

import jakarta.persistence.*
import java.time.LocalDateTime
import java.util.UUID

/**
 * =========================================================================================
 * [TÊN FILE]: Lesson.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/entity/
 * [TẦNG KIẾN TRÚC]: Entity (Thực thể ánh xạ Cơ sở dữ liệu)
 * [BẢNG TƯƠNG ỨNG]: 'lessons' trong PostgreSQL
 *
 * [CHỨC NĂNG CHÍNH]:
 * - Đại diện cho từng bài học cụ thể thuộc một môn học.
 * - Liên kết trực tiếp tới tài liệu PDF qua khóa ngoại 'documentId' (trỏ tới bảng 'documents').
 * - Đã loại bỏ cột 'description' theo yêu cầu tinh gọn cấu trúc database.
 * =========================================================================================
 */
@Entity
@Table(name = "lessons")
data class Lesson(
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    val id: UUID? = null,

    // Khóa ngoại trỏ đến ID của môn học trong bảng 'subjects'
    @Column(name = "subject_id", nullable = false)
    var subjectId: UUID,

    // Khóa ngoại trỏ đến ID của file PDF trong bảng 'documents' (null nếu bài chưa có tài liệu)
    @Column(name = "document_id")
    var documentId: UUID? = null,

    // Số thứ tự bài học (vd: 1, 2, 3...)
    @Column(name = "lesson_no", nullable = false)
    var lessonNo: Int,

    // Tiêu đề/chủ đề chi tiết của bài học (vd: "Khái lược về Triết học...", "Chủ nghĩa duy vật...")
    @Column(name = "title", nullable = false, length = 255)
    var title: String,

    // Thời điểm tạo bài học
    @Column(name = "created_at", nullable = false, updatable = false)
    var createdAt: LocalDateTime = LocalDateTime.now()
)
