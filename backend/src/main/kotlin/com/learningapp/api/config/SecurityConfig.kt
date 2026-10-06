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

    // Cấu hình chuỗi lọc bảo mật (Security Filter Chain) cho các yêu cầu HTTP:
    // - Tắt CSRF (vì API RESTful dùng JWT, không dùng Session Cookie nên không sợ CSRF).
    // - Bật CORS để cho phép ứng dụng Flutter gọi API.
    // - Mở quyền truy cập tự do vào các API xác thực tài khoản.
    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        http
            // Tắt kiểm tra CSRF token cho các API không trạng thái (stateless REST API)
            .csrf { it.disable() }
            // Kích hoạt CORS (Cross-Origin Resource Sharing)
            .cors { it.configure(http) }
            // Cấu hình phân quyền theo đường dẫn URL
            .authorizeHttpRequests { auth ->
                // Cho phép tất cả mọi người truy cập các route auth mà không cần đăng nhập trước
                auth.requestMatchers("/api/auth/**").permitAll()
                // Trong giai đoạn phát triển, cho phép tất cả các route khác
                auth.anyRequest().permitAll()
            }
        return http.build()
    }
}
