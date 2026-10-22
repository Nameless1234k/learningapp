package com.learningapp.api.service

import com.learningapp.api.entity.Document
import com.learningapp.api.entity.Lesson
import com.learningapp.api.entity.Subject
import com.learningapp.api.repository.DocumentRepository
import com.learningapp.api.repository.LessonRepository
import com.learningapp.api.repository.SubjectRepository
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.`when`
import org.mockito.Mockito.mock
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.web.multipart.MultipartFile
import java.util.Optional
import java.util.UUID

@ExtendWith(MockitoExtension::class)
class AdminLessonServiceTest {

    @Mock
    private lateinit var lessonRepository: LessonRepository

    @Mock
    private lateinit var subjectRepository: SubjectRepository

    @Mock
    private lateinit var documentRepository: DocumentRepository

    @InjectMocks
    private lateinit var adminLessonService: AdminLessonService

    private val sampleSubject = Subject(
        id = UUID.randomUUID(),
        code = "TRIET_HOC",
        name = "Triết học Mác - Lênin",
        displayOrder = 1
    )

    @Test
    @DisplayName("TC01 - Báo lỗi khi tên bài học để trống")
    fun testCreateLesson_EmptyTitle_ThrowsException() {
        val ex = assertThrows(IllegalArgumentException::class.java) {
            adminLessonService.createLesson("   ", sampleSubject.id!!, null)
        }
        assertEquals("Vui lòng nhập tên bài học!", ex.message)
    }

    @Test
    @DisplayName("TC02 - Báo lỗi khi file không phải định dạng PDF")
    fun testCreateLesson_NonPdfFile_ThrowsException() {
        `when`(subjectRepository.findById(sampleSubject.id!!)).thenReturn(Optional.of(sampleSubject))

        val mockFile = mock(MultipartFile::class.java)
        `when`(mockFile.isEmpty).thenReturn(false)
        `when`(mockFile.originalFilename).thenReturn("tailieu.docx")

        val ex = assertThrows(IllegalArgumentException::class.java) {
            adminLessonService.createLesson("Bài 1", sampleSubject.id!!, mockFile)
        }
        assertEquals("Chỉ chấp nhận file định dạng PDF!", ex.message)
    }

    @Test
    @DisplayName("TC03 - Báo lỗi khi file PDF vượt quá giới hạn 200MB theo sơ đồ đặc tả")
    fun testCreateLesson_FileOver200MB_ThrowsException() {
        `when`(subjectRepository.findById(sampleSubject.id!!)).thenReturn(Optional.of(sampleSubject))

        val mockFile = mock(MultipartFile::class.java)
        `when`(mockFile.isEmpty).thenReturn(false)
        `when`(mockFile.originalFilename).thenReturn("giao_trinh_nang.pdf")
        // Giả lập file 201 MB (vượt 200MB)
        `when`(mockFile.size).thenReturn(201L * 1024 * 1024)

        val ex = assertThrows(IllegalArgumentException::class.java) {
            adminLessonService.createLesson("Bài 1", sampleSubject.id!!, mockFile)
        }
        assertEquals("chỉ chấp nhận file PDF tối đa 200 MB", ex.message)
    }

    @Test
    @DisplayName("TC04 - Tạo bài học thành công không kèm file")
    fun testCreateLesson_WithoutFile_Success() {
        `when`(subjectRepository.findById(sampleSubject.id!!)).thenReturn(Optional.of(sampleSubject))
        `when`(lessonRepository.findTopBySubjectIdOrderByLessonNoDesc(sampleSubject.id!!)).thenReturn(null)

        val newLesson = Lesson(
            id = UUID.randomUUID(),
            subjectId = sampleSubject.id!!,
            documentId = null,
            lessonNo = 1,
            title = "Bài 1: Khái lược Triết học"
        )
        `when`(lessonRepository.save(org.mockito.ArgumentMatchers.any(Lesson::class.java))).thenReturn(newLesson)

        val result = adminLessonService.createLesson("Bài 1: Khái lược Triết học", sampleSubject.id!!, null)

        assertNotNull(result)
        assertEquals("Bài 1: Khái lược Triết học", result.title)
        assertEquals(1, result.lessonNo)
        assertNull(result.documentId)
    }
}
