package com.learningapp.api.entity

import jakarta.persistence.*
import java.io.Serializable
import java.math.BigDecimal
import java.time.LocalDateTime
import java.util.UUID

data class UserLessonProgressId(
    var userId: UUID? = null,
    var lessonId: UUID? = null
) : Serializable

@Entity
@Table(name = "user_lesson_progress")
@IdClass(UserLessonProgressId::class)
data class UserLessonProgress(
    @Id
    @Column(name = "user_id", nullable = false)
    var userId: UUID,

    @Id
    @Column(name = "lesson_id", nullable = false)
    var lessonId: UUID,

    @Column(name = "progress_percent", nullable = false, precision = 5, scale = 2)
    var progressPercent: BigDecimal = BigDecimal.ZERO,

    @Column(name = "last_position", nullable = false)
    var lastPosition: Int = 0,

    @Column(name = "status", nullable = false, length = 20)
    var status: String = "NOT_STARTED",

    @Column(name = "last_read_at")
    var lastReadAt: LocalDateTime? = null,

    @Column(name = "completed_at")
    var completedAt: LocalDateTime? = null,

    @Column(name = "reading_time_seconds", nullable = false)
    var readingTimeSeconds: Int = 0
)
