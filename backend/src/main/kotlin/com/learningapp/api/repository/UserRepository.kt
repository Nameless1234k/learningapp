package com.learningapp.api.repository

import com.learningapp.api.entity.User
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.util.UUID

interface UserRepository : JpaRepository<User, UUID> {
    // Tìm người dùng theo email (trả về User hoặc null nếu không thấy)
    fun findByEmail(email: String): User?

    // Tìm người dùng theo số điện thoại
    fun findByPhone(phone: String): User?

    // Lấy tất cả người dùng sắp xếp mới nhất lên đầu
    fun findAllByOrderByCreatedAtDesc(): List<User>

    // Tìm kiếm người dùng theo họ tên, email hoặc số điện thoại
    @Query("SELECT u FROM User u WHERE " +
           "LOWER(u.firstName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(u.lastName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "(u.phone IS NOT NULL AND u.phone LIKE CONCAT('%', :keyword, '%')) " +
           "ORDER BY u.createdAt DESC")
    fun searchUsers(@Param("keyword") keyword: String): List<User>
}
