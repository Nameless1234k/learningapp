package com.learningapp.api.repository

import com.learningapp.api.entity.UserLessonProgress
import com.learningapp.api.entity.UserLessonProgressId
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
interface UserLessonProgressRepository : JpaRepository<UserLessonProgress, UserLessonProgressId> {
    fun findByUserId(userId: UUID): List<UserLessonProgress>
    fun findByUserIdAndLessonId(userId: UUID, lessonId: UUID): UserLessonProgress?
}
