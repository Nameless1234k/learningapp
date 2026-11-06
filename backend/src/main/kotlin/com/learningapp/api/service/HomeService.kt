package com.learningapp.api.service

import com.learningapp.api.dto.home.HomeDashboardResponse
import com.learningapp.api.dto.home.RecentLessonResponse
import com.learningapp.api.dto.home.TodaySessionResponse
import com.learningapp.api.entity.Document
import com.learningapp.api.entity.Lesson
import com.learningapp.api.entity.Subject
import com.learningapp.api.repository.*
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.format.DateTimeFormatter
import java.util.UUID

/**
 * =========================================================================================
 * [TÊN FILE]: HomeService.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/service/
 * [TẦNG KIẾN TRÚC]: Service (Pattern MVC)
 * [MỤC ĐÍCH]: Xử lý nghiệp vụ hiển thị cho màn hình Trang chủ (Screen 1):
 * - CHỈ TÍNH BÀI HỌC CÓ TÀI LIỆU PDF: Bài nào không có file PDF đính kèm sẽ tự động bỏ qua.
 * - Xử lý tài khoản mới lập: gợi ý Bài học đầu tiên có PDF, nút "Vào học".
 * - Xử lý tài khoản đang học dở: hiển thị % dựa trên last_position / total_pages, nút "Tiếp tục học".
 * - Xử lý khi đạt 100%: tự động chuyển sang Bài tiếp theo có PDF.
 * - Danh sách "Đã học": Chỉ hiển thị các bài học có PDF hợp lệ.
 * =========================================================================================
 */
@Service
@Transactional(readOnly = true)
class HomeService(
    private val userRepository: UserRepository,
    private val subjectRepository: SubjectRepository,
    private val lessonRepository: LessonRepository,
    private val documentRepository: DocumentRepository,
    private val userLessonProgressRepository: UserLessonProgressRepository
) {
    private val dateFormatter = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy")

    /**
     * Kiểm tra và lấy tài liệu PDF hợp lệ của bài học (nếu có)
     */
    private fun getValidDocument(lesson: Lesson): Document? {
        val docId = lesson.documentId ?: return null
        val doc = documentRepository.findById(docId).orElse(null) ?: return null
        return if (!doc.filePath.isNullOrBlank()) doc else null
    }

    /**
     * Tìm bài học đầu tiên có tài liệu PDF trong toàn bộ hệ thống (dành cho tài khoản mới)
     */
    private fun findFirstLessonWithPdf(): Pair<Subject, Pair<Lesson, Document>>? {
        val subjects = subjectRepository.findAllByOrderByDisplayOrderAsc()
        for (sub in subjects) {
            val lessons = lessonRepository.findBySubjectIdOrderByLessonNoAsc(sub.id!!)
            for (lesson in lessons) {
                val doc = getValidDocument(lesson)
                if (doc != null) {
                    return Pair(sub, Pair(lesson, doc))
                }
            }
        }
        return null
    }

    /**
     * Tìm bài học tiếp theo CÓ TÀI LIỆU PDF (ưu tiên cùng môn, sau đó chuyển sang môn tiếp theo)
     */
    private fun findNextLessonWithPdf(currentLesson: Lesson, currentSubject: Subject): Pair<Subject, Pair<Lesson, Document>>? {
        // 1. Tìm các bài kế tiếp trong cùng môn có lesson_no > currentLesson.lessonNo
        val nextLessonsInSubject = lessonRepository.findBySubjectIdAndLessonNoGreaterThanOrderByLessonNoAsc(
            currentLesson.subjectId,
            currentLesson.lessonNo
        )
        for (l in nextLessonsInSubject) {
            val doc = getValidDocument(l)
            if (doc != null) {
                return Pair(currentSubject, Pair(l, doc))
            }
        }

        // 2. Nếu môn hiện tại không còn bài nào có PDF, tìm trong các môn tiếp theo theo displayOrder
        val allSubjects = subjectRepository.findAllByOrderByDisplayOrderAsc()
        val currentSubjectIndex = allSubjects.indexOfFirst { it.id == currentSubject.id }
        if (currentSubjectIndex >= 0) {
            for (i in (currentSubjectIndex + 1) until allSubjects.size) {
                val nextSub = allSubjects[i]
                val subLessons = lessonRepository.findBySubjectIdOrderByLessonNoAsc(nextSub.id!!)
                for (l in subLessons) {
                    val doc = getValidDocument(l)
                    if (doc != null) {
                        return Pair(nextSub, Pair(l, doc))
                    }
                }
            }
        }

        return null
    }

    fun getHomeDashboard(userId: UUID): HomeDashboardResponse {
        val user = userRepository.findById(userId).orElseThrow {
            IllegalArgumentException("Người dùng không tồn tại trong hệ thống!")
        }

        val fullName = "${user.lastName} ${user.firstName}".trim()
        val initials = extractInitials(user.lastName, user.firstName)

        // 1. Tìm bản ghi đọc dở gần nhất của người dùng
        val allUserProgress = userLessonProgressRepository.findByUserIdOrderByLastReadAtDesc(userId)
        val latestProgress = allUserProgress.firstOrNull()

        // NHÁNH 1: TÀI KHOẢN MỚI LẬP (Chưa từng đọc bài nào)
        if (latestProgress == null) {
            val firstAvailable = findFirstLessonWithPdf()
            val session = if (firstAvailable != null) {
                val (firstSub, lessonAndDoc) = firstAvailable
                val (firstLesson, doc) = lessonAndDoc
                TodaySessionResponse(
                    lessonId = firstLesson.id.toString(),
                    subjectId = firstSub.id.toString(),
                    subjectName = firstSub.name,
                    lessonNo = firstLesson.lessonNo,
                    lessonTitle = firstLesson.title,
                    progressPercent = 0.0,
                    lastPosition = 1,
                    totalPages = doc.totalPages ?: 1,
                    pdfUrl = "/api/documents/${doc.id}/file",
                    buttonText = "Vào học",
                    status = "NOT_STARTED",
                    readingSeconds = 0
                )
            } else null

            return HomeDashboardResponse(
                greeting = "Chào mừng bạn đến với Learning App",
                userFullName = fullName,
                userInitials = initials,
                isNewUser = true,
                todaySession = session,
                recentLessons = emptyList()
            )
        }

        // NHÁNH 2 & 3: TÀI KHOẢN ĐÃ CÓ TIẾN ĐỘ
        val currentLesson = lessonRepository.findById(latestProgress.lessonId).orElse(null)
        val currentSubject = currentLesson?.subjectId?.let { subjectRepository.findById(it).orElse(null) }
        val currentDoc = currentLesson?.let { getValidDocument(it) }

        val isCompleted = latestProgress.status == "COMPLETED" || latestProgress.progressPercent.toDouble() >= 100.0
        val todaySession: TodaySessionResponse?
        val greeting = "Xin chào, ${user.firstName}!"

        if (!isCompleted && currentLesson != null && currentSubject != null && currentDoc != null) {
            // NHÁNH 2: Đang đọc dở bài học CÓ PDF (< 100%)
            val totalPages = currentDoc.totalPages ?: 1
            val lastPos = Math.max(1, latestProgress.lastPosition)

            todaySession = TodaySessionResponse(
                lessonId = currentLesson.id.toString(),
                subjectId = currentSubject.id.toString(),
                subjectName = currentSubject.name,
                lessonNo = currentLesson.lessonNo,
                lessonTitle = currentLesson.title,
                progressPercent = latestProgress.progressPercent.toDouble(),
                lastPosition = lastPos,
                totalPages = totalPages,
                pdfUrl = "/api/documents/${currentDoc.id}/file",
                buttonText = "Tiếp tục học",
                status = latestProgress.status,
                readingSeconds = latestProgress.readingTimeSeconds
            )
        } else if (currentLesson != null && currentSubject != null) {
            // NHÁNH 3: Đã hoàn thành 100% HOẶC bài hiện tại không có PDF -> Tự động tìm bài tiếp theo CÓ PDF
            val nextAvailable = findNextLessonWithPdf(currentLesson, currentSubject)

            if (nextAvailable != null) {
                val (nextSub, lessonAndDoc) = nextAvailable
                val (nextLesson, nextDoc) = lessonAndDoc
                todaySession = TodaySessionResponse(
                    lessonId = nextLesson.id.toString(),
                    subjectId = nextSub.id.toString(),
                    subjectName = nextSub.name,
                    lessonNo = nextLesson.lessonNo,
                    lessonTitle = nextLesson.title,
                    progressPercent = 0.0,
                    lastPosition = 1,
                    totalPages = nextDoc.totalPages ?: 1,
                    pdfUrl = "/api/documents/${nextDoc.id}/file",
                    buttonText = "Vào học",
                    status = "NOT_STARTED",
                    readingSeconds = 0
                )
            } else {
                // Đã hoàn thành toàn bộ các bài học có PDF trong hệ thống
                if (currentDoc != null) {
                    todaySession = TodaySessionResponse(
                        lessonId = currentLesson.id.toString(),
                        subjectId = currentSubject.id.toString(),
                        subjectName = currentSubject.name,
                        lessonNo = currentLesson.lessonNo,
                        lessonTitle = currentLesson.title,
                        progressPercent = 100.0,
                        lastPosition = Math.max(1, latestProgress.lastPosition),
                        totalPages = currentDoc.totalPages ?: 1,
                        pdfUrl = "/api/documents/${currentDoc.id}/file",
                        buttonText = "Đọc lại",
                        status = "COMPLETED",
                        readingSeconds = latestProgress.readingTimeSeconds
                    )
                } else {
                    todaySession = null
                }
            }
        } else {
            todaySession = null
        }

        // 2. Danh sách "ĐÃ HỌC": CHỈ LẤY CÁC BÀI HỌC CÓ TÀI LIỆU PDF HỢP LỆ
        val recentLessons = allUserProgress
            .mapNotNull { p ->
                val lesson = lessonRepository.findById(p.lessonId).orElse(null) ?: return@mapNotNull null
                val doc = getValidDocument(lesson) ?: return@mapNotNull null
                val subject = subjectRepository.findById(lesson.subjectId).orElse(null)
                RecentLessonResponse(
                    lessonId = lesson.id.toString(),
                    lessonTitle = lesson.title,
                    subjectName = subject?.name ?: "",
                    progressPercent = p.progressPercent.toDouble(),
                    lastPosition = Math.max(1, p.lastPosition),
                    pdfUrl = "/api/documents/${doc.id}/file",
                    lastReadAt = p.lastReadAt?.format(dateFormatter)
                )
            }
            .take(6)

        return HomeDashboardResponse(
            greeting = greeting,
            userFullName = fullName,
            userInitials = initials,
            isNewUser = false,
            todaySession = todaySession,
            recentLessons = recentLessons
        )
    }

    /**
     * Tự động trích xuất 2 chữ cái Avatar (Initials) từ Họ và Tên (ví dụ: "Lê Anh" + "Huy" -> "LH")
     */
    private fun extractInitials(lastName: String, firstName: String): String {
        val l = lastName.trim().firstOrNull()?.uppercaseChar()?.toString() ?: ""
        val f = firstName.trim().firstOrNull()?.uppercaseChar()?.toString() ?: ""
        return if (l.isNotEmpty() && f.isNotEmpty()) "$l$f" else (l + f).ifEmpty { "U" }
    }
}
