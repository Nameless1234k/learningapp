package com.learningapp.api.entity

import jakarta.persistence.*
import java.time.LocalDateTime
import java.util.UUID

/**
 * =========================================================================================
 * [TÊN FILE]: Document.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/entity/
 * [TẦNG KIẾN TRÚC]: Entity (Thực thể ánh xạ Cơ sở dữ liệu)
 * [BẢNG TƯƠNG ỨNG]: 'documents' trong PostgreSQL
 *
 * [CHỨC NĂNG CHÍNH]:
 * - Lưu trữ thông tin tài liệu / giáo trình dạng file PDF.
 * - KHÔNG lưu nội dung nhị phân (BLOB) của file để tránh nặng database.
 * - Chỉ lưu đường dẫn tải file ('file_path') và siêu dữ liệu (tên file, số trang, trạng thái).
 * - Đã loại bỏ cột 'title' để tránh nhầm lẫn với cột 'title' của bảng 'lessons' (chỉ lessons quản lý tiêu đề bài học).
 * - Đã lược bỏ cột 'version' theo yêu cầu tinh gọn cấu trúc database.
 *
 * [MỐI LIÊN KẾT]:
 * - N-1 với Subject: Mỗi tài liệu thuộc về một môn học cụ thể (subject_id).
 * - 1-1 hoặc 1-N với Lesson: Mỗi bài học (Lesson) trỏ tới tài liệu tương ứng qua (document_id).
 * =========================================================================================
 */
@Entity
@Table(name = "documents")
data class Document(
    // Khóa chính: UUID định danh duy nhất cho tài liệu, tự sinh khi thêm mới
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    val id: UUID? = null,

    // Khóa ngoại trỏ đến ID của môn học trong bảng 'subjects'
    @Column(name = "subject_id", nullable = false)
    var subjectId: UUID,

    // Tên file gốc vật lý (ví dụ: "BÀI 1-ĐỀ CƯƠNG BÀI GIẢNG.pdf")
    @Column(name = "file_name", nullable = false, length = 255)
    var fileName: String,

    // Đường dẫn tải file được phục vụ qua API (ví dụ: "/api/documents/files/chủ nghĩa xã hội khoa học/...")
    @Column(name = "file_path", columnDefinition = "TEXT")
    var filePath: String? = null,

    // Thời điểm tải lên hệ thống
    @Column(name = "created_at", nullable = false, updatable = false)
    var createdAt: LocalDateTime = LocalDateTime.now(),

    // Thời điểm chỉnh sửa cập nhật tài liệu gần nhất
    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now()
)
