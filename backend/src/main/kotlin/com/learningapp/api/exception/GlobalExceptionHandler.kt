package com.learningapp.api.exception

import com.learningapp.api.dto.ApiResponse
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.http.converter.HttpMessageNotReadableException
import org.springframework.web.HttpRequestMethodNotSupportedException
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

/**
 * =========================================================================================
 * 1. @RestControllerAdvice là gì?
 *    - Trong Spring Boot (Java), đây là một "Bộ đón bắt ngoại lệ tập trung" (Global Exception Handler).
 *    - Hoạt động giống như việc bạn bọc toàn bộ các route trong một khối "try...except" lớn trong Python Flask/FastAPI.
 *    - Khi bất kỳ Controller nào trong hệ thống quăng ra một Exception (lỗi), thay vì làm server sập
 *      hoặc trả về trang HTML 500 kèm StackTrace xấu xí, nó sẽ rơi vào đây để xử lý.
 *
 * 2. @ExceptionHandler(TênNgoạiLệ::class):
 *    - Chỉ định hàm bên dưới sẽ chịu trách nhiệm bắt loại ngoại lệ nào.
 *    - Tương tự như "except IllegalArgumentException as ex:" trong Python.
 * =========================================================================================
 */
@RestControllerAdvice
class GlobalExceptionHandler {

    /**
     * Bắt các ngoại lệ do logic nghiệp vụ chủ động ném ra (ví dụ: mật khẩu sai, tài khoản đã tồn tại, OTP hết hạn).
     * Trả về HTTP 400 (Bad Request).
     */
    @ExceptionHandler(IllegalArgumentException::class)
    fun handleIllegalArgumentException(ex: IllegalArgumentException): ResponseEntity<ApiResponse> {
        val message = ex.message ?: "Yêu cầu không hợp lệ."
        return ResponseEntity
            .status(HttpStatus.BAD_REQUEST)
            .body(ApiResponse(success = false, message = message))
    }

    /**
     * Bắt lỗi khi người dùng gửi JSON sai cú pháp hoặc sai kiểu dữ liệu (ví dụ thiếu dấu ngoặc nhọn, gửi chuỗi vào ô số).
     * Trả về HTTP 400 (Bad Request).
     */
    @ExceptionHandler(HttpMessageNotReadableException::class)
    fun handleHttpMessageNotReadable(ex: HttpMessageNotReadableException): ResponseEntity<ApiResponse> {
        return ResponseEntity
            .status(HttpStatus.BAD_REQUEST)
            .body(ApiResponse(success = false, message = "Dữ liệu gửi lên sai định dạng JSON hoặc thiếu trường bắt buộc."))
    }

    /**
     * Bắt lỗi khi các trường dữ liệu không vượt qua validation (nếu dùng các annotation như @NotBlank, @Size).
     */
    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidationException(ex: MethodArgumentNotValidException): ResponseEntity<ApiResponse> {
        val firstError = ex.bindingResult.fieldErrors.firstOrNull()?.defaultMessage ?: "Dữ liệu không hợp lệ."
        return ResponseEntity
            .status(HttpStatus.BAD_REQUEST)
            .body(ApiResponse(success = false, message = firstError))
    }

    /**
     * Bắt lỗi khi gọi sai phương thức HTTP (ví dụ API là POST nhưng client lại gọi bằng GET).
     * Trả về HTTP 405 (Method Not Allowed).
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException::class)
    fun handleMethodNotSupported(ex: HttpRequestMethodNotSupportedException): ResponseEntity<ApiResponse> {
        return ResponseEntity
            .status(HttpStatus.METHOD_NOT_ALLOWED)
            .body(ApiResponse(success = false, message = "Phương thức HTTP không được hỗ trợ: ${ex.method}"))
    }

    /**
     * Lưới an toàn cuối cùng: Bắt tất cả các lỗi chưa lường trước khác (ví dụ: NullPointerException, lỗi DB, mất kết nối mạng server).
     * Trả về HTTP 500 (Internal Server Error) và ẩn đi các thông tin nhạy cảm của server.
     */
    @ExceptionHandler(Exception::class)
    fun handleGeneralException(ex: Exception): ResponseEntity<ApiResponse> {
        // Trong môi trường thật, ta sẽ ghi log lỗi này vào file log để lập trình viên theo dõi
        println("[SERVER ERROR LOG]: ${ex.javaClass.simpleName} - ${ex.message}")
        
        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ApiResponse(success = false, message = "Đã xảy ra lỗi nội bộ trên máy chủ. Vui lòng thử lại sau."))
    }
}
