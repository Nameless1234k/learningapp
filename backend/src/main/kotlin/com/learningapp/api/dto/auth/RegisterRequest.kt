package com.learningapp.api.dto.auth

data class RegisterRequest(
    val firstName: String,
    val lastName: String,
    val email: String,
    val phone: String?,
    val password: String
)

