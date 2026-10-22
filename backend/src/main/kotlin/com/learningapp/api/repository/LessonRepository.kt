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
    fun findAllByOrderByCreatedAtDesc(): List<Lesson>

    @Query("SELECT l FROM Lesson l WHERE " +
           "(:subjectId IS NULL OR l.subjectId = :subjectId) AND " +
           "(:keyword IS NULL OR :keyword = '' OR LOWER(l.title) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "ORDER BY l.createdAt DESC")
    fun searchLessons(@Param("subjectId") subjectId: UUID?, @Param("keyword") keyword: String?): List<Lesson>
}
