# Learning App

Ứng dụng Flutter học tập. Mã nguồn ứng dụng nằm trong `lib/`.

## Cấu trúc và vai trò

| Thư mục/file | Vai trò | Kết nối chính |
| --- | --- | --- |
| `lib/main.dart` | Khởi động Flutter, cấu hình theme và màn hình đầu tiên | `screens/login_screen.dart` |
| `lib/screens/` | Màn hình và UI state: nhận thao tác, loading, SnackBar, điều hướng | Gọi `controllers/`, hiển thị `widgets/` |
| `lib/controllers/` | Xử lý nghiệp vụ/kiểm tra dữ liệu, gọi service và trả kết quả cho screen | Gọi `services/auth_service.dart` |
| `lib/services/` | Gửi HTTP request, mã hóa/giải mã JSON và báo lỗi từ backend | Dùng URL trong `config/api_endpoints.dart` |
| `lib/config/api_endpoints.dart` | Khai báo base URL và các endpoint backend | Được `AuthService` sử dụng |
| `lib/widgets/` | Widget giao diện dùng lại ở nhiều màn hình | Được import bởi các screen |

### Luồng đăng nhập

`main.dart` -> `LoginScreen` -> `LoginController` -> `AuthService` -> `ApiEndpoints` -> backend.

Controller không nhận `BuildContext`, không hiển thị UI và không điều hướng. Screen nhận kết quả controller để cập nhật loading, hiển thị thông báo và chuyển màn hình. Các widget dùng chung như `CustomTextField`, `PrimaryButton`, `InputLabel` và `AuthHeader` được đặt trong `lib/widgets/`.

### Luồng quên mật khẩu

`ForgotPasswordScreen` -> `ForgotPasswordController` -> `AuthService.forgotPassword` -> `VerifyOtpScreen` -> `VerifyOtpController` -> `AuthService.verifyOtp` -> `ResetPasswordScreen` -> `ResetPasswordController` -> `AuthService.resetPassword`.

Screen giữ việc điều hướng giữa các bước; controller chỉ trả `null` nếu thành công hoặc chuỗi lỗi nếu thất bại.

## Tìm nhanh trong code

Chạy các lệnh sau từ thư mục gốc project trong PowerShell:

```powershell
# Liệt kê toàn bộ mã Dart trong lib
Get-ChildItem .\lib -Recurse -Filter *.dart

# Tìm nơi khai báo/gọi một controller, service hoặc widget
rg "ForgotPasswordController|AuthService|PrimaryButton" .\lib

# Tìm các endpoint và nơi gọi API
rg "ApiEndpoints|forgotPassword|verifyOtp|resetPassword" .\lib
```

## Lệnh phát triển và kiểm tra

```powershell
# Cài/cập nhật dependencies theo pubspec.lock
flutter pub get

# Chạy ứng dụng trên thiết bị/emulator đang chọn
flutter run

# Kiểm tra lỗi và lint Dart/Flutter trong project
flutter analyze

# Chạy unit/widget tests (nếu project có tests)
flutter test
```

## Cấu hình backend

Sửa `lib/config/api_endpoints.dart` để thay `baseUrl` theo môi trường chạy. Kiểm tra địa chỉ host phù hợp với web, Android emulator hoặc thiết bị thật; không mặc định `localhost` sẽ trỏ đến máy backend trên mọi thiết bị.
