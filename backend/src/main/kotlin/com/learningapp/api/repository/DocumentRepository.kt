package com.learningapp.api.repository

import com.learningapp.api.entity.Document
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.UUID

/**
 * =========================================================================================
 * [TÊN FILE]: DocumentRepository.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/repository/
 * [TẦNG KIẾN TRÚC]: Data Access Layer (Repository / JPA DAO)
 *
 * [CHỨC NĂNG CHÍNH]:
 * - Cung cấp các thao tác truy vấn (CRUD: Thêm, Xem, Sửa, Xóa) dữ liệu bảng 'documents'.
 * - Kế thừa JpaRepository của Spring Data để có sẵn các hàm findById, save, delete...
 *
 * [MỐI LIÊN KẾT]:
 * - Document.kt: Thực thể dữ liệu thao tác.
 * - SubjectService.kt: Được gọi để truy vấn lấy thông tin file PDF của bài học.
 * =========================================================================================
 */
@Repository
interface DocumentRepository : JpaRepository<Document, UUID> {

    /**
     * Tìm tất cả tài liệu thuộc về một môn học cụ thể
     */
    fun findBySubjectId(subjectId: UUID): List<Document>

    /**
     * Tìm tài liệu theo tên file
     */
    fun findByFileName(fileName: String): Document?
}
