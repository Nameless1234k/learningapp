class ApiEndpoints {
  // Base URL for the backend API
  // Sử dụng localhost cho máy ảo Android, hoặc IP của máy tính (vd: 192.168.1.x) khi test trên thiết bị thật
  static const String baseUrl = 'http://192.168.252.18:8080/api'; 
  
  // Auth endpoints
  static const String loginAPI = '$baseUrl/auth/login';
  static const String registerAPI = '$baseUrl/auth/register';
  static const String forgotPasswordAPI = '$baseUrl/auth/forgot-password';
  static const String verifyOtpAPI = '$baseUrl/auth/verify-otp';
  static const String resetPasswordAPI = '$baseUrl/auth/reset-password';
}
