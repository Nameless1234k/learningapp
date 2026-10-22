package com.learningapp.api.controller

import com.learningapp.api.constant.ApiEndpoints
import com.learningapp.api.repository.DocumentRepository
import com.learningapp.api.util.FileStorageHelper
import jakarta.servlet.http.HttpServletRequest
import org.springframework.core.io.FileSystemResource
import org.springframework.core.io.Resource
import org.springframework.http.ContentDisposition
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.io.File
import java.nio.charset.StandardCharsets
import java.util.UUID

@RestController
@RequestMapping(ApiEndpoints.Documents.BASE)
@CrossOrigin(origins = ["*"])
class DocumentFileController(
    private val documentRepository: DocumentRepository
) {

    @RequestMapping(value = ["/{id}/file"], method = [RequestMethod.GET, RequestMethod.HEAD])
    fun getPdfFileById(@PathVariable id: UUID): ResponseEntity<Resource> {
        val doc = documentRepository.findById(id).orElse(null)
            ?: return ResponseEntity.notFound().build()

        val targetFile = doc.filePath?.let { FileStorageHelper.findPdfFile(it) }
            ?: FileStorageHelper.findPdfFile(doc.fileName)
            ?: return ResponseEntity.notFound().build()

        return servePdf(targetFile, doc.fileName)
    }

    @RequestMapping(value = ["/files/**"], method = [RequestMethod.GET, RequestMethod.HEAD])
    fun getPdfFileByPath(request: HttpServletRequest): ResponseEntity<Resource> {
        val requestUri = request.requestURI
        val rawPath = requestUri.substringAfter("/api/documents/files/")
        val targetFile = FileStorageHelper.findPdfFile(rawPath) ?: return ResponseEntity.notFound().build()
        return servePdf(targetFile, targetFile.name)
    }

    private fun servePdf(targetFile: File, displayName: String): ResponseEntity<Resource> {
        val resource = FileSystemResource(targetFile)
        val contentDisposition = ContentDisposition.inline()
            .filename(displayName, StandardCharsets.UTF_8)
            .build()

        return ResponseEntity.ok()
            .contentType(MediaType.APPLICATION_PDF)
            .contentLength(targetFile.length())
            .header(HttpHeaders.ACCEPT_RANGES, "bytes")
            .header(HttpHeaders.CONTENT_DISPOSITION, contentDisposition.toString())
            .body(resource)
    }
}
