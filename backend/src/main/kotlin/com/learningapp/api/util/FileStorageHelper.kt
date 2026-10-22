package com.learningapp.api.util

import java.io.File
import java.net.URLDecoder
import java.nio.charset.StandardCharsets
import java.text.Normalizer

/**
 * =========================================================================================
 * [TÊN FILE]: FileStorageHelper.kt
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/util/FileStorageHelper.kt
 * [MỤC ĐÍCH]: Helper dùng chung quản lý việc định vị và tìm kiếm tệp tin PDF trên máy chủ.
 * - Tái sử dụng giữa AdminLessonService và DocumentFileController.
 * - Tự động nhận diện thư mục uploadDir ('uploads/documents' hoặc 'backend/uploads/documents').
 * - Tìm kiếm file theo đường dẫn tương đối, tên file gốc hoặc số thứ tự bài học chuẩn hóa NFC.
 * =========================================================================================
 */
object FileStorageHelper {

    val uploadDir: File by lazy {
        val currentDir = File(System.getProperty("user.dir"))
        val candidateInBackend = File(currentDir, "backend/uploads/documents")
        val candidateDirect = File(currentDir, "uploads/documents")
        val dir = when {
            candidateInBackend.exists() -> candidateInBackend
            candidateDirect.exists() -> candidateDirect
            else -> candidateDirect.apply { mkdirs() }
        }
        if (!dir.exists()) dir.mkdirs()
        dir
    }

    /**
     * Tìm kiếm file PDF an toàn theo đường dẫn hoặc tên file
     */
    fun findPdfFile(pathOrName: String?): File? {
        if (pathOrName.isNullOrBlank()) return null
        val decoded = try {
            URLDecoder.decode(pathOrName, StandardCharsets.UTF_8.name())
        } catch (_: Exception) {
            pathOrName
        }
        val cleanPath = decoded.trim()
            .removePrefix("/")
            .removePrefix("api/documents/files/")
            .removePrefix("documents/files/")

        val targetFile = File(uploadDir, cleanPath)
        if (targetFile.canonicalPath.startsWith(uploadDir.canonicalPath) && targetFile.exists() && targetFile.isFile) {
            return targetFile
        }

        val normalizedTarget = Normalizer.normalize(File(cleanPath).name.trim(), Normalizer.Form.NFC)
        val found = uploadDir.walkTopDown().firstOrNull { file ->
            if (!file.isFile) return@firstOrNull false
            val normalizedFileName = Normalizer.normalize(file.name.trim(), Normalizer.Form.NFC)
            normalizedFileName.equals(normalizedTarget, ignoreCase = true)
        }
        if (found != null) {
            return found
        }

        val lessonNumberMatch = Regex("""(?i)bài\s*(\d+)""").find(normalizedTarget)
        if (lessonNumberMatch != null) {
            val num = lessonNumberMatch.groupValues[1]
            val foundByNum = uploadDir.walkTopDown().firstOrNull { file ->
                file.isFile && file.name.endsWith(".pdf", ignoreCase = true) &&
                        Regex("""(?i)bài\s*0*$num\b""").containsMatchIn(file.name)
            }
            if (foundByNum != null) {
                return foundByNum
            }
        }
        return null
    }

    /**
     * Tính toán dung lượng tệp tin theo Bytes và MB
     */
    fun calculateFileSize(filePath: String?, fileName: String?): Pair<Long?, Double?> {
        val file = findPdfFile(filePath) ?: findPdfFile(fileName)
        if (file == null || !file.exists()) return Pair(null, null)
        val bytes = file.length()
        val mb = Math.round((bytes.toDouble() / (1024.0 * 1024.0)) * 10.0) / 10.0
        return Pair(bytes, mb)
    }
}
