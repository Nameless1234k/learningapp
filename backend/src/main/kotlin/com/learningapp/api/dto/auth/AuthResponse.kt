package com.learningapp.api.dto.auth

data class AuthResponse(
    val token: String,
    val userId: String,
    val email: String,
    val fullName: String
)

