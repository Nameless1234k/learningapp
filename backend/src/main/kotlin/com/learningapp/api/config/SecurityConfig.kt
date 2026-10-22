package com.learningapp.api.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.web.SecurityFilterChain

// =========================================================================================
// [GIẢI THÍCH DÀNH CHO NGƯỜI HỌC CÓ NỀN TẢNG JAVA / PYTHON]:
//
// 1. @Configuration là gì?
//    - Báo cho Spring Boot biết đây là một file CẤU HÌNH (Configuration Class).
//    - Spring sẽ đọc file này khi khởi động và tạo các Bean cần thiết vào Spring Container (IoC Container).
//
// 2. @Bean là gì?
//    - Tương tự như việc bạn viết một hàm khởi tạo object và đăng ký vào bộ nhớ chung của ứng dụng.
//    - Bất kỳ class nào khác (như AuthService) cần PasswordEncoder thì Spring sẽ tự lấy Bean này đưa vào.
//
// 3. Spring Security:
//    - Khung bảo mật tiêu chuẩn công nghiệp của hệ sinh thái Java/Spring.
//    - Quản lý việc băm mật khẩu, phân quyền truy cập endpoint và cấu hình CORS / CSRF.
// =========================================================================================

@Configuration
@EnableWebSecurity
class SecurityConfig {

    // Khởi tạo Bean mã hóa mật khẩu bằng thuật toán BCrypt.
    // BCrypt tự động thêm muối (Salt) ngẫu nhiên vào mật khẩu, chống tấn công Rainbow Table.
    @Bean
    fun passwordEncoder(): PasswordEncoder {
        return BCryptPasswordEncoder()
    }

    // Cấu hình CORS chi tiết cho phép mọi nguồn (Origin), mọi phương thức (GET, POST, OPTIONS, HEAD...)
    // Giúp Flutter Web và các thiết bị di động truy cập API và tải file PDF không bị chặn bởi trình duyệt
    @Bean
    fun corsConfigurationSource(): org.springframework.web.cors.CorsConfigurationSource {
        val configuration = org.springframework.web.cors.CorsConfiguration()
        // Cho phép tất cả các nguồn gọi đến (bao gồm Flutter Web localhost và IP thiết bị di động)
        configuration.allowedOriginPatterns = listOf("*")
        // Cho phép đầy đủ các phương thức HTTP cần thiết
        configuration.allowedMethods = listOf("GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD")
        // Cho phép tất cả các header được gửi lên
        configuration.allowedHeaders = listOf("*")
        // Cho phép gửi kèm cookie hoặc thông tin xác thực nếu có
        configuration.allowCredentials = true

        // Đăng ký cấu hình CORS áp dụng cho tất cả các đường dẫn API
        val source = org.springframework.web.cors.UrlBasedCorsConfigurationSource()
        source.registerCorsConfiguration("/**", configuration)
        return source
    }

    // Cấu hình chuỗi lọc bảo mật (Security Filter Chain) cho các yêu cầu HTTP:
    // - Tắt CSRF (vì API RESTful dùng JWT, không dùng Session Cookie nên không sợ CSRF).
    // - Bật CORS để cho phép ứng dụng Flutter gọi API.
    // - Tắt X-Frame-Options để hỗ trợ hiển thị xem trước PDF trên web.
    // - Mở quyền truy cập tự do vào các API xác thực tài khoản và tài liệu.
    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        http
            // Tắt kiểm tra CSRF token cho các API không trạng thái (stateless REST API)
            .csrf { it.disable() }
            // Kích hoạt CORS sử dụng cấu hình chi tiết phía trên
            .cors { it.configurationSource(corsConfigurationSource()) }
            // Tắt header X-Frame-Options để cho phép trình duyệt hiển thị PDF nhúng
            .headers { headers ->
                headers.frameOptions { it.disable() }
            }
            // Cấu hình phân quyền theo đường dẫn URL
            .authorizeHttpRequests { auth ->
                // Cho phép tất cả mọi người truy cập các route auth mà không cần đăng nhập trước
                auth.requestMatchers("/api/auth/**").permitAll()
                // Cho phép truy cập file tài liệu PDF
                auth.requestMatchers("/api/documents/**").permitAll()
                // Cho phép truy cập danh sách môn học và bài học
                auth.requestMatchers("/api/subjects/**").permitAll()
                // Cho phép truy cập API Quản trị Admin
                auth.requestMatchers("/api/admin/**").permitAll()
                // Trong giai đoạn phát triển, cho phép tất cả các route khác
                auth.anyRequest().permitAll()
            }
        return http.build()
    }
}
