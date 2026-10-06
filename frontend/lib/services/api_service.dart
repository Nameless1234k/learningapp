
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ghi chú: Chúng ta sử dụng 'localhost' vì Flutter đang chạy trên Chrome web
  static const String baseUrl = 'http://localhost:8080/api'; 

  Future<Map<String, dynamic>> fetchTestData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/test/hello'));

      if (response.statusCode == 200) {
        // Giải mã JSON nhận được từ Backend
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load API data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}