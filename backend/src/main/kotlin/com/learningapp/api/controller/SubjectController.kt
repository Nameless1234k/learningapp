package com.learningapp.api.controller

import com.learningapp.api.constant.ApiEndpoints
import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.service.SubjectService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.util.UUID

/**
 * =========================================================================================
 * [TÊN FILE]: SubjectController.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/controller/
 * [TẦNG KIẾN TRÚC]: Controller (REST API Controller)
 *
 * [CHỨC NĂNG CHÍNH]:
 * - Tiếp nhận và xử lý các yêu cầu HTTP liên quan đến môn học và danh sách bài học.
 * - Endpoint 1: GET /api/subjects -> Trả về danh sách tất cả môn học kèm % tiến độ của học viên (Screen 9).
 * - Endpoint 2: GET /api/subjects/{id}/lessons -> Trả về danh sách bài học kèm link PDF động từ database (Screen 14).
 *
 * [LIÊN KẾT VỚI]:
 * - SubjectService: Gọi xử lý nghiệp vụ, tổng hợp dữ liệu từ các Repository.
 * - ApiEndpoints: Hằng số chứa định nghĩa URL.
 * - Flutter SubjectService & SubjectController: Gọi HTTP tới các endpoint này.
 * =========================================================================================
 */
@RestController
@RequestMapping(ApiEndpoints.Subjects.BASE)
@CrossOrigin(origins = ["*"])
class SubjectController(
    private val subjectService: SubjectService
) {

    /**
     * API LẤY DANH SÁCH MÔN HỌC VÀ TIẾN ĐỘ
     * Đường dẫn: GET /api/subjects?userId={userId}
     * - userId: Tùy chọn (nếu truyền vào sẽ tính % tiến độ riêng cho user đó)
     */
    @GetMapping
    fun getSubjects(
        @RequestParam(required = false) userId: UUID?
    ): ResponseEntity<*> {
        return try {
            val response = subjectService.getSubjectsWithProgress(userId)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi lấy danh sách môn học"))
        }
    }

    /**
     * API LẤY CHI TIẾT BÀI HỌC CỦA MÔN HỌC
     * Đường dẫn: GET /api/subjects/{id}/lessons?userId={userId}
     * - id: UUID của môn học cần lấy bài học
     * - userId: Tùy chọn để lấy trạng thái bài đã đọc/chưa đọc
     * - Kết quả trả về chứa pdfUrl động lấy trực tiếp từ bảng 'documents'
     */
    @GetMapping(ApiEndpoints.Subjects.GET_LESSONS)
    fun getSubjectLessons(
        @PathVariable id: UUID,
        @RequestParam(required = false) userId: UUID?
    ): ResponseEntity<*> {
        return try {
            val response = subjectService.getSubjectDetail(id, userId)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi lấy chi tiết bài học"))
        }
    }

    /**
     * API TỰ ĐỘNG CẬP NHẬT TIẾN ĐỘ BÀI HỌC (Zero-click khi đọc 30 giây hoặc khi thoát)
     * Đường dẫn: POST /api/subjects/lessons/{lessonId}/progress?userId={userId}
     * - lessonId: UUID bài học đang đọc
     * - userId: UUID học viên
     * - body: UpdateLessonProgressRequest (pageNumber, totalPages, secondsSpent)
     */
    @PostMapping(ApiEndpoints.Subjects.UPDATE_PROGRESS)
    fun updateLessonProgress(
        @PathVariable lessonId: UUID,
        @RequestParam userId: UUID,
        @RequestBody request: com.learningapp.api.dto.subject.UpdateLessonProgressRequest
    ): ResponseEntity<*> {
        return try {
            val response = subjectService.updateLessonProgress(userId, lessonId, request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            ResponseEntity.badRequest().body(ApiResponse(false, e.message ?: "Lỗi cập nhật tiến độ bài học"))
        }
    }
}

