package com.learningapp.api.entity

import jakarta.persistence.*
import java.time.LocalDateTime
import java.util.UUID

/**
 * =========================================================================================
 * [GIẢI THÍCH DÀNH CHO NGƯỜI HỌC CÓ NỀN TẢNG JAVA / PYTHON]:
 *
 * 1. data class trong Kotlin là gì?
 *    - Trong Java: Bạn phải viết class bình thường, sau đó viết hàng loạt Getter, Setter, toString(),
 *      equals(), hashCode() hoặc dùng thư viện Lombok (@Data, @Getter, @Setter).
 *    - Trong Python: Tương tự như @dataclass trong module dataclasses.
 *    - Trong Kotlin: Chỉ cần thêm chữ "data" trước "class", trình biên dịch sẽ tự động sinh toàn bộ!
 *
 * 2. Các Annotation JPA (Jakarta Persistence API) dùng chung cho Java và Kotlin:
 *    - @Entity: Đánh dấu class này đại diện cho 1 bảng (Table) trong cơ sở dữ liệu.
 *    - @Table(name = "users"): Tên của bảng trong PostgreSQL là "users".
 *    - @Id: Đánh dấu trường này là Khóa chính (Primary Key).
 *    - @GeneratedValue(strategy = GenerationType.AUTO): Tự động sinh ID duy nhất dạng UUID.
 *    - @Column: Cấu hình thuộc tính của cột (tên cột, có cho phép null không, độ dài tối đa, unique).
 * =========================================================================================
 */
@Entity
@Table(name = "users")
data class User(
    // Khóa chính: Mã định danh duy nhất (UUID), mặc định là null khi chưa lưu vào DB
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    val id: UUID? = null,

    // Cột họ và tên đệm (tối đa 80 ký tự, không được null)
    @Column(name = "last_name", nullable = false, length = 80)
    var lastName: String,

    // Cột tên (tối đa 50 ký tự, không được null)
    @Column(name = "first_name", nullable = false, length = 50)
    var firstName: String,

    // Cột email đăng nhập (phải là duy nhất - unique = true, không được trùng)
    @Column(name = "email", nullable = false, unique = true, length = 255)
    var email: String,

    // Cột số điện thoại (có dấu ? nghĩa là nullable: cho phép để trống/null)
    @Column(name = "phone", length = 20)
    var phone: String?,

    // Cột mật khẩu đã băm (BCrypt Hash), tuyệt đối không lưu mật khẩu gốc
    @Column(name = "password_hash", nullable = false)
    var passwordHash: String,

    // Trạng thái tài khoản: true = đang hoạt động, false = bị khóa
    @Column(name = "is_active", nullable = false)
    var isActive: Boolean = true,

    // Thời điểm tạo tài khoản (updatable = false: không cho phép cập nhật sau khi tạo)
    @Column(name = "created_at", nullable = false, updatable = false)
    var createdAt: LocalDateTime = LocalDateTime.now(),

    // Thời điểm cập nhật thông tin gần nhất
    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now()
) {
    // Không map trường full_name vì trong PostgreSQL nó được GENERATED ALWAYS AS (last_name || ' ' || first_name) STORED
}
