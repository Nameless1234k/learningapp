package com.learningapp.api.repository

import com.learningapp.api.entity.User
import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

/**
 * =========================================================================================
 * [GIẢI THÍCH DÀNH CHO NGƯỜI HỌC CÓ NỀN TẢNG JAVA / PYTHON]:
 *
 * 1. Interface UserRepository kế thừa JpaRepository<User, UUID>:
 *    - JpaRepository là thư viện kỳ diệu của Spring Data JPA (Java).
 *    - Tương tự ORM như SQLAlchemy trong Python hoặc Hibernate trong Java.
 *    - Nó tự động cung cấp sẵn các hàm thao tác DB cơ bản: save(), findById(), findAll(), deleteById()...
 *
 * 2. Magic Query Methods (Phương thức truy vấn tự động):
 *    - Chỉ cần bạn đặt tên hàm là "findByEmail(email)", Spring sẽ tự dịch thành câu lệnh SQL:
 *      "SELECT * FROM users WHERE email = ?"
 *    - Tương tự với "findByPhone(phone)". Bạn không cần viết một dòng SQL nào!
 * =========================================================================================
 */
interface UserRepository : JpaRepository<User, UUID> {
    // Tìm người dùng theo email (trả về User hoặc null nếu không thấy)
    fun findByEmail(email: String): User?

    // Tìm người dùng theo số điện thoại
    fun findByPhone(phone: String): User?
}
