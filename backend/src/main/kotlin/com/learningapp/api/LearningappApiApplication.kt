package com.learningapp.api

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

/**
 * =========================================================================================
 * [GIẢI THÍCH DÀNH CHO NGƯỜI HỌC CÓ NỀN TẢNG JAVA / PYTHON]:
 *
 * 1. @SpringBootApplication là gì?
 *    - Trong Java Spring Boot, đây là Annotation quan trọng nhất đại diện cho gốc của dự án.
 *    - Nó là sự kết hợp của 3 annotations:
 *      + @Configuration: Cho phép định nghĩa các Bean.
 *      + @EnableAutoConfiguration: Tự động cấu hình các thư viện (JPA, Mail, Security...) dựa trên các file JAR có trong dự án.
 *      + @ComponentScan: Tự động quét tìm tất cả các Controller, Service, Repository trong package này để nạp vào bộ nhớ.
 *
 * 2. fun main(args: Array<String>):
 *    - Điểm vào (Entry point) của toàn bộ ứng dụng Backend.
 *    - Tương đương:
 *      + Java: "public static void main(String[] args)"
 *      + Python: "if __name__ == '__main__':"
 *    - Hàm runApplication<...>(*args) sẽ khởi động máy chủ nhúng Tomcat (port 8080) và sẵn sàng đón nhận request.
 * =========================================================================================
 */
@SpringBootApplication
class LearningappApiApplication

fun main(args: Array<String>) {
	runApplication<LearningappApiApplication>(*args)
}
