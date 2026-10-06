package com.learningapp.api.constant

/**
 * Nơi tập trung toàn bộ các endpoint của API để dễ dàng quản lý và chỉnh sửa (fix bug) sau này.
 */
object ApiEndpoints {
    const val BASE_API = "/api"

    object Auth {
        const val BASE = "$BASE_API/auth"
        const val REGISTER = "/register"
        const val LOGIN = "/login"
        const val FORGOT_PASSWORD = "/forgot-password"
        const val VERIFY_OTP = "/verify-otp"
        const val RESET_PASSWORD = "/reset-password"
    }
}

