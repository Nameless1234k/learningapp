package com.learningapp.api.service

import com.learningapp.api.dto.admin.AdminSubjectRequest
import com.learningapp.api.entity.Subject
import com.learningapp.api.repository.LessonRepository
import com.learningapp.api.repository.SubjectRepository
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.`when`
import org.mockito.Mockito.verify
import org.mockito.junit.jupiter.MockitoExtension
import java.util.Optional
import java.util.UUID

@ExtendWith(MockitoExtension::class)
class AdminSubjectServiceTest {

    @Mock
    private lateinit var subjectRepository: SubjectRepository

    @Mock
    private lateinit var lessonRepository: LessonRepository

    @InjectMocks
    private lateinit var adminSubjectService: AdminSubjectService

    @Test
    @DisplayName("TC-SUB-01 - Thêm môn học tự động tính số thứ tự (displayOrder) tăng dần theo max + 1")
    fun testCreateSubject_AutoIncrementsDisplayOrder() {
        val request = AdminSubjectRequest(
            code = "PLDC",
            name = "Pháp luật đại cương",
            displayOrder = 1 // Client gửi 1 nhưng Backend sẽ tự động tính max + 1
        )

        `when`(subjectRepository.findByCode("PLDC")).thenReturn(null)
        // Giả sử CSDL hiện tại có 5 môn, max displayOrder = 5
        `when`(subjectRepository.findMaxDisplayOrder()).thenReturn(5)
        `when`(subjectRepository.save(org.mockito.ArgumentMatchers.any(Subject::class.java))).thenAnswer { it.arguments[0] }

        val created = adminSubjectService.createSubject(request)

        assertNotNull(created)
        assertEquals("PLDC", created.code)
        assertEquals("Pháp luật đại cương", created.name)
        // displayOrder phải tự động là 5 + 1 = 6
        assertEquals(6, created.displayOrder)
    }

    @Test
    @DisplayName("TC-SUB-02 - Xóa môn học ở bất kỳ vị trí nào sẽ tự động đánh lại số thứ tự (1, 2, 3...) cho các môn còn lại")
    fun testDeleteSubject_ReindexesRemainingSubjects() {
        val subject1Id = UUID.randomUUID()
        val subject2Id = UUID.randomUUID()
        val subject3Id = UUID.randomUUID()

        val sub1 = Subject(id = subject1Id, code = "M1", name = "Môn 1", displayOrder = 1)
        val sub2 = Subject(id = subject2Id, code = "M2", name = "Môn 2", displayOrder = 2)
        val sub3 = Subject(id = subject3Id, code = "M3", name = "Môn 3", displayOrder = 3)

        // Xóa Môn 2 (vị trí số 2)
        `when`(subjectRepository.existsById(subject2Id)).thenReturn(true)
        `when`(lessonRepository.countBySubjectId(subject2Id)).thenReturn(0L)

        // Sau khi xóa sub2, danh sách còn lại gồm sub1 (order 1) và sub3 (order 3)
        `when`(subjectRepository.findAllByOrderByDisplayOrderAscCreatedAtAsc()).thenReturn(listOf(sub1, sub3))

        val response = adminSubjectService.deleteSubject(subject2Id)

        assertTrue(response.success)
        verify(subjectRepository).deleteById(subject2Id)

        // sub1 vẫn giữ nguyên 1
        assertEquals(1, sub1.displayOrder)
        // sub3 trước đó là 3, sau khi reindex phải được cập nhật thành 2
        assertEquals(2, sub3.displayOrder)
        verify(subjectRepository).save(sub3)
    }
}
