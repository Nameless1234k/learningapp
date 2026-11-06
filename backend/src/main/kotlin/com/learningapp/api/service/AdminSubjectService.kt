package com.learningapp.api.service

import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.admin.AdminSubjectRequest
import com.learningapp.api.entity.Subject
import com.learningapp.api.repository.LessonRepository
import com.learningapp.api.repository.SubjectRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class AdminSubjectService(
    private val subjectRepository: SubjectRepository,
    private val lessonRepository: LessonRepository
) {
    /**
     * Lấy danh sách môn học kèm tìm kiếm
     */
    fun getSubjects(keyword: String?): List<Subject> {
        return if (keyword.isNullOrBlank()) {
            subjectRepository.findAllByOrderByDisplayOrderAscCreatedAtAsc()
        } else {
            subjectRepository.searchSubjects(keyword.trim())
        }
    }

    /**
     * Thêm môn học mới
     */
    @Transactional
    fun createSubject(request: AdminSubjectRequest): Subject {
        val trimmedCode = request.code.trim().uppercase()
        val trimmedName = request.name.trim()

        if (trimmedCode.isEmpty() || trimmedName.isEmpty()) {
            throw IllegalArgumentException("Vui lòng nhập đầy đủ mã và tên môn học!")
        }

        if (subjectRepository.findByCode(trimmedCode) != null) {
            throw IllegalArgumentException("Mã môn học '$trimmedCode' đã tồn tại!")
        }

        // Tự động tính số thứ tự tiếp theo = max(displayOrder) + 1
        val maxOrder = subjectRepository.findMaxDisplayOrder() ?: 0
        val nextOrder = maxOrder + 1

        val subject = Subject(
            code = trimmedCode,
            name = trimmedName,
            displayOrder = nextOrder
        )
        return subjectRepository.save(subject)
    }

    /**
     * Sửa môn học
     */
    @Transactional
    fun updateSubject(id: UUID, request: AdminSubjectRequest): Subject {
        val subject = subjectRepository.findById(id).orElseThrow {
            IllegalArgumentException("Không tìm thấy môn học với ID: $id")
        }

        val trimmedCode = request.code.trim().uppercase()
        val trimmedName = request.name.trim()

        if (trimmedCode.isEmpty() || trimmedName.isEmpty()) {
            throw IllegalArgumentException("Vui lòng nhập đầy đủ mã và tên môn học!")
        }

        val existingWithCode = subjectRepository.findByCode(trimmedCode)
        if (existingWithCode != null && existingWithCode.id != id) {
            throw IllegalArgumentException("Mã môn học '$trimmedCode' đã được sử dụng bởi môn học khác!")
        }

        subject.code = trimmedCode
        subject.name = trimmedName
        subject.displayOrder = request.displayOrder
        return subjectRepository.save(subject)
    }

    /**
     * Xóa môn học (kiểm tra bài học tham chiếu và đánh lại số thứ tự môn)
     */
    @Transactional
    fun deleteSubject(id: UUID): ApiResponse {
        if (!subjectRepository.existsById(id)) {
            throw IllegalArgumentException("Không tìm thấy môn học với ID: $id")
        }

        val lessonCount = lessonRepository.countBySubjectId(id)
        if (lessonCount > 0) {
            throw IllegalArgumentException("Không thể xóa môn học này vì hiện có $lessonCount bài học đang thuộc về môn!")
        }

        subjectRepository.deleteById(id)
        subjectRepository.flush()

        // Tự động đánh lại số thứ tự liên tục 1, 2, 3... cho các môn còn lại
        reindexSubjects()

        return ApiResponse(true, "Đã xóa môn học và đánh lại số thứ tự thành công.")
    }

    /**
     * Đánh lại số thứ tự (displayOrder) liên tục 1, 2, 3... cho các môn học còn lại
     * khi có bất kỳ môn học nào bị xóa ở bất kỳ vị trí nào
     */
    @Transactional
    fun reindexSubjects() {
        val remainingSubjects = subjectRepository.findAllByOrderByDisplayOrderAscCreatedAtAsc()
        remainingSubjects.forEachIndexed { index, subject ->
            val correctOrder = index + 1
            if (subject.displayOrder != correctOrder) {
                subject.displayOrder = correctOrder
                subjectRepository.save(subject)
            }
        }
        subjectRepository.flush()
    }
}
