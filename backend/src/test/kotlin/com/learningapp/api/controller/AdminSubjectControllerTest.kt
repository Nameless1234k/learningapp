package com.learningapp.api.controller

import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.admin.AdminSubjectRequest
import com.learningapp.api.entity.Subject
import com.learningapp.api.service.AdminSubjectService
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
class AdminSubjectControllerTest {

    @Mock
    private lateinit var adminSubjectService: AdminSubjectService

    @InjectMocks
    private lateinit var adminSubjectController: AdminSubjectController

    private val sampleSubject = Subject(
        id = UUID.randomUUID(),
        code = "TRIET_HOC",
        name = "Triết học Mác - Lênin",
        displayOrder = 1
    )

    @Test
    @DisplayName("TC01 - Endpoint lấy danh sách môn học trả về HTTP 200")
    fun testGetSubjects_Success() {
        `when`(adminSubjectService.getSubjects(null)).thenReturn(listOf(sampleSubject))

        val response = adminSubjectController.getSubjects(null)

        assertEquals(HttpStatus.OK, response.statusCode)
        assertNotNull(response.body)
        assertEquals(1, response.body!!.size)
        assertEquals("TRIET_HOC", response.body!![0].code)
    }

    @Test
    @DisplayName("TC02 - Endpoint thêm môn học mới trả về HTTP 200")
    fun testCreateSubject_Success() {
        val request = AdminSubjectRequest("CNXHKH", "Chủ nghĩa xã hội khoa học", 2)
        val created = Subject(UUID.randomUUID(), request.code, request.name, request.displayOrder)
        `when`(adminSubjectService.createSubject(request)).thenReturn(created)

        val response = adminSubjectController.createSubject(request)

        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals("CNXHKH", response.body!!.code)
    }

    @Test
    @DisplayName("TC03 - Endpoint sửa môn học trả về HTTP 200")
    fun testUpdateSubject_Success() {
        val request = AdminSubjectRequest("TRIET_HOC_NEW", "Triết học nâng cao", 1)
        val updated = Subject(sampleSubject.id, request.code, request.name, request.displayOrder)
        `when`(adminSubjectService.updateSubject(sampleSubject.id!!, request)).thenReturn(updated)

        val response = adminSubjectController.updateSubject(sampleSubject.id!!, request)

        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals("TRIET_HOC_NEW", response.body!!.code)
    }

    @Test
    @DisplayName("TC04 - Endpoint xóa môn học thành công")
    fun testDeleteSubject_Success() {
        val expected = ApiResponse(true, "Đã xóa môn học thành công.")
        `when`(adminSubjectService.deleteSubject(sampleSubject.id!!)).thenReturn(expected)

        val response = adminSubjectController.deleteSubject(sampleSubject.id!!)

        assertEquals(HttpStatus.OK, response.statusCode)
        assertTrue(response.body!!.success)
    }
}
