package com.learningapp.api.service

import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.admin.AdminLessonResponse
import com.learningapp.api.entity.Document
import com.learningapp.api.entity.Lesson
import com.learningapp.api.repository.DocumentRepository
import com.learningapp.api.repository.LessonRepository
import com.learningapp.api.repository.SubjectRepository
import com.learningapp.api.util.FileStorageHelper
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
     * Thêm bài học mới kèm tải lên file PDF (nếu có)
     */
    @Transactional
    fun createLesson(title: String, subjectId: UUID, file: MultipartFile?): AdminLessonResponse {
        val trimmedTitle = title.trim()
        if (trimmedTitle.isEmpty()) {
            throw IllegalArgumentException("Vui lòng nhập tên bài học!")
        }

        val subject = subjectRepository.findById(subjectId).orElseThrow {
            IllegalArgumentException("Vui lòng chọn môn học hợp lệ!")
        }

        var savedDoc: Document? = null

        // Xử lý upload file PDF nếu được cung cấp
        if (file != null && !file.isEmpty) {
            savedDoc = handleFileUpload(file, subject.code, subject.id!!)
        }

        // Tự động tính số thứ tự bài học tiếp theo trong môn
        val lastLesson = lessonRepository.findTopBySubjectIdOrderByLessonNoDesc(subjectId)
        val nextLessonNo = (lastLesson?.lessonNo ?: 0) + 1

        val newLesson = Lesson(
            subjectId = subjectId,
            documentId = savedDoc?.id,
            lessonNo = nextLessonNo,
            title = trimmedTitle
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
        file: MultipartFile?,
        removeFile: Boolean? = false
    ): AdminLessonResponse {
        val lesson = lessonRepository.findById(id).orElseThrow {
            IllegalArgumentException("Không tìm thấy bài học với ID: $id")
        }

        if (title != null) {
            val trimmedTitle = title.trim()
            if (trimmedTitle.isEmpty()) {
                throw IllegalArgumentException("Vui lòng nhập tên bài học!")
            }
            lesson.title = trimmedTitle
        }

        if (subjectId != null) {
            if (!subjectRepository.existsById(subjectId)) {
                throw IllegalArgumentException("Vui lòng chọn môn học hợp lệ!")
            }
            lesson.subjectId = subjectId
        }

        val subject = subjectRepository.findById(lesson.subjectId).orElseThrow {
            IllegalArgumentException("Không tìm thấy môn học liên kết!")
        }

        // Nếu người dùng chọn gỡ bỏ tệp PDF
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

        val savedLesson = lessonRepository.save(lesson)
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
     * Hàm phụ trợ xử lý upload và kiểm tra định dạng file
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

        // 4. Lưu thực thể Document vào CSDL
        val document = Document(
            subjectId = subjectId,
            fileName = originalName,
            filePath = "/api/documents/files/$subjectCode/$finalFileName",
            createdAt = LocalDateTime.now(),
            updatedAt = LocalDateTime.now()
        )
        return documentRepository.save(document)
    }
}
