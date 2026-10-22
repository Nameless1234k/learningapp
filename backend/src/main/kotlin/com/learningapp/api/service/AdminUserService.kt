package com.learningapp.api.service

import com.learningapp.api.dto.ApiResponse
import com.learningapp.api.dto.admin.AdminUserDTO
import com.learningapp.api.entity.User
import com.learningapp.api.repository.UserRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.format.DateTimeFormatter
import java.util.UUID

@Service
class AdminUserService(
    private val userRepository: UserRepository
) {
    private val dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")

    private fun toDTO(user: User): AdminUserDTO {
        return AdminUserDTO(
            id = user.id!!,
            lastName = user.lastName,
            firstName = user.firstName,
            fullName = "${user.lastName} ${user.firstName}".trim(),
            email = user.email,
            phone = user.phone,
            role = user.role,
            isActive = user.isActive,
            createdAt = user.createdAt.format(dateFormatter)
        )
    }

    /**
     * Lấy danh sách tài khoản, có hỗ trợ tìm kiếm theo từ khóa (họ tên, email, sđt)
     * Sắp xếp: Tài khoản ADMIN luôn đứng đầu, sau đó sắp xếp theo ngày tạo sớm nhất (tăng dần)
     */
    fun getUsers(keyword: String?): List<AdminUserDTO> {
        val users = if (keyword.isNullOrBlank()) {
            userRepository.findAll()
        } else {
            userRepository.searchUsers(keyword.trim())
        }
        val dtos = users.map { toDTO(it) }
        return dtos.sortedWith(
            compareByDescending<AdminUserDTO> { it.role.equals("ADMIN", ignoreCase = true) }
                .thenBy { it.createdAt }
        )
    }

    /**
     * Cập nhật trạng thái Hoạt động / Khóa cho 1 tài khoản
     */
    @Transactional
    fun updateStatus(id: UUID, isActive: Boolean): AdminUserDTO {
        val user = userRepository.findById(id).orElseThrow {
            IllegalArgumentException("Không tìm thấy người dùng với ID: $id")
        }
        if (user.role.equals("ADMIN", ignoreCase = true)) {
            throw IllegalArgumentException("Không thể thay đổi trạng thái của tài khoản Quản trị viên (ADMIN)!")
        }
        user.isActive = isActive
        val saved = userRepository.save(user)
        return toDTO(saved)
    }

    /**
     * Cập nhật trạng thái cho nhiều tài khoản cùng lúc (loại trừ ADMIN)
     */
    @Transactional
    fun bulkUpdateStatus(ids: List<UUID>, isActive: Boolean): ApiResponse {
        val users = userRepository.findAllById(ids).filter { !it.role.equals("ADMIN", ignoreCase = true) }
        users.forEach { it.isActive = isActive }
        userRepository.saveAll(users)
        return ApiResponse(true, "Đã cập nhật trạng thái cho ${users.size} tài khoản.")
    }

    /**
     * Xóa 1 tài khoản (bảo vệ tài khoản ADMIN)
     */
    @Transactional
    fun deleteUser(id: UUID): ApiResponse {
        val user = userRepository.findById(id).orElseThrow {
            IllegalArgumentException("Không tìm thấy người dùng với ID: $id")
        }
        if (user.role.equals("ADMIN", ignoreCase = true)) {
            throw IllegalArgumentException("Không thể xóa tài khoản Quản trị viên (ADMIN)!")
        }
        userRepository.deleteById(id)
        return ApiResponse(true, "Đã xóa tài khoản thành công.")
    }

    /**
     * Xóa nhiều tài khoản cùng lúc (loại trừ ADMIN)
     */
    @Transactional
    fun bulkDelete(ids: List<UUID>): ApiResponse {
        val users = userRepository.findAllById(ids).filter { !it.role.equals("ADMIN", ignoreCase = true) }
        userRepository.deleteAll(users)
        return ApiResponse(true, "Đã xóa thành công ${users.size} tài khoản.")
    }
}
