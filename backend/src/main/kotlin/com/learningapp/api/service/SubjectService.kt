package com.learningapp.api.service

import com.learningapp.api.dto.subject.*
import com.learningapp.api.entity.UserLessonProgress
import com.learningapp.api.repository.DocumentRepository
import com.learningapp.api.repository.LessonRepository
import com.learningapp.api.repository.SubjectRepository
import com.learningapp.api.repository.UserLessonProgressRepository
import org.springframework.stereotype.Service
import java.math.BigDecimal
import java.time.LocalDateTime
import java.util.UUID

/**
 * =========================================================================================
 * [TÊN FILE]: SubjectService.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/service/
 * [TẦNG KIẾN TRÚC]: Business Logic Layer (Tầng xử lý nghiệp vụ - Pattern MVC)
 *
 * [CHỨC NĂNG CHÍNH]:
 * - Xử lý nghiệp vụ hiển thị danh sách môn học và tiến độ hoàn thành của học viên.
 * - Xử lý chi tiết bài học thuộc môn và liên kết động tới tài liệu PDF từ bảng 'documents'.
 * - Tự động cập nhật số trang total_pages vào documents khi học viên đọc PDF.
 * - Tự động tính phần trăm tiến độ bài học dựa trên last_position và total_pages.
 * =========================================================================================
 */
@Service
class SubjectService(
    private val subjectRepository: SubjectRepository,
    private val lessonRepository: LessonRepository,
    private val documentRepository: DocumentRepository,
    private val userLessonProgressRepository: UserLessonProgressRepository
) {
    companion object {
        /**
         * [NGƯỠNG THỜI GIAN TỰ ĐỘNG HOÀN THÀNH BÀI HỌC]:
         * Số giây tối thiểu học viên cần đọc để hệ thống tự động ghi nhận là "ĐÃ ĐỌC" (COMPLETED).
         */
        const val COMPLETION_READING_THRESHOLD_SECONDS = 60
    }

    /**
     * LẤY DANH SÁCH MÔN HỌC KÈM TIẾN ĐỘ HỌC CỦA NGƯỜI DÙNG (Dành cho Screen 9)
     */
    fun getSubjectsWithProgress(userId: UUID?): SubjectListResponse {
        val subjects = subjectRepository.findAllByOrderByDisplayOrderAsc()
        if (subjects.isEmpty()) {
            return SubjectListResponse(totalSubjects = 0, readSubjects = 0, subjects = emptyList())
        }

        val userProgressMap = if (userId != null) {
            userLessonProgressRepository.findByUserId(userId).associateBy { it.lessonId }
        } else {
            emptyMap()
        }

        var readSubjectsCount = 0

        val subjectResponses = subjects.map { subject ->
            val lessons = lessonRepository.findBySubjectIdOrderByLessonNoAsc(subject.id!!)
            val totalLessons = lessons.size

            var completedLessons = 0
            var hasReadAny = false
            var nextLessonTitle: String? = null

            for (lesson in lessons) {
                val progress = userProgressMap[lesson.id]
                val isCompleted = progress?.status == "COMPLETED" || (progress != null && progress.progressPercent.toDouble() >= 100.0)
                val isStarted = progress != null && progress.status != "NOT_STARTED"

                if (isCompleted) {
                    completedLessons++
                    hasReadAny = true
                } else if (isStarted) {
                    hasReadAny = true
                    if (nextLessonTitle == null) {
                        nextLessonTitle = "Bài ${lesson.lessonNo}-${lesson.title}"
                    }
                } else {
                    if (nextLessonTitle == null) {
                        nextLessonTitle = "Bài ${lesson.lessonNo}-${lesson.title}"
                    }
                }
            }

            if (hasReadAny) {
                readSubjectsCount++
            }

            val progressPercent = if (totalLessons > 0) {
                (completedLessons.toDouble() / totalLessons) * 100.0
            } else {
                0.0
            }

            SubjectProgressResponse(
                id = subject.id.toString(),
                code = subject.code,
                name = subject.name,
                progressPercent = Math.round(progressPercent * 10.0) / 10.0,
                nextLesson = nextLessonTitle?.let { "Bài tiếp theo: $it" },
                totalLessons = totalLessons,
                completedLessons = completedLessons
            )
        }

        return SubjectListResponse(
            totalSubjects = subjects.size,
            readSubjects = readSubjectsCount,
            subjects = subjectResponses
        )
    }

    /**
     * LẤY CHI TIẾT MÔN HỌC VÀ CÁC BÀI HỌC
     */
    fun getSubjectDetail(subjectId: UUID, userId: UUID?): SubjectDetailResponse {
        val subject = subjectRepository.findById(subjectId).orElseThrow {
            IllegalArgumentException("Môn học không tồn tại trong hệ thống!")
        }

        val lessons = lessonRepository.findBySubjectIdOrderByLessonNoAsc(subjectId)
        val userProgressMap = if (userId != null) {
            userLessonProgressRepository.findByUserId(userId).associateBy { it.lessonId }
        } else {
            emptyMap()
        }

        var completedCount = 0

        val lessonResponses = lessons.map { lesson ->
            val progress = userProgressMap[lesson.id]
            val isCompleted = progress?.status == "COMPLETED" || (progress != null && progress.progressPercent.toDouble() >= 100.0)
            if (isCompleted) {
                completedCount++
            }

            val status = progress?.status ?: "NOT_STARTED"

            val pdfUrl = lesson.documentId?.let { docId ->
                val doc = documentRepository.findById(docId).orElse(null)
                if (doc != null) "/api/documents/$docId/file" else null
            }

            val readingSeconds = progress?.readingTimeSeconds ?: 0
            val readingMinutes = if (readingSeconds > 0) Math.max(1, (readingSeconds + 30) / 60) else 0
            val lastPosition = progress?.lastPosition ?: 1

            LessonItemResponse(
                id = lesson.id.toString(),
                lessonNo = lesson.lessonNo,
                title = lesson.title,
                estimatedMinutes = 0,
                status = status,
                isRead = isCompleted,
                pdfUrl = pdfUrl,
                readingMinutes = readingMinutes,
                readingSeconds = readingSeconds,
                lastPosition = lastPosition
            )
        }

        val progressPercent = if (lessons.isNotEmpty()) {
            Math.round((completedCount.toDouble() / lessons.size * 100.0) * 10.0) / 10.0
        } else {
            0.0
        }

        return SubjectDetailResponse(
            subjectId = subject.id.toString(),
            subjectName = subject.name,
            totalLessons = lessons.size,
            progressPercent = progressPercent,
            lessons = lessonResponses
        )
    }

    /**
     * TỰ ĐỘNG CẬP NHẬT TIẾN ĐỘ BÀI HỌC VÀ TIẾN ĐỘ MÔN HỌC (Zero-click)
     * - Tự động cập nhật tổng số trang PDF vào documents nếu chưa có.
     * - Tính toán % theo: (last_position / total_pages) * 100.
     * - Khi đạt >= 60s hoặc lướt tới trang cuối -> COMPLETED (100%).
     */
    fun updateLessonProgress(
        userId: UUID,
        lessonId: UUID,
        request: UpdateLessonProgressRequest
    ): LessonProgressResponse {
        val lesson = lessonRepository.findById(lessonId).orElseThrow {
            IllegalArgumentException("Bài học không tồn tại trong hệ thống!")
        }

        val existing = userLessonProgressRepository.findByUserIdAndLessonId(userId, lessonId)
        val progress = existing ?: UserLessonProgress(
            userId = userId,
            lessonId = lessonId,
            status = "NOT_STARTED",
            lastPosition = 1,
            progressPercent = BigDecimal.ZERO,
            readingTimeSeconds = 0
        )

        // Tự động lưu total_pages vào bảng documents nếu DB chưa có
        if (lesson.documentId != null && request.totalPages > 0) {
            val doc = documentRepository.findById(lesson.documentId!!).orElse(null)
            if (doc != null && (doc.totalPages == null || doc.totalPages == 0)) {
                doc.totalPages = request.totalPages
                documentRepository.save(doc)
            }
        }

        // 1. Cập nhật vị trí trang: Giữ trang đọc lớn nhất từng đạt được
        if (request.pageNumber > 0) {
            progress.lastPosition = Math.max(progress.lastPosition, request.pageNumber)
        }
        progress.lastReadAt = LocalDateTime.now()

        // 2. Cập nhật thời gian đọc
        if (request.durationSeconds != null && request.durationSeconds > 0) {
            progress.readingTimeSeconds += request.durationSeconds
        } else if (request.secondsSpent > 0) {
            progress.readingTimeSeconds = Math.max(progress.readingTimeSeconds, request.secondsSpent)
        }

        // Điều kiện tự động hoàn thành bài học:
        val isAlreadyCompleted = progress.status == "COMPLETED" || progress.progressPercent.toDouble() >= 100.0
        val isReachedThreshold = progress.readingTimeSeconds >= COMPLETION_READING_THRESHOLD_SECONDS || 
                                 request.secondsSpent >= COMPLETION_READING_THRESHOLD_SECONDS
        val isReachedLastPage = request.totalPages > 0 && 
                               (request.pageNumber >= request.totalPages || progress.lastPosition >= request.totalPages)

        val shouldMarkCompleted = isAlreadyCompleted || isReachedThreshold || isReachedLastPage

        if (shouldMarkCompleted) {
            progress.status = "COMPLETED"
            progress.progressPercent = BigDecimal(100)
            if (progress.completedAt == null) {
                progress.completedAt = LocalDateTime.now()
            }
        } else {
            if (progress.status == "NOT_STARTED") {
                progress.status = "IN_PROGRESS"
            }
            // TÍNH PHẦN TRĂM TIẾN ĐỘ THEO TRANG ĐỌC DỞ
            if (request.totalPages > 0) {
                val maxReached = Math.max(progress.lastPosition, request.pageNumber)
                val calculated = Math.min(99.0, (maxReached.toDouble() / request.totalPages) * 100.0)
                val rounded = Math.round(calculated * 10.0) / 10.0
                if (rounded > progress.progressPercent.toDouble()) {
                    progress.progressPercent = BigDecimal.valueOf(rounded)
                }
            }
        }

        userLessonProgressRepository.save(progress)

        // Tính toán lại % hoàn thành của toàn bộ môn học
        val allLessons = lessonRepository.findBySubjectIdOrderByLessonNoAsc(lesson.subjectId)
        val userProgressMap = userLessonProgressRepository.findByUserId(userId).associateBy { it.lessonId }

        var completedCount = 0
        for (l in allLessons) {
            val p = userProgressMap[l.id]
            val c = p?.status == "COMPLETED" || (p != null && p.progressPercent.toDouble() >= 100.0)
            if (c) {
                completedCount++
            }
        }

        val subjectPercent = if (allLessons.isNotEmpty()) {
            Math.round((completedCount.toDouble() / allLessons.size * 100.0) * 10.0) / 10.0
        } else {
            0.0
        }

        val actualReadingMinutes = if (progress.readingTimeSeconds > 0) Math.max(1, (progress.readingTimeSeconds + 30) / 60) else 0

        return LessonProgressResponse(
            lessonId = lessonId.toString(),
            status = progress.status,
            isRead = progress.status == "COMPLETED",
            progressPercent = progress.progressPercent.toDouble(),
            lastPosition = progress.lastPosition,
            subjectProgressPercent = subjectPercent,
            readingMinutes = actualReadingMinutes,
            readingSeconds = progress.readingTimeSeconds
        )
    }
}
