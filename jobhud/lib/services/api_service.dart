import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for iOS simulator, or your machine's IP for physical devices
  static const String baseUrl = 'http://192.168.12.122:3001';
  
  // Helper method to handle API responses
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // In a real app, this would validate credentials with the backend
    // For now, we'll just return a success response with a mock user ID
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return {
      'success': true,
      'userId': 'user_${email.hashCode}',
      'email': email,
      'displayName': email.split('@')[0],
    };
  }

  // Profile endpoints
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/profile/$userId'));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateProfile(
      String userId, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/profile/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // Add other API methods as needed
}
