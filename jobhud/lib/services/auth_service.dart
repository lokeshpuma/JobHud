import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Base URL for authentication API
  // For Android emulator: 10.0.2.2 points to the host machine
  // For physical devices: Use your machine's local IP address
  static const String _baseUrl = 'http://192.168.12.121:3001/api';

  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  
  // User data
  Map<String, dynamic>? _currentUser;
  String? _token;

  // Getters
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;
  String? get userId => _currentUser?['id']?.toString();
  String? get email => _currentUser?['email'];
  String? get displayName => _currentUser?['name'];

  // Initialize service with saved token
  AuthService() {
    loadUserData();
  }

  // Load saved user data and token
  Future<void> loadUserData() async {
    try {
      final prefs = await _prefs;
      final userData = prefs.getString('user_data');
      _token = prefs.getString('auth_token');
      
      if (userData != null) {
        _currentUser = Map<String, dynamic>.from(jsonDecode(userData));
      }
    } catch (e) {
      print('Error loading user data: $e');
      _currentUser = null;
      _token = null;
    }
  }

  // Save user data and token
  Future<void> _saveUserData(Map<String, dynamic> userData, String token) async {
    try {
      final prefs = await _prefs;
      await prefs.setString('user_data', jsonEncode(userData));
      await prefs.setString('auth_token', token);
      _currentUser = userData;
      _token = token;
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // Clear user data on logout
  Future<void> _clearUserData() async {
    try {
      final prefs = await _prefs;
      await prefs.remove('user_data');
      await prefs.remove('auth_token');
      _currentUser = null;
      _token = null;
    } catch (e) {
      print('Error clearing user data: $e');
      rethrow;
    }
  }
  
  // Register a new user
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final url = '$_baseUrl/auth/register';
      print('Attempting to register at: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        // Don't save user data here, just return the response
        // The user will need to login manually after registration
        return responseData;
      } else {
        throw Exception('Registration failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Registration error details:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Registration error: $e');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await _saveUserData(responseData, responseData['token']);
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _clearUserData();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      if (_token == null) throw Exception('Not authenticated');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await _saveUserData(responseData, _token!);
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      print('Get profile error: $e');
      rethrow;
    }
  }

  // Check if token is expired
  bool get _isTokenExpired {
    if (_token == null) return true;
    try {
      // Decode the token to check expiration
      final parts = _token!.split('.');
      if (parts.length != 3) return true;
      
      final payload = jsonDecode(utf8.decode(base64Url.decode(
        base64Url.normalize(parts[1]),
      )));
      
      final exp = payload['exp'] as int?;
      if (exp == null) return true;
      
      // Check if token is expired (with 5 second buffer)
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          .isBefore(DateTime.now().add(const Duration(seconds: 5)));
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
  }

  // Refresh the access token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await (await _prefs).getString('refresh_token');
      if (refreshToken == null) return false;
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await _saveUserData(responseData['user'], responseData['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Make authenticated request with token refresh
  Future<http.Response> _makeAuthenticatedRequest(
    String method,
    String path, {
    dynamic body,
    Map<String, String>? headers,
    bool retry = true,
  }) async {
    if (_token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl$path');
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
      ...?headers,
    };

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: requestHeaders);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // If token expired and we can retry, try to refresh the token
      if (response.statusCode == 401 && retry) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the request with the new token
          return _makeAuthenticatedRequest(
            method,
            path,
            body: body,
            headers: headers,
            retry: false, // Prevent infinite loops
          );
        } else {
          // If refresh fails, clear user data and throw exception
          await _clearUserData();
          throw Exception('Session expired. Please login again.');
        }
      }

      return response;
    } catch (e) {
      print('Request error: $e');
      rethrow;
    }
  }

  bool get isAuthenticated => _token != null && _currentUser != null && !_isTokenExpired;

  // Update user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      // Ensure we have the latest token and it's not expired
      await loadUserData();
      
      if (_token == null || _currentUser == null) {
        throw Exception('Please login to update your profile');
      }
      
      if (_isTokenExpired) {
        throw Exception('Session expired. Please login again.');
      }
      
      // Make a copy of current user data
      final currentUserData = Map<String, dynamic>.from(_currentUser!);
      
      // Prepare the data to send, ensuring required fields are included
      final dataToSend = {
        ...data,
        'id': currentUserData['id'],
        'email': currentUserData['email'],
      };
      
      // Make the API request
      final response = await http.put(
        Uri.parse('$_baseUrl/api/profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(dataToSend),
      ).timeout(const Duration(seconds: 30));

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Merge with existing data
        final updatedUserData = {
          ...currentUserData,
          ...responseData,
          'updatedAt': DateTime.now().toIso8601String(),
        };
        
        await _saveUserData(updatedUserData, _token!);
        return updatedUserData;
      } 
      // Handle unauthorized/expired token
      else if (response.statusCode == 401) {
        await _clearUserData();
        throw Exception('Session expired. Please login again.');
      } 
      // Handle other error responses
      else {
        try {
          final error = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(error['message'] ?? 'Failed to update profile');
        } catch (e) {
          throw Exception('Failed to update profile. Please try again.');
        }
      }
    } on http.ClientException catch (e) {
      print('Network error: $e');
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      print('Update error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _makeAuthenticatedRequest('GET', '/auth/me');
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await _saveUserData(responseData, _token!);
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      print('Get profile error: $e');
      rethrow;
    }
  }
}
