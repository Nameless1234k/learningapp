package com.learningapp.api.entity

import jakarta.persistence.*
import java.time.LocalDateTime
import java.util.UUID

/**
 * Entity ánh xạ bảng user_settings trong PostgreSQL:
 * - Lưu thiết lập giao diện Sáng / Tối (dark_mode)
 * - Lưu trạng thái nhận thông báo (notification_enabled)
 */
@Entity
@Table(name = "user_settings")
data class UserSetting(
    @Id
    @Column(name = "user_id")
    val userId: UUID,

    @Column(name = "dark_mode", nullable = false)
    var darkMode: Boolean = false,

    @Column(name = "notification_enabled", nullable = false)
    var notificationEnabled: Boolean = true,

    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now()
)
