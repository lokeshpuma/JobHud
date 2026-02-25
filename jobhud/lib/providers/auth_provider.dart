import 'package:flutter/foundation.dart';
import 'package:jobhud/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool get isAuthenticated => _authService.token != null;
  String? get token => _authService.token;
  String? get userId => _authService.userId;
  String? get email => _authService.email;
  String? get displayName => _authService.displayName;
  Map<String, dynamic>? get user => _authService.currentUser;
  
  // Initialize auth state
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // This will load any saved token and user data
      await _authService.loadUserData();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }
  
  // Register a new user
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final userData = await _authService.register(name, email, password);
      notifyListeners();
      return userData;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out user
  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
  
  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final userData = await _authService.login(email, password);
      notifyListeners();
      return userData;
    } catch (e) {
      rethrow;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      await _authService.signOut();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      return await _authService.getUserProfile();
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      // Ensure we have the latest user data
      await _authService.loadUserData();
      
      if (!_authService.isAuthenticated) {
        throw Exception('Please login to update your profile');
      }
      
      try {
        // Let AuthService handle token refresh if needed
        final updatedProfile = await _authService.updateProfile(data);
        notifyListeners();
        return updatedProfile;
      } catch (e) {
        // If we get here, AuthService already tried to refresh the token and failed
        print('Profile update failed after token refresh: $e');
        
        // Only sign out if it's definitely an auth error
        if (e.toString().contains('expired') || 
            e.toString().contains('token') || 
            e.toString().contains('auth') ||
            e.toString().contains('401') ||
            e.toString().contains('403')) {
          await _authService.signOut();
          notifyListeners();
          throw Exception('Session expired. Please login again.');
        }
        
        // For other errors, just rethrow with a user-friendly message
        throw Exception('Failed to update profile. Please try again.');
      }
    } catch (e) {
      print('Error in updateProfile: $e');
      rethrow;
    }
  }
}
