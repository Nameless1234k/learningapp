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

    // Tìm bài đọc dở gần nhất (last_read_at muộn nhất)
    fun findTopByUserIdOrderByLastReadAtDesc(userId: UUID): UserLessonProgress?

    // Lấy danh sách bài đã học của học viên theo thời gian đọc giảm dần
    fun findByUserIdOrderByLastReadAtDesc(userId: UUID): List<UserLessonProgress>
}
