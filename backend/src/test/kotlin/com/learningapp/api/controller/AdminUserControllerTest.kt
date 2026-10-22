package com.learningapp.api.controller

import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.admin.AdminUserDTO
import com.learningapp.api.dto.admin.BulkDeleteRequest
import com.learningapp.api.dto.admin.BulkUserStatusRequest
import com.learningapp.api.dto.admin.UpdateUserStatusRequest
import com.learningapp.api.service.AdminUserService
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
class AdminUserControllerTest {

    @Mock
    private lateinit var adminUserService: AdminUserService

    @InjectMocks
    private lateinit var adminUserController: AdminUserController

    private val sampleUser = AdminUserDTO(
        id = UUID.randomUUID(),
        lastName = "Nguyen",
        firstName = "An",
        fullName = "Nguyen An",
        email = "an@gmail.com",
        phone = "0901234567",
        role = "USER",
        isActive = true,
        createdAt = "2026-10-20 10:00:00"
    )

    @Test
    @DisplayName("TC01 - Endpoint lấy danh sách người dùng trả về HTTP 200")
    fun testGetUsers_Success() {
        `when`(adminUserService.getUsers(null)).thenReturn(listOf(sampleUser))

        val response = adminUserController.getUsers(null)

        assertEquals(HttpStatus.OK, response.statusCode)
        assertNotNull(response.body)
        assertEquals(1, response.body!!.size)
        assertEquals("Nguyen An", response.body!![0].fullName)
    }

    @Test
    @DisplayName("TC02 - Endpoint tìm kiếm người dùng trả về danh sách lọc đúng")
    fun testSearchUsers_Success() {
        `when`(adminUserService.getUsers("An")).thenReturn(listOf(sampleUser))

        val response = adminUserController.getUsers("An")

        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(1, response.body!!.size)
        assertEquals("an@gmail.com", response.body!![0].email)
    }

    @Test
    @DisplayName("TC03 - Endpoint cập nhật trạng thái người dùng trả về HTTP 200")
    fun testUpdateStatus_Success() {
        val updatedUser = sampleUser.copy(isActive = false)
        `when`(adminUserService.updateStatus(sampleUser.id, false)).thenReturn(updatedUser)

        val response = adminUserController.updateStatus(sampleUser.id, UpdateUserStatusRequest(false))

        assertEquals(HttpStatus.OK, response.statusCode)
        assertFalse(response.body!!.isActive)
    }

    @Test
    @DisplayName("TC04 - Endpoint cập nhật trạng thái nhiều tài khoản thành công")
    fun testBulkUpdateStatus_Success() {
        val ids = listOf(sampleUser.id)
        val expected = ApiResponse(true, "Đã cập nhật trạng thái cho 1 tài khoản.")
        `when`(adminUserService.bulkUpdateStatus(ids, false)).thenReturn(expected)

        val response = adminUserController.bulkUpdateStatus(BulkUserStatusRequest(ids, false))

        assertEquals(HttpStatus.OK, response.statusCode)
        assertTrue(response.body!!.success)
    }

    @Test
    @DisplayName("TC05 - Endpoint xóa tài khoản người dùng thành công")
    fun testDeleteUser_Success() {
        val expected = ApiResponse(true, "Đã xóa tài khoản thành công.")
        `when`(adminUserService.deleteUser(sampleUser.id)).thenReturn(expected)

        val response = adminUserController.deleteUser(sampleUser.id)

        assertEquals(HttpStatus.OK, response.statusCode)
        assertTrue(response.body!!.success)
    }

    @Test
    @DisplayName("TC06 - Endpoint xóa nhiều tài khoản người dùng thành công")
    fun testBulkDeleteUsers_Success() {
        val ids = listOf(sampleUser.id)
        val expected = ApiResponse(true, "Đã xóa thành công 1 tài khoản.")
        `when`(adminUserService.bulkDelete(ids)).thenReturn(expected)

        val response = adminUserController.bulkDelete(BulkDeleteRequest(ids))

        assertEquals(HttpStatus.OK, response.statusCode)
        assertTrue(response.body!!.success)
    }
}
