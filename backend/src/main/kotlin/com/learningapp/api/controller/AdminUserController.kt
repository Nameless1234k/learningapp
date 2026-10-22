package com.learningapp.api.controller

import com.learningapp.api.constant.ApiEndpoints
import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.admin.AdminUserDTO
import com.learningapp.api.dto.admin.BulkDeleteRequest
import com.learningapp.api.dto.admin.BulkUserStatusRequest
import com.learningapp.api.dto.admin.UpdateUserStatusRequest
import com.learningapp.api.service.AdminUserService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping(ApiEndpoints.Admin.USERS)
@CrossOrigin(origins = ["*"])
class AdminUserController(
    private val adminUserService: AdminUserService
) {
    @GetMapping
    fun getUsers(@RequestParam(required = false) keyword: String?): ResponseEntity<List<AdminUserDTO>> {
        val users = adminUserService.getUsers(keyword)
        return ResponseEntity.ok(users)
    }

    @PutMapping("/{id}/status")
    fun updateStatus(
        @PathVariable id: UUID,
        @RequestBody request: UpdateUserStatusRequest
    ): ResponseEntity<AdminUserDTO> {
        val updated = adminUserService.updateStatus(id, request.isActive)
        return ResponseEntity.ok(updated)
    }

    @PutMapping("/bulk-status")
    fun bulkUpdateStatus(
        @RequestBody request: BulkUserStatusRequest
    ): ResponseEntity<ApiResponse> {
        val response = adminUserService.bulkUpdateStatus(request.ids, request.isActive)
        return ResponseEntity.ok(response)
    }

    @DeleteMapping("/{id}")
    fun deleteUser(@PathVariable id: UUID): ResponseEntity<ApiResponse> {
        val response = adminUserService.deleteUser(id)
        return ResponseEntity.ok(response)
    }

    @PostMapping("/bulk-delete")
    fun bulkDelete(@RequestBody request: BulkDeleteRequest): ResponseEntity<ApiResponse> {
        val response = adminUserService.bulkDelete(request.ids)
        return ResponseEntity.ok(response)
    }
}
