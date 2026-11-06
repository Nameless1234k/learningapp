package com.learningapp.api.util

/**
 * =========================================================================================
 * [TÊN FILE: ValidationUtil.kt]
 * [VỊ TRÍ]: backend/src/main/kotlin/com/learningapp/api/util/ValidationUtil.kt
 * [MỤC ĐÍCH]: Bộ kiểm tra tính hợp lệ dữ liệu (Validator Helper) tập trung cho toàn Backend:
 * - Tối ưu hóa code (DRY - Don't Repeat Yourself): Cung cấp các hàm kiểm tra chỉ bằng 1 dòng.
 * - Đồng bộ hóa điều kiện kiểm tra và Exception giữa chức năng Đăng ký (Register), Đặt lại mật khẩu (Reset Password)
 *   và Cập nhật thông tin cá nhân / Đổi mật khẩu (Profile).
 * =========================================================================================
 */
object ValidationUtil {

    private val emailRegex = "^[A-Za-z0-9._%+-]+@gmail\\.com$".toRegex()
    private val phoneRegex = "^[0-9]{9,11}$".toRegex()

    /**
     * 1. Kiểm tra các trường bắt buộc không được null hoặc rỗng
     */
    fun validateRequired(vararg fields: Pair<String, String?>) {
        for ((_, value) in fields) {
            if (value.isNullOrBlank()) {
                throw IllegalArgumentException("Vui lòng nhập đầy đủ thông tin")
            }
        }
    }

    /**
     * 2. Kiểm tra Họ và Tên (dùng chung cho cả Đăng ký và Cập nhật hồ sơ)
     * - Bắt buộc nhập đầy đủ (Họ và Tên không được rỗng)
     * - Giới hạn độ dài theo Schema DB (Họ tối đa 80, Tên tối đa 50)
     */
    fun validateNames(firstName: String?, lastName: String?) {
        if (firstName.isNullOrBlank() || lastName.isNullOrBlank()) {
            throw IllegalArgumentException("Vui lòng nhập đầy đủ thông tin")
        }
        if (lastName.trim().length > 80) {
            throw IllegalArgumentException("Họ và tên đệm không được vượt quá 80 ký tự!")
        }
        if (firstName.trim().length > 50) {
            throw IllegalArgumentException("Tên không được vượt quá 50 ký tự!")
        }
    }

    /**
     * 3. Kiểm tra định dạng Email
     */
    fun validateEmail(email: String?) {
        val trimmed = email?.trim()
        if (trimmed.isNullOrEmpty()) {
            throw IllegalArgumentException("Vui lòng nhập đầy đủ thông tin")
        }
        if (!emailRegex.matches(trimmed)) {
            throw IllegalArgumentException("Email không đúng định dạng!")
        }
    }

    /**
     * 4. Kiểm tra số điện thoại (nếu người dùng có nhập)
     */
    fun validatePhone(phone: String?) {
        val trimmed = phone?.trim()
        if (!trimmed.isNullOrEmpty() && !phoneRegex.matches(trimmed)) {
            throw IllegalArgumentException("Số điện thoại không hợp lệ (9 - 11 chữ số)!")
        }
    }

    /**
     * 5. Kiểm tra mật khẩu (độ dài tối thiểu 8 ký tự theo đúng chuẩn Đăng ký)
     */
    fun validatePassword(password: String?) {
        if (password.isNullOrBlank()) {
            throw IllegalArgumentException("Vui lòng nhập đầy đủ thông tin")
        }
        if (password.length < 8) {
            throw IllegalArgumentException("Mật khẩu phải dài ít nhất 8 ký tự")
        }
    }

    /**
     * 6. Kiểm tra mật khẩu xác nhận phải trùng khớp
     */
    fun validatePasswordMatch(password: String?, confirmPassword: String?) {
        if (password != confirmPassword) {
            throw IllegalArgumentException("Mật khẩu xác nhận không khớp")
        }
    }
}
