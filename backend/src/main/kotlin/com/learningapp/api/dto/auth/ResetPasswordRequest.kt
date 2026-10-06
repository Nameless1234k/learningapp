package com.learningapp.api.dto.auth

data class ResetPasswordRequest(
    val email: String,
    val newPassword: String
)

