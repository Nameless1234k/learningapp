package com.learningapp.api.service

import com.learningapp.api.entity.Lesson
import com.learningapp.api.entity.Subject
import com.learningapp.api.repository.LessonRepository
import com.learningapp.api.repository.SubjectRepository
import com.learningapp.api.repository.UserLessonProgressRepository
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.`when`
import org.mockito.Mockito.any
import org.mockito.junit.jupiter.MockitoExtension
import java.util.*

// =========================================================================================
// [TÊN FILE: SubjectServiceTest.kt]
// [VỊ TRÍ]: src/test/kotlin/.../SubjectServiceTest.kt
// [MỤC ĐÍCH]: Kiểm thử đơn vị tầng Service cho Use Case "Xem tài liệu":
// - Screen 9: Lấy danh sách 5 môn học kèm % tiến độ và bài tiếp theo
// - Screen 14: Lấy danh sách bài học của môn học được chọn
// =========================================================================================

@ExtendWith(MockitoExtension::class)
class SubjectServiceTest {

    // Mock các Repository để không gọi Database thật
    @Mock
    private lateinit var subjectRepository: SubjectRepository

    @Mock
    private lateinit var lessonRepository: LessonRepository

    @Mock
    private lateinit var userLessonProgressRepository: UserLessonProgressRepository

    @Mock
    private lateinit var documentRepository: com.learningapp.api.repository.DocumentRepository

    // Tiêm các Mock vào SubjectService
    @InjectMocks
    private lateinit var subjectService: SubjectService

    @Test
    @DisplayName("TC01 - Lấy danh sách môn học kèm tiến độ thành công (Screen 9)")
    fun testGetSubjectsWithProgress_Success() {
        // 1. Chuẩn bị dữ liệu mẫu
        val subjectId1 = UUID.randomUUID()
        val subjectId2 = UUID.randomUUID()

        val subject1 = Subject(
            id = subjectId1,
            code = "TRIET_HOC",
            name = "Triết học Mác - Lênin",
            displayOrder = 1
        )
        val subject2 = Subject(
            id = subjectId2,
            code = "CNXHKH",
            name = "Chủ nghĩa xã hội khoa học",
            displayOrder = 2
        )

        val lesson1 = Lesson(
            id = UUID.randomUUID(),
            subjectId = subjectId1,
            lessonNo = 1,
            title = "Khái lược về Triết học"
        )

        // 2. Giả lập hành vi của Mockito
        `when`(subjectRepository.findAllByOrderByDisplayOrderAsc()).thenReturn(listOf(subject1, subject2))
        `when`(lessonRepository.findBySubjectIdOrderByLessonNoAsc(subjectId1)).thenReturn(listOf(lesson1))
        `when`(lessonRepository.findBySubjectIdOrderByLessonNoAsc(subjectId2)).thenReturn(emptyList())

        // 3. Thực thi
        val response = subjectService.getSubjectsWithProgress(userId = null)

        // 4. Kiểm tra kết quả
        assertEquals(2, response.totalSubjects)
        assertEquals(2, response.subjects.size)
        assertEquals("Triết học Mác - Lênin", response.subjects[0].name)
        assertEquals("Chủ nghĩa xã hội khoa học", response.subjects[1].name)
    }

    @Test
    @DisplayName("TC02 - Lấy chi tiết bài học của môn thành công (Screen 14)")
    fun testGetSubjectDetail_Success() {
        val subjectId = UUID.randomUUID()
        val subject = Subject(
            id = subjectId,
            code = "TRIET_HOC",
            name = "Triết học Mác – Lênin"
        )

        val lesson1 = Lesson(
            id = UUID.randomUUID(),
            subjectId = subjectId,
            lessonNo = 1,
            title = "Bài 1. Khái lược Triết học"
        )
        val lesson2 = Lesson(
            id = UUID.randomUUID(),
            subjectId = subjectId,
            lessonNo = 2,
            title = "Bài 2. Chủ nghĩa duy vật"
        )

        `when`(subjectRepository.findById(subjectId)).thenReturn(Optional.of(subject))
        `when`(lessonRepository.findBySubjectIdOrderByLessonNoAsc(subjectId)).thenReturn(listOf(lesson1, lesson2))

        val response = subjectService.getSubjectDetail(subjectId, userId = null)

        assertEquals("Triết học Mác – Lênin", response.subjectName)
        assertEquals(2, response.totalLessons)
        assertEquals(2, response.lessons.size)
        assertEquals(0, response.lessons[0].estimatedMinutes)
        assertEquals(0, response.lessons[1].estimatedMinutes)
    }

    @Test
    @DisplayName("TC03 - Môn học chưa có bài học trả về danh sách rỗng để hiển thị 'Hệ thống đang cập nhật'")
    fun testGetSubjectDetail_EmptyLessons() {
        val subjectId = UUID.randomUUID()
        val subject = Subject(
            id = subjectId,
            code = "LS_DCSVN",
            name = "Lịch sử Đảng"
        )

        `when`(subjectRepository.findById(subjectId)).thenReturn(Optional.of(subject))
        `when`(lessonRepository.findBySubjectIdOrderByLessonNoAsc(subjectId)).thenReturn(emptyList())

        val response = subjectService.getSubjectDetail(subjectId, userId = null)

        assertEquals(0, response.totalLessons)
        assertTrue(response.lessons.isEmpty())
    }

    @Test
    @DisplayName("TC04 - Tự động đánh dấu hoàn thành bài học khi đọc >= 60 giây và tính lại % môn học")
    fun testUpdateLessonProgress_Threshold60s_Completed() {
        val userId = UUID.randomUUID()
        val subjectId = UUID.randomUUID()
        val lessonId1 = UUID.randomUUID()
        val lessonId2 = UUID.randomUUID()

        val lesson1 = Lesson(id = lessonId1, subjectId = subjectId, lessonNo = 1, title = "Bài 1")
        val lesson2 = Lesson(id = lessonId2, subjectId = subjectId, lessonNo = 2, title = "Bài 2")

        `when`(lessonRepository.findById(lessonId1)).thenReturn(Optional.of(lesson1))
        `when`(userLessonProgressRepository.findByUserIdAndLessonId(userId, lessonId1)).thenReturn(null)
        `when`(userLessonProgressRepository.save(any(com.learningapp.api.entity.UserLessonProgress::class.java))).thenAnswer { it.arguments[0] }
        `when`(lessonRepository.findBySubjectIdOrderByLessonNoAsc(subjectId)).thenReturn(listOf(lesson1, lesson2))
        
        // Giả lập danh sách tiến độ sau khi lưu (lesson1 đã COMPLETED, lesson2 chưa học)
        val completedProgress1 = com.learningapp.api.entity.UserLessonProgress(
            userId = userId,
            lessonId = lessonId1,
            status = "COMPLETED",
            progressPercent = java.math.BigDecimal(100),
            readingTimeSeconds = 65
        )
        `when`(userLessonProgressRepository.findByUserId(userId)).thenReturn(listOf(completedProgress1))

        // Gửi request đọc 65 giây (vượt ngưỡng 60s)
        val request = com.learningapp.api.dto.subject.UpdateLessonProgressRequest(
            pageNumber = 3,
            totalPages = 10,
            secondsSpent = 65
        )

        val response = subjectService.updateLessonProgress(userId, lessonId1, request)

        assertTrue(response.isRead)
        assertEquals("COMPLETED", response.status)
        assertEquals(100.0, response.progressPercent)
        assertEquals(3, response.lastPosition)
        assertEquals(50.0, response.subjectProgressPercent) // 1/2 bài = 50.0%
        assertEquals(1, response.readingMinutes)            // 65s -> 1 phút
    }

    @Test
    @DisplayName("TC05 - Tự động đánh dấu hoàn thành khi cuộn tới trang cuối")
    fun testUpdateLessonProgress_ReachedLastPage_Completed() {
        val userId = UUID.randomUUID()
        val subjectId = UUID.randomUUID()
        val lessonId = UUID.randomUUID()
        val lesson = Lesson(id = lessonId, subjectId = subjectId, lessonNo = 1, title = "Bài 1")

        `when`(lessonRepository.findById(lessonId)).thenReturn(Optional.of(lesson))
        `when`(userLessonProgressRepository.findByUserIdAndLessonId(userId, lessonId)).thenReturn(null)
        `when`(userLessonProgressRepository.save(any(com.learningapp.api.entity.UserLessonProgress::class.java))).thenAnswer { it.arguments[0] }
        `when`(lessonRepository.findBySubjectIdOrderByLessonNoAsc(subjectId)).thenReturn(listOf(lesson))
        `when`(userLessonProgressRepository.findByUserId(userId)).thenReturn(emptyList())

        // Cuộn tới trang 15 trên 15 trang
        val request = com.learningapp.api.dto.subject.UpdateLessonProgressRequest(
            pageNumber = 15,
            totalPages = 15,
            secondsSpent = 10
        )

        val response = subjectService.updateLessonProgress(userId, lessonId, request)

        assertTrue(response.isRead)
        assertEquals("COMPLETED", response.status)
        assertEquals(100.0, response.progressPercent)
    }

    @Test
    @DisplayName("TC06 - Khi chưa đạt 60s và chưa tới trang cuối thì chuyển sang IN_PROGRESS")
    fun testUpdateLessonProgress_InProgress() {
        val userId = UUID.randomUUID()
        val subjectId = UUID.randomUUID()
        val lessonId = UUID.randomUUID()
        val lesson = Lesson(id = lessonId, subjectId = subjectId, lessonNo = 1, title = "Bài 1")

        `when`(lessonRepository.findById(lessonId)).thenReturn(Optional.of(lesson))
        `when`(userLessonProgressRepository.findByUserIdAndLessonId(userId, lessonId)).thenReturn(null)
        `when`(userLessonProgressRepository.save(any(com.learningapp.api.entity.UserLessonProgress::class.java))).thenAnswer { it.arguments[0] }
        `when`(lessonRepository.findBySubjectIdOrderByLessonNoAsc(subjectId)).thenReturn(listOf(lesson))
        `when`(userLessonProgressRepository.findByUserId(userId)).thenReturn(emptyList())

        // Mới đọc 25 giây, trang 2/10
        val request = com.learningapp.api.dto.subject.UpdateLessonProgressRequest(
            pageNumber = 2,
            totalPages = 10,
            secondsSpent = 25
        )

        val response = subjectService.updateLessonProgress(userId, lessonId, request)

        assertFalse(response.isRead)
        assertEquals("IN_PROGRESS", response.status)
        assertEquals(2, response.lastPosition)
        assertEquals(25, response.readingSeconds)
    }

    @Test
    @DisplayName("TC07 - Cộng dồn thời gian đọc qua nhiều phiên: Phiên 1 (25s) + Phiên 2 (40s) = 65s -> COMPLETED")
    fun testUpdateLessonProgress_MultiSession_TimeAccumulation() {
        val userId = UUID.randomUUID()
        val subjectId = UUID.randomUUID()
        val lessonId = UUID.randomUUID()
        val lesson = Lesson(id = lessonId, subjectId = subjectId, lessonNo = 1, title = "Bài 1")

        // Giả lập phiên 1 đã đọc 25 giây trước đó và thoát ra
        val existingProgress = com.learningapp.api.entity.UserLessonProgress(
            userId = userId,
            lessonId = lessonId,
            status = "IN_PROGRESS",
            lastPosition = 3,
            readingTimeSeconds = 25
        )

        `when`(lessonRepository.findById(lessonId)).thenReturn(Optional.of(lesson))
        `when`(userLessonProgressRepository.findByUserIdAndLessonId(userId, lessonId)).thenReturn(existingProgress)
        `when`(userLessonProgressRepository.save(any(com.learningapp.api.entity.UserLessonProgress::class.java))).thenAnswer { it.arguments[0] }
        `when`(lessonRepository.findBySubjectIdOrderByLessonNoAsc(subjectId)).thenReturn(listOf(lesson))
        `when`(userLessonProgressRepository.findByUserId(userId)).thenReturn(emptyList())

        // Phiên 2: Đọc thêm 40 giây (Client gửi durationSeconds = 40 hoặc tổng tích lũy = 65s)
        val request = com.learningapp.api.dto.subject.UpdateLessonProgressRequest(
            pageNumber = 5,
            totalPages = 10,
            durationSeconds = 40
        )

        val response = subjectService.updateLessonProgress(userId, lessonId, request)

        // Tổng thời gian được cộng dồn: 25 + 40 = 65 giây -> Vượt ngưỡng 60s -> COMPLETED
        assertTrue(response.isRead)
        assertEquals("COMPLETED", response.status)
        assertEquals(65, response.readingSeconds)
        assertEquals(1, response.readingMinutes) // 65s = 1 phút
        assertEquals(5, response.lastPosition)
    }

    @Test
    @DisplayName("TC08 - Cập nhật vị trí trang: Giữ trang lớn nhất từng đọc (không giảm khi lật ngược lại)")
    fun testUpdateLessonProgress_PreserveMaxPage() {
        val userId = UUID.randomUUID()
        val subjectId = UUID.randomUUID()
        val lessonId = UUID.randomUUID()
        val lesson = Lesson(id = lessonId, subjectId = subjectId, lessonNo = 1, title = "Bài 1")

        // Đã từng đọc tới trang 8
        val existingProgress = com.learningapp.api.entity.UserLessonProgress(
            userId = userId,
            lessonId = lessonId,
            status = "IN_PROGRESS",
            lastPosition = 8,
            readingTimeSeconds = 45
        )

        `when`(lessonRepository.findById(lessonId)).thenReturn(Optional.of(lesson))
        `when`(userLessonProgressRepository.findByUserIdAndLessonId(userId, lessonId)).thenReturn(existingProgress)
        `when`(userLessonProgressRepository.save(any(com.learningapp.api.entity.UserLessonProgress::class.java))).thenAnswer { it.arguments[0] }
        `when`(lessonRepository.findBySubjectIdOrderByLessonNoAsc(subjectId)).thenReturn(listOf(lesson))
        `when`(userLessonProgressRepository.findByUserId(userId)).thenReturn(emptyList())

        // Trường hợp 1: Người dùng lật ngược về trang 3 -> Vẫn giữ lastPosition = 8
        val requestBackwards = com.learningapp.api.dto.subject.UpdateLessonProgressRequest(
            pageNumber = 3,
            totalPages = 20,
            secondsSpent = 50
        )
        val response1 = subjectService.updateLessonProgress(userId, lessonId, requestBackwards)
        assertEquals(8, response1.lastPosition, "Trang không được giảm xuống 3 khi lật ngược lại")

        // Trường hợp 2: Người dùng lật tiến tới trang 12 -> Cập nhật lên lastPosition = 12
        val requestForwards = com.learningapp.api.dto.subject.UpdateLessonProgressRequest(
            pageNumber = 12,
            totalPages = 20,
            secondsSpent = 55
        )
        val response2 = subjectService.updateLessonProgress(userId, lessonId, requestForwards)
        assertEquals(12, response2.lastPosition, "Trang phải được cập nhật lên 12 khi xem trang lớn hơn")
    }
}
