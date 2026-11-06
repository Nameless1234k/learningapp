package com.learningapp.api.service

import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.admin.AdminLessonResponse
import com.learningapp.api.entity.Document
import com.learningapp.api.entity.Lesson
import com.learningapp.api.repository.DocumentRepository
import com.learningapp.api.repository.LessonRepository
import com.learningapp.api.repository.SubjectRepository
import com.learningapp.api.util.FileStorageHelper
import org.apache.pdfbox.Loader
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.multipart.MultipartFile
import java.io.File
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.UUID

@Service
class AdminLessonService(
    private val lessonRepository: LessonRepository,
    private val subjectRepository: SubjectRepository,
    private val documentRepository: DocumentRepository
) {
    private val dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
    private val maxFileSize = 200L * 1024 * 1024 // 200 MB
    private val uploadDir: File get() = FileStorageHelper.uploadDir

    /**
     * Tự động trích xuất tổng số trang (total_pages) của file PDF bằng Apache PDFBox
     */
    private fun extractPdfTotalPages(file: File): Int? {
        return try {
            Loader.loadPDF(file).use { doc ->
                doc.numberOfPages
            }
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Lấy danh sách bài học kèm tìm kiếm và lọc môn học
     * Sắp xếp:
     * Cấp 1: Thứ tự môn học (displayOrder tăng dần: Triết học -> CNXHKH...)
     * Cấp 2: Thứ tự bài học trong môn (lessonNo tăng dần: Bài 1, 2, ... 10)
     */
    fun getLessons(subjectId: UUID?, keyword: String?): List<AdminLessonResponse> {
        val lessons = lessonRepository.searchLessons(subjectId, keyword)
        val subjectsMap = subjectRepository.findAll().associateBy { it.id }
        val documentsMap = documentRepository.findAll().associateBy { it.id }

        val mapped = lessons.map { lesson ->
            val subject = subjectsMap[lesson.subjectId]
            val doc = lesson.documentId?.let { documentsMap[it] }
            val (sizeBytes, sizeMb) = calculateFileSize(doc)

            AdminLessonResponse(
                id = lesson.id!!,
                subjectId = lesson.subjectId,
                subjectName = subject?.name ?: "Không xác định",
                subjectCode = subject?.code ?: "UNKNOWN",
                subjectDisplayOrder = subject?.displayOrder ?: 0,
                documentId = lesson.documentId,
                fileName = doc?.fileName,
                filePath = doc?.filePath,
                fileSizeBytes = sizeBytes,
                fileSizeMb = sizeMb,
                totalPages = doc?.totalPages,
                lessonNo = lesson.lessonNo,
                title = lesson.title,
                createdAt = lesson.createdAt.format(dateFormatter)
            )
        }

        return mapped.sortedWith(
            compareBy<AdminLessonResponse> { it.subjectDisplayOrder }
                .thenBy { it.lessonNo }
        )
    }

    /**
     * Chuẩn hóa tiêu đề bài học hiển thị theo định dạng: "Bài {lessonNo}: {Tên nội dung}"
     */
    fun formatLessonTitle(lessonNo: Int, rawTitle: String): String {
        val cleanTitle = rawTitle.trim().replaceFirst(Regex("^Bài\\s*\\d+\\s*[:\\.\\-]?\\s*", RegexOption.IGNORE_CASE), "").trim()
        return if (cleanTitle.isNotEmpty()) "Bài $lessonNo: $cleanTitle" else "Bài $lessonNo"
    }

    /**
     * Thêm bài học mới kèm số thứ tự bài (lessonNo) và tải lên file PDF (nếu có)
     */
    @Transactional
    fun createLesson(title: String, subjectId: UUID, lessonNo: Int?, file: MultipartFile?): AdminLessonResponse {
        if (lessonNo == null || lessonNo <= 0) {
            throw IllegalArgumentException("Số thứ tự bài học phải là số nguyên dương (> 0)!")
        }

        val trimmedTitle = title.trim()
        if (trimmedTitle.isEmpty()) {
            throw IllegalArgumentException("Vui lòng nhập tên bài học!")
        }

        val subject = subjectRepository.findById(subjectId).orElseThrow {
            IllegalArgumentException("Vui lòng chọn môn học hợp lệ!")
        }

        val existingLesson = lessonRepository.findBySubjectIdAndLessonNo(subjectId, lessonNo)
        if (existingLesson != null) {
            throw IllegalArgumentException("Số thứ tự bài học $lessonNo đã được sử dụng bởi bài '${existingLesson.title}' trong môn này!")
        }

        var savedDoc: Document? = null

        // Xử lý upload file PDF nếu được cung cấp
        if (file != null && !file.isEmpty) {
            savedDoc = handleFileUpload(file, subject.code, subject.id!!)
        }

        val formattedTitle = formatLessonTitle(lessonNo, trimmedTitle)

        val newLesson = Lesson(
            subjectId = subjectId,
            documentId = savedDoc?.id,
            lessonNo = lessonNo,
            title = formattedTitle
        )
        val savedLesson = lessonRepository.save(newLesson)

        val (createdSizeBytes, createdSizeMb) = calculateFileSize(savedDoc)
        return AdminLessonResponse(
            id = savedLesson.id!!,
            subjectId = savedLesson.subjectId,
            subjectName = subject.name,
            subjectCode = subject.code,
            subjectDisplayOrder = subject.displayOrder,
            documentId = savedDoc?.id,
            fileName = savedDoc?.fileName,
            filePath = savedDoc?.filePath,
            fileSizeBytes = createdSizeBytes,
            fileSizeMb = createdSizeMb,
            totalPages = savedDoc?.totalPages,
            lessonNo = savedLesson.lessonNo,
            title = savedLesson.title,
            createdAt = savedLesson.createdAt.format(dateFormatter)
        )
    }

    /**
     * Cập nhật thông tin bài học (và cập nhật hoặc gỡ bỏ file PDF nếu được yêu cầu)
     */
    @Transactional
    fun updateLesson(
        id: UUID,
        title: String?,
        subjectId: UUID?,
        lessonNo: Int?,
        file: MultipartFile?,
        removeFile: Boolean? = false
    ): AdminLessonResponse {
        val lesson = lessonRepository.findById(id).orElseThrow {
            IllegalArgumentException("Không tìm thấy bài học với ID: $id")
        }

        // 1. Kiểm tra môn học mới (nếu có đổi môn)
        val targetSubjectId = subjectId ?: lesson.subjectId
        if (subjectId != null && subjectId != lesson.subjectId) {
            if (!subjectRepository.existsById(subjectId)) {
                throw IllegalArgumentException("Vui lòng chọn môn học hợp lệ!")
            }
            lesson.subjectId = subjectId
        }

        // 2. Kiểm tra xung đột số thứ tự bài học (lessonNo)
        var conflictingLesson: Lesson? = null
        val oldLessonNo = lesson.lessonNo

        if (lessonNo != null) {
            if (lessonNo <= 0) {
                throw IllegalArgumentException("Số thứ tự bài học phải là số nguyên dương (> 0)!")
            }

            if (lessonNo != lesson.lessonNo || targetSubjectId != lesson.subjectId) {
                val existing = lessonRepository.findBySubjectIdAndLessonNo(targetSubjectId, lessonNo)
                if (existing != null && existing.id != lesson.id) {
                    if (targetSubjectId == lesson.subjectId) {
                        // Cùng môn học: kích hoạt chế độ tự động hoán đổi (auto-swap)
                        conflictingLesson = existing
                    } else {
                        throw IllegalArgumentException("Môn học mới đã có bài số $lessonNo ('${existing.title}')!")
                    }
                }
            }
        }

        // 3. Nếu hoán đổi trong cùng môn: tạm thời gán conflictingLesson sang số tạm lớn để tránh trùng uq_lessons_subject_no
        if (conflictingLesson != null) {
            val maxNo = (lessonRepository.findTopBySubjectIdOrderByLessonNoDesc(targetSubjectId)?.lessonNo ?: 100)
            val tempNo = maxNo + 1000
            conflictingLesson.lessonNo = tempNo
            lessonRepository.saveAndFlush(conflictingLesson)
        }

        // 4. Cập nhật lessonNo mới cho bài hiện tại
        if (lessonNo != null) {
            lesson.lessonNo = lessonNo
        }

        // 5. Cập nhật tiêu đề bài học
        if (title != null) {
            val trimmedTitle = title.trim()
            if (trimmedTitle.isEmpty()) {
                throw IllegalArgumentException("Vui lòng nhập tên bài học!")
            }
            lesson.title = formatLessonTitle(lesson.lessonNo, trimmedTitle)
        } else if (lessonNo != null) {
            lesson.title = formatLessonTitle(lesson.lessonNo, lesson.title)
        }

        val subject = subjectRepository.findById(lesson.subjectId).orElseThrow {
            IllegalArgumentException("Không tìm thấy môn học liên kết!")
        }

        // 6. Xử lý tệp PDF
        if (removeFile == true) {
            val oldDocId = lesson.documentId
            lesson.documentId = null
            if (oldDocId != null) {
                documentRepository.deleteById(oldDocId)
            }
        } else if (file != null && !file.isEmpty) {
            // Nếu người dùng tải lên file PDF mới thay thế
            val newDoc = handleFileUpload(file, subject.code, subject.id!!)
            lesson.documentId = newDoc.id
        }

        // 7. Lưu bài đang sửa (lúc này lesson chiếm lessonNo mới và giải phóng oldLessonNo)
        val savedLesson = lessonRepository.saveAndFlush(lesson)

        // 8. Nếu có hoán đổi: gán oldLessonNo cho conflictingLesson
        if (conflictingLesson != null) {
            conflictingLesson.lessonNo = oldLessonNo
            lessonRepository.saveAndFlush(conflictingLesson)
        }

        val doc = savedLesson.documentId?.let { documentRepository.findById(it).orElse(null) }
        val (updatedSizeBytes, updatedSizeMb) = calculateFileSize(doc)

        return AdminLessonResponse(
            id = savedLesson.id!!,
            subjectId = savedLesson.subjectId,
            subjectName = subject.name,
            subjectCode = subject.code,
            subjectDisplayOrder = subject.displayOrder,
            documentId = doc?.id,
            fileName = doc?.fileName,
            filePath = doc?.filePath,
            fileSizeBytes = updatedSizeBytes,
            fileSizeMb = updatedSizeMb,
            totalPages = doc?.totalPages,
            lessonNo = savedLesson.lessonNo,
            title = savedLesson.title,
            createdAt = savedLesson.createdAt.format(dateFormatter)
        )
    }

    /**
     * Xóa bài học (và tài liệu liên kết)
     */
    @Transactional
    fun deleteLesson(id: UUID): ApiResponse {
        val lesson = lessonRepository.findById(id).orElseThrow {
            IllegalArgumentException("Không tìm thấy bài học với ID: $id")
        }

        val docId = lesson.documentId
        lessonRepository.delete(lesson)

        if (docId != null) {
            documentRepository.deleteById(docId)
        }

        return ApiResponse(true, "Đã xóa bài học thành công.")
    }

    private fun calculateFileSize(doc: Document?): Pair<Long?, Double?> {
        if (doc == null) return Pair(null, null)
        return FileStorageHelper.calculateFileSize(doc.filePath, doc.fileName)
    }

    /**
     * Hàm phụ trợ xử lý upload, tự động đếm số trang PDF và kiểm tra định dạng file
     */
    private fun handleFileUpload(file: MultipartFile, subjectCode: String, subjectId: UUID): Document {
        val originalName = file.originalFilename ?: "tailieu.pdf"

        // 1. Kiểm tra định dạng PDF
        if (!originalName.lowercase().endsWith(".pdf")) {
            throw IllegalArgumentException("Chỉ chấp nhận file định dạng PDF!")
        }

        // 2. Kiểm tra dung lượng tối đa 200MB theo sơ đồ đặc tả
        if (file.size > maxFileSize) {
            throw IllegalArgumentException("chỉ chấp nhận file PDF tối đa 200 MB")
        }

        // 3. Tạo thư mục con theo mã môn học
        val subDir = File(uploadDir, subjectCode)
        if (!subDir.exists()) {
            subDir.mkdirs()
        }

        // Đặt tên file duy nhất tránh ghi đè
        val sanitizedOriginal = originalName.replace(Regex("[^a-zA-Z0-9._-]"), "_")
        val finalFileName = "${System.currentTimeMillis()}_$sanitizedOriginal"
        val destFile = File(subDir, finalFileName)
        file.transferTo(destFile)

        // Tự động đếm số trang PDF của tệp vừa tải lên
        val pageCount = extractPdfTotalPages(destFile)

        // 4. Lưu thực thể Document vào CSDL kèm total_pages tự động
        val document = Document(
            subjectId = subjectId,
            fileName = originalName,
            filePath = "/api/documents/files/$subjectCode/$finalFileName",
            totalPages = pageCount,
            createdAt = LocalDateTime.now(),
            updatedAt = LocalDateTime.now()
        )
        return documentRepository.save(document)
    }
}
