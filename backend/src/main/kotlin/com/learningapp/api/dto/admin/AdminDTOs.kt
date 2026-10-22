package com.learningapp.api.dto.admin

import java.util.UUID

data class AdminUserDTO(
    val id: UUID,
    val lastName: String,
    val firstName: String,
    val fullName: String,
    val email: String,
    val phone: String?,
    val role: String,
    val isActive: Boolean,
    val createdAt: String
)

data class UpdateUserStatusRequest(
    val isActive: Boolean
)

data class BulkUserStatusRequest(
    val ids: List<UUID>,
    val isActive: Boolean
)

data class BulkDeleteRequest(
    val ids: List<UUID>
)

data class AdminSubjectRequest(
    val code: String,
    val name: String,
    val displayOrder: Int = 0
)

data class AdminLessonResponse(
    val id: UUID,
    val subjectId: UUID,
    val subjectName: String,
    val subjectCode: String,
    val subjectDisplayOrder: Int = 0,
    val documentId: UUID?,
    val fileName: String?,
    val filePath: String?,
    val fileSizeBytes: Long? = null,
    val fileSizeMb: Double? = null,
    val lessonNo: Int,
    val title: String,
    val createdAt: String
)
