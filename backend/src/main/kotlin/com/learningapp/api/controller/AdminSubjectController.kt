package com.learningapp.api.controller

import com.learningapp.api.constant.ApiEndpoints
import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.admin.AdminSubjectRequest
import com.learningapp.api.entity.Subject
import com.learningapp.api.service.AdminSubjectService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping(ApiEndpoints.Admin.SUBJECTS)
@CrossOrigin(origins = ["*"])
class AdminSubjectController(
    private val adminSubjectService: AdminSubjectService
) {
    @GetMapping
    fun getSubjects(@RequestParam(required = false) keyword: String?): ResponseEntity<List<Subject>> {
        val subjects = adminSubjectService.getSubjects(keyword)
        return ResponseEntity.ok(subjects)
    }

    @PostMapping
    fun createSubject(@RequestBody request: AdminSubjectRequest): ResponseEntity<Subject> {
        val created = adminSubjectService.createSubject(request)
        return ResponseEntity.ok(created)
    }

    @PutMapping("/{id}")
    fun updateSubject(
        @PathVariable id: UUID,
        @RequestBody request: AdminSubjectRequest
    ): ResponseEntity<Subject> {
        val updated = adminSubjectService.updateSubject(id, request)
        return ResponseEntity.ok(updated)
    }

    @DeleteMapping("/{id}")
    fun deleteSubject(@PathVariable id: UUID): ResponseEntity<ApiResponse> {
        val response = adminSubjectService.deleteSubject(id)
        return ResponseEntity.ok(response)
    }
}
