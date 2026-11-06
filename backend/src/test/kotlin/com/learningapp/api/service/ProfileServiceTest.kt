package com.learningapp.api.service

import com.learningapp.api.dto.profile.ChangePasswordRequest
import com.learningapp.api.dto.profile.UpdateProfileRequest
import com.learningapp.api.entity.User
import com.learningapp.api.repository.UserRepository
import com.learningapp.api.repository.UserSettingRepository
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.security.crypto.password.PasswordEncoder
import java.util.Optional
import java.util.UUID

@ExtendWith(MockitoExtension::class)
class ProfileServiceTest {

    @Mock
    private lateinit var userRepository: UserRepository

    @Mock
    private lateinit var userSettingRepository: UserSettingRepository

    @Mock
    private lateinit var passwordEncoder: PasswordEncoder

    @InjectMocks
    private lateinit var profileService: ProfileService

    private val userId: UUID = UUID.randomUUID()
    private lateinit var sampleUser: User

    @BeforeEach
    fun setUp() {
        sampleUser = User(
            id = userId,
            firstName = "Huy",
            lastName = "Le Anh",
            email = "huy@gmail.com",
            phone = "0912345678",
            passwordHash = "encoded_old_password"
        )
    }

    @Test
    @DisplayName("TC01 - Cập nhật thất bại khi để trống Tên (giống Đăng ký)")
    fun testUpdateProfile_EmptyFirstName_ThrowsException() {
        `when`(userRepository.findById(userId)).thenReturn(Optional.of(sampleUser))

        val request = UpdateProfileRequest(firstName = "", lastName = "Le Anh", phone = "0912345678")

        val ex = assertThrows(IllegalArgumentException::class.java) {
            profileService.updateProfile(userId, request)
        }
        assertEquals("Vui lòng nhập đầy đủ thông tin", ex.message)
    }

    @Test
    @DisplayName("TC02 - Cập nhật thất bại khi để trống Họ và tên đệm (giống Đăng ký)")
    fun testUpdateProfile_EmptyLastName_ThrowsException() {
        `when`(userRepository.findById(userId)).thenReturn(Optional.of(sampleUser))

        val request = UpdateProfileRequest(firstName = "Huy", lastName = "", phone = "0912345678")

        val ex = assertThrows(IllegalArgumentException::class.java) {
            profileService.updateProfile(userId, request)
        }
        assertEquals("Vui lòng nhập đầy đủ thông tin", ex.message)
    }

    @Test
    @DisplayName("TC03 - Cập nhật thất bại khi Số điện thoại không đúng định dạng")
    fun testUpdateProfile_InvalidPhone_ThrowsException() {
        `when`(userRepository.findById(userId)).thenReturn(Optional.of(sampleUser))

        val request = UpdateProfileRequest(firstName = "Huy", lastName = "Le Anh", phone = "123")

        val ex = assertThrows(IllegalArgumentException::class.java) {
            profileService.updateProfile(userId, request)
        }
        assertEquals("Số điện thoại không hợp lệ (9 - 11 chữ số)!", ex.message)
    }

    @Test
    @DisplayName("TC04 - Đổi mật khẩu thất bại khi để trống trường bắt buộc")
    fun testChangePassword_EmptyField_ThrowsException() {
        `when`(userRepository.findById(userId)).thenReturn(Optional.of(sampleUser))

        val request = ChangePasswordRequest(oldPassword = "", newPassword = "Password@123", confirmPassword = "Password@123")

        val ex = assertThrows(IllegalArgumentException::class.java) {
            profileService.changePassword(userId, request)
        }
        assertEquals("Vui lòng nhập đầy đủ thông tin", ex.message)
    }

    @Test
    @DisplayName("TC05 - Đổi mật khẩu thất bại khi mật khẩu mới dưới 8 ký tự (giống Đăng ký)")
    fun testChangePassword_ShortPassword_ThrowsException() {
        `when`(userRepository.findById(userId)).thenReturn(Optional.of(sampleUser))

        val request = ChangePasswordRequest(oldPassword = "OldPassword@123", newPassword = "short", confirmPassword = "short")

        val ex = assertThrows(IllegalArgumentException::class.java) {
            profileService.changePassword(userId, request)
        }
        assertEquals("Mật khẩu phải dài ít nhất 8 ký tự", ex.message)
    }

    @Test
    @DisplayName("TC06 - Đổi mật khẩu thất bại khi mật khẩu xác nhận không khớp")
    fun testChangePassword_PasswordMismatch_ThrowsException() {
        `when`(userRepository.findById(userId)).thenReturn(Optional.of(sampleUser))

        val request = ChangePasswordRequest(oldPassword = "OldPassword@123", newPassword = "Password@123", confirmPassword = "DifferentPassword@123")

        val ex = assertThrows(IllegalArgumentException::class.java) {
            profileService.changePassword(userId, request)
        }
        assertEquals("Mật khẩu xác nhận không khớp", ex.message)
    }

    @Test
    @DisplayName("TC07 - Đổi mật khẩu thất bại khi mật khẩu hiện tại không chính xác")
    fun testChangePassword_WrongOldPassword_ThrowsException() {
        `when`(userRepository.findById(userId)).thenReturn(Optional.of(sampleUser))
        `when`(passwordEncoder.matches("WrongOldPassword", sampleUser.passwordHash)).thenReturn(false)

        val request = ChangePasswordRequest(oldPassword = "WrongOldPassword", newPassword = "NewPassword@123", confirmPassword = "NewPassword@123")

        val ex = assertThrows(IllegalArgumentException::class.java) {
            profileService.changePassword(userId, request)
        }
        assertEquals("Mật khẩu hiện tại không chính xác!", ex.message)
    }

    @Test
    @DisplayName("TC08 - Đổi mật khẩu thất bại khi mật khẩu mới trùng mật khẩu cũ")
    fun testChangePassword_SamePassword_ThrowsException() {
        `when`(userRepository.findById(userId)).thenReturn(Optional.of(sampleUser))
        `when`(passwordEncoder.matches("SamePassword@123", sampleUser.passwordHash)).thenReturn(true)

        val request = ChangePasswordRequest(oldPassword = "SamePassword@123", newPassword = "SamePassword@123", confirmPassword = "SamePassword@123")

        val ex = assertThrows(IllegalArgumentException::class.java) {
            profileService.changePassword(userId, request)
        }
        assertEquals("Mật khẩu mới không được trùng với mật khẩu cũ!", ex.message)
    }
}
