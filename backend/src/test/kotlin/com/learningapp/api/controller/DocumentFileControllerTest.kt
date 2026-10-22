package com.learningapp.api.controller

import com.learningapp.api.entity.Document
import com.learningapp.api.repository.DocumentRepository
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.http.HttpStatus
import java.util.Optional
import java.util.UUID

@ExtendWith(MockitoExtension::class)
class DocumentFileControllerTest {

    @Mock
    private lateinit var documentRepository: DocumentRepository

    @InjectMocks
    private lateinit var documentFileController: DocumentFileController

    @Test
    @DisplayName("TC01 - Khi không tìm thấy Document ID trong DB thì trả về 404")
    fun testGetPdfFileById_NotFound() {
        val nonExistentId = UUID.randomUUID()
        `when`(documentRepository.findById(nonExistentId)).thenReturn(Optional.empty())

        val response = documentFileController.getPdfFileById(nonExistentId)
        assertEquals(HttpStatus.NOT_FOUND, response.statusCode)
    }

    @Test
    @DisplayName("TC02 - Khi có Document ID nhưng file vật lý không tồn tại thì trả về 404 an toàn")
    fun testGetPdfFileById_FileNotFoundOnDisk() {
        val docId = UUID.randomUUID()
        val mockDoc = Document(
            id = docId,
            subjectId = UUID.randomUUID(),
            fileName = "khong_ton_tai.pdf",
            filePath = "khong_ton_tai.pdf"
        )
        `when`(documentRepository.findById(docId)).thenReturn(Optional.of(mockDoc))

        val response = documentFileController.getPdfFileById(docId)
        assertEquals(HttpStatus.NOT_FOUND, response.statusCode)
    }
}
