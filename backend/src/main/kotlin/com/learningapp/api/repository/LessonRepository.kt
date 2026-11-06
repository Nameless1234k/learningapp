package com.learningapp.api.repository

import com.learningapp.api.entity.Lesson
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
interface LessonRepository : JpaRepository<Lesson, UUID> {
    fun findBySubjectIdOrderByLessonNoAsc(subjectId: UUID): List<Lesson>
    fun countBySubjectId(subjectId: UUID): Long
    fun findTopBySubjectIdOrderByLessonNoDesc(subjectId: UUID): Lesson?
    fun findBySubjectIdAndLessonNo(subjectId: UUID, lessonNo: Int): Lesson?

    // Tìm bài đầu tiên của môn học (lesson_no nhỏ nhất, thường là Bài 1)
    fun findTopBySubjectIdOrderByLessonNoAsc(subjectId: UUID): Lesson?

    // Tìm các bài kế tiếp trong cùng môn học có lesson_no lớn hơn bài hiện tại
    fun findBySubjectIdAndLessonNoGreaterThanOrderByLessonNoAsc(subjectId: UUID, lessonNo: Int): List<Lesson>

    @Query("SELECT l FROM Lesson l WHERE " +
           "(:subjectId IS NULL OR l.subjectId = :subjectId) AND " +
           "(:keyword IS NULL OR :keyword = '' OR LOWER(l.title) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "ORDER BY l.createdAt DESC")
    fun searchLessons(@Param("subjectId") subjectId: UUID?, @Param("keyword") keyword: String?): List<Lesson>
}
