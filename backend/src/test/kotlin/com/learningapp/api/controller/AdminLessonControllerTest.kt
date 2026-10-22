package com.learningapp.api.controller

import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.admin.AdminLessonResponse
import com.learningapp.api.service.AdminLessonService
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.http.HttpStatus
import java.util.UUID

@ExtendWith(MockitoExtension::class)
class AdminLessonControllerTest {

    @Mock
    private lateinit var adminLessonService: AdminLessonService

    @InjectMocks
    private lateinit var adminLessonController: AdminLessonController

    private val sampleLesson = AdminLessonResponse(
        id = UUID.randomUUID(),
        subjectId = UUID.randomUUID(),
        subjectName = "Triết học Mác - Lênin",
        subjectCode = "TRIET_HOC",
        documentId = UUID.randomUUID(),
        fileName = "bai1.pdf",
        filePath = "/api/documents/files/TRIET_HOC/bai1.pdf",
        lessonNo = 1,
        title = "Bài 1: Triết học và vấn đề cơ bản",
        createdAt = "2026-10-20 10:00:00"
    )

    @Test
    @DisplayName("TC01 - Endpoint lấy danh sách bài học trả về HTTP 200")
    fun testGetLessons_Success() {
        `when`(adminLessonService.getLessons(null, null)).thenReturn(listOf(sampleLesson))

        val response = adminLessonController.getLessons(null, null)

        assertEquals(HttpStatus.OK, response.statusCode)
        assertNotNull(response.body)
        assertEquals(1, response.body!!.size)
        assertEquals("Bài 1: Triết học và vấn đề cơ bản", response.body!![0].title)
    }

    @Test
    @DisplayName("TC02 - Endpoint thêm bài học trả về HTTP 200")
    fun testCreateLesson_Success() {
        val subjectId = sampleLesson.subjectId
        `when`(adminLessonService.createLesson("Bài 1 mới", subjectId, null)).thenReturn(sampleLesson)

        val response = adminLessonController.createLesson("Bài 1 mới", subjectId, null)

        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(sampleLesson.title, response.body!!.title)
    }

    @Test
    @DisplayName("TC03 - Endpoint sửa bài học trả về HTTP 200")
    fun testUpdateLesson_Success() {
        val updatedLesson = sampleLesson.copy(title = "Bài 1 đã cập nhật")
        `when`(adminLessonService.updateLesson(sampleLesson.id, "Bài 1 đã cập nhật", null, null))
            .thenReturn(updatedLesson)

        val response = adminLessonController.updateLesson(sampleLesson.id, "Bài 1 đã cập nhật", null, null)

        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals("Bài 1 đã cập nhật", response.body!!.title)
    }

    @Test
    @DisplayName("TC04 - Endpoint xóa bài học thành công")
    fun testDeleteLesson_Success() {
        val expected = ApiResponse(true, "Đã xóa bài học thành công.")
        `when`(adminLessonService.deleteLesson(sampleLesson.id)).thenReturn(expected)

        val response = adminLessonController.deleteLesson(sampleLesson.id)

        assertEquals(HttpStatus.OK, response.statusCode)
        assertTrue(response.body!!.success)
    }
}
