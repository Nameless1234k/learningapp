package com.learningapp.api.dto.auth

data class VerifyOtpRequest(
    val email: String,
    val otp: String
)

