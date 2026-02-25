import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobhud/models/culture_preference_model.dart';

class CulturePreferenceService extends ChangeNotifier {
  static const String _prefsKey = 'culture_preferences';
  CulturePreference? _preferences;
  bool _hasCompletedQuiz = false;

  CulturePreference? get preferences => _preferences;
  bool get hasCompletedQuiz => _hasCompletedQuiz;

  // Initialize and load preferences
  Future<void> initialize() async {
    await loadPreferences();
  }

  // Load preferences from storage
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString(_prefsKey);
      
      if (prefsJson != null) {
        final Map<String, dynamic> prefsMap = json.decode(prefsJson);
        _preferences = CulturePreference.fromMap(prefsMap);
        _hasCompletedQuiz = true;
      } else {
        _hasCompletedQuiz = false;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading culture preferences: $e');
      _hasCompletedQuiz = false;
    }
  }

  // Save preferences to storage
  Future<void> savePreferences(CulturePreference preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = json.encode(preferences.toMap());
      await prefs.setString(_prefsKey, prefsJson);
      
      _preferences = preferences;
      _hasCompletedQuiz = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving culture preferences: $e');
      throw Exception('Failed to save preferences');
    }
  }

  // Update existing preferences
  Future<void> updatePreferences(CulturePreference preferences) async {
    await savePreferences(preferences.copyWith(updatedAt: DateTime.now()));
  }

  // Clear preferences (for testing or reset)
  Future<void> clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      
      _preferences = null;
      _hasCompletedQuiz = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing culture preferences: $e');
    }
  }

  // Calculate match score for a job
  int calculateJobMatchScore(List<CultureTag> jobTags) {
    if (_preferences == null) return 50; // Default score
    return _preferences!.calculateMatchScore(jobTags);
  }

  // Get match breakdown for a job
  Map<String, List<CultureTag>> getMatchBreakdown(List<CultureTag> jobTags) {
    if (_preferences == null) {
      return {'matches': [], 'mismatches': []};
    }
    return _preferences!.getMatchBreakdown(jobTags);
  }

  // Get color based on match score
  static String getMatchColor(int score) {
    if (score >= 80) return 'green';
    if (score >= 60) return 'lightGreen';
    if (score >= 40) return 'orange';
    return 'red';
  }

  // Get emoji based on match score
  static String getMatchEmoji(int score) {
    if (score >= 80) return '🟢';
    if (score >= 60) return '🟡';
    if (score >= 40) return '🟠';
    return '🔴';
  }
}
