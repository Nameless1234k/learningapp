import '../config/api_endpoints.dart';

// =========================================================================================
// [TÊN FILE: url_helper.dart]
// [VỊ TRÍ]: lib/utils/url_helper.dart
// [MỤC ĐÍCH]: Tiện ích chuẩn hóa và phân giải đường dẫn URL cho toàn bộ ứng dụng.
// - Tách riêng phần xử lý chuỗi và logic URL ra khỏi cấu hình hằng số (ApiEndpoints).
// - Đảm bảo URL tải file PDF từ Backend luôn là đường dẫn tuyệt đối, chỉ có duy nhất 1 tiền tố /api.
// =========================================================================================

class UrlHelper {
  /// Lấy server origin (loại bỏ phần đuôi '/api' của baseUrl nếu có)
  static String get serverOrigin {
    final base = ApiEndpoints.baseUrl;
    if (base.endsWith('/api')) {
      return base.substring(0, base.length - 4);
    }
    return base;
  }

  /// Hàm tạo link tải PDF tuyệt đối, đảm bảo luôn luôn chỉ có DUY NHẤT 1 tiền tố /api
  static String getFullPdfUrl(String pdfPath) {
    final trimmed = pdfPath.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final clean = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    if (clean.startsWith('/api/')) {
      return '$serverOrigin$clean';
    }
    return '${ApiEndpoints.baseUrl}$clean';
  }
}
