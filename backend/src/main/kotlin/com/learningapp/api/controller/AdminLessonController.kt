package com.learningapp.api.controller

import com.learningapp.api.constant.ApiEndpoints
import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.admin.AdminLessonResponse
import com.learningapp.api.service.AdminLessonService
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile
import java.util.UUID

@RestController
@RequestMapping(ApiEndpoints.Admin.LESSONS)
@CrossOrigin(origins = ["*"])
class AdminLessonController(
    private val adminLessonService: AdminLessonService
) {
    @GetMapping
    fun getLessons(
        @RequestParam(required = false) subjectId: UUID?,
        @RequestParam(required = false) keyword: String?
    ): ResponseEntity<List<AdminLessonResponse>> {
        val lessons = adminLessonService.getLessons(subjectId, keyword)
        return ResponseEntity.ok(lessons)
    }

    @PostMapping(consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
    fun createLesson(
        @RequestParam("title") title: String,
        @RequestParam("subjectId") subjectId: UUID,
        @RequestParam(value = "file", required = false) file: MultipartFile?
    ): ResponseEntity<AdminLessonResponse> {
        val response = adminLessonService.createLesson(title, subjectId, file)
        return ResponseEntity.ok(response)
    }

    @PutMapping("/{id}", consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
    fun updateLesson(
        @PathVariable id: UUID,
        @RequestParam(value = "title", required = false) title: String?,
        @RequestParam(value = "subjectId", required = false) subjectId: UUID?,
        @RequestParam(value = "file", required = false) file: MultipartFile?,
        @RequestParam(value = "removeFile", required = false) removeFile: Boolean? = false
    ): ResponseEntity<AdminLessonResponse> {
        val response = adminLessonService.updateLesson(id, title, subjectId, file, removeFile)
        return ResponseEntity.ok(response)
    }

    @DeleteMapping("/{id}")
    fun deleteLesson(@PathVariable id: UUID): ResponseEntity<ApiResponse> {
        val response = adminLessonService.deleteLesson(id)
        return ResponseEntity.ok(response)
    }
}
