package com.learningapp.api.repository

import com.learningapp.api.entity.Subject
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
interface SubjectRepository : JpaRepository<Subject, UUID> {
    fun findAllByOrderByDisplayOrderAsc(): List<Subject>
    fun findByCode(code: String): Subject?

    @Query("SELECT s FROM Subject s WHERE " +
           "LOWER(s.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(s.code) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "ORDER BY s.displayOrder ASC")
    fun searchSubjects(@Param("keyword") keyword: String): List<Subject>
}
