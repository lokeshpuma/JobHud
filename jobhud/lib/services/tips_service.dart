import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:jobhud/models/career_tip_model.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class TipsService {
  // Base URL for API requests with fallback to local tips
  static const String _baseUrl = 'http://192.168.12.122:3001/api/tips';
  static const bool _useLocalTips = true; // Set to false to try the remote server
  
  // Local fallback tips - 25 unique career tips
  static final List<Map<String, dynamic>> _localTips = [
    // Networking Tips
    {
      'id': 1,
      'title': 'Professional Networking',
      'tip': 'Attend at least one industry event per month and follow up with 3 new contacts from each event.',
      'category': 'networking',
      'icon': 'people',
    },
    {
      'id': 2,
      'title': 'LinkedIn Strategy',
      'tip': 'Regularly update your LinkedIn profile and engage with content in your industry to increase visibility.',
      'category': 'networking',
      'icon': 'people',
    },
    
    // Resume & Application Tips
    {
      'id': 3,
      'title': 'Resume Customization',
      'tip': 'Tailor your resume for each application by including keywords from the job description.',
      'category': 'resume',
      'icon': 'description',
    },
    {
      'id': 4,
      'title': 'Cover Letter Impact',
      'tip': 'Write personalized cover letters that connect your experience to the specific role requirements.',
      'category': 'resume',
      'icon': 'description',
    },
    
    // Interview Preparation
    {
      'id': 5,
      'title': 'STAR Technique',
      'tip': 'Use the STAR method (Situation, Task, Action, Result) to structure your interview responses.',
      'category': 'interview',
      'icon': 'videocam',
    },
    {
      'id': 6,
      'title': 'Research Companies',
      'tip': 'Thoroughly research the company and interviewers before your interview to ask insightful questions.',
      'category': 'interview',
      'icon': 'search',
    },
    
    // Skill Development
    {
      'id': 7,
      'title': 'Skill Enhancement',
      'tip': 'Dedicate 2-3 hours weekly to learning new skills relevant to your target roles.',
      'category': 'skills',
      'icon': 'school',
    },
    {
      'id': 8,
      'title': 'Certification Value',
      'tip': 'Pursue industry-recognized certifications to validate your expertise and stand out.',
      'category': 'skills',
      'icon': 'badge',
    },
    
    // Job Search Strategy
    {
      'id': 9,
      'title': 'Targeted Applications',
      'tip': 'Focus on quality over quantity - tailor each application instead of mass applying.',
      'category': 'job_search',
      'icon': 'search',
    },
    {
      'id': 10,
      'title': 'Informational Interviews',
      'tip': 'Request informational interviews to learn about roles and companies from current employees.',
      'category': 'job_search',
      'icon': 'people',
    },
    
    // Personal Branding
    {
      'id': 11,
      'title': 'Online Presence',
      'tip': 'Maintain a professional online presence across all platforms, especially LinkedIn.',
      'category': 'branding',
      'icon': 'public',
    },
    {
      'id': 12,
      'title': 'Portfolio Development',
      'tip': 'Create an online portfolio showcasing your best work and achievements.',
      'category': 'branding',
      'icon': 'work',
    },
    
    // Career Growth
    {
      'id': 13,
      'title': 'Mentorship',
      'tip': 'Seek out mentors who can provide guidance and advice for your career growth.',
      'category': 'growth',
      'icon': 'psychology',
    },
    {
      'id': 14,
      'title': 'Goal Setting',
      'tip': 'Set SMART (Specific, Measurable, Achievable, Relevant, Time-bound) career goals.',
      'category': 'growth',
      'icon': 'flag',
    },
    
    // Workplace Success
    {
      'id': 15,
      'title': 'Effective Communication',
      'tip': 'Develop strong written and verbal communication skills for workplace success.',
      'category': 'workplace',
      'icon': 'chat',
    },
    {
      'id': 16,
      'title': 'Time Management',
      'tip': 'Use productivity techniques like time blocking to manage your workload effectively.',
      'category': 'workplace',
      'icon': 'schedule',
    },
    
    // Additional Tips
    {
      'id': 17,
      'title': 'Salary Research',
      'tip': 'Research industry salary standards before negotiating your compensation package.',
      'category': 'negotiation',
      'icon': 'attach_money',
    },
    {
      'id': 18,
      'title': 'Professional Development',
      'tip': 'Attend workshops and webinars to stay current with industry trends and best practices.',
      'category': 'growth',
      'icon': 'trending_up',
    },
    {
      'id': 19,
      'title': 'Work-Life Balance',
      'tip': 'Maintain a healthy work-life balance to prevent burnout and sustain long-term success.',
      'category': 'wellness',
      'icon': 'self_improvement',
    },
    {
      'id': 20,
      'title': 'Feedback Reception',
      'tip': 'Actively seek and be open to constructive feedback to support your professional growth.',
      'category': 'growth',
      'icon': 'feedback',
    },
    {
      'id': 21,
      'title': 'Industry Trends',
      'tip': 'Stay informed about emerging technologies and trends in your field through industry publications.',
      'category': 'industry',
      'icon': 'trending_up',
    },
    {
      'id': 22,
      'title': 'Professional Associations',
      'tip': 'Join relevant professional associations to expand your network and access resources.',
      'category': 'networking',
      'icon': 'groups',
    },
    {
      'id': 23,
      'title': 'Career Transitions',
      'tip': 'Leverage transferable skills when considering a career change to a new industry.',
      'category': 'transition',
      'icon': 'compare_arrows',
    },
    {
      'id': 24,
      'title': 'Personal Projects',
      'tip': 'Work on personal projects to demonstrate initiative and practical application of skills.',
      'category': 'portfolio',
      'icon': 'code',
    },
    {
      'id': 25,
      'title': 'Professional Etiquette',
      'tip': 'Practice professional etiquette in all communications and interactions.',
      'category': 'workplace',
      'icon': 'handshake',
    },
  ];

  // Get daily career tips (multiple)
  static Future<List<CareerTip>> getDailyTips() async {
    try {
      if (_useLocalTips) {
        return _getLocalTips();
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/daily'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tipsJson = data['tips'] ?? [];
        if (tipsJson.isEmpty) return _getLocalTips();
        return tipsJson.map((json) => CareerTip.fromJson(json)).toList();
      } else {
        return _getLocalTips();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching daily tips: $e');
      }
      return _getLocalTips();
    }
  }
  
  // Get random career tips
  static Future<List<CareerTip>> getRandomTips({int count = 3}) async {
    try {
      // First, try to get all tips
      final allTips = await getAllTips();
      
      if (allTips.isEmpty) {
        return _getLocalTips(count: count);
      }
      
      // Shuffle the list to get random tips
      final random = Random();
      allTips.shuffle(random);
      
      // Return the requested number of tips (or all if there are fewer tips than requested)
      return allTips.take(count).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error in getRandomTips: $e');
      }
      return _getLocalTips(count: count);
    }
  }
  
  // Get all tips
  static Future<List<CareerTip>> getAllTips() async {
    try {
      if (_useLocalTips) {
        return _getLocalTips();
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/all'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tipsJson = data['tips'] ?? [];
        if (tipsJson.isEmpty) return _getLocalTips();
        return tipsJson.map((json) => CareerTip.fromJson(json)).toList();
      } else {
        return _getLocalTips();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAllTips: $e');
      }
      return _getLocalTips();
    }
  }
  
  // Get tips by category
  static Future<List<CareerTip>> getTipsByCategory(String category) async {
    try {
      final allTips = await getAllTips();
      if (allTips.isEmpty) return [];
      
      return allTips.where((tip) => tip.category.toLowerCase() == category.toLowerCase()).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error in getTipsByCategory: $e');
      }
      return [];
    }
  }
  
  // Helper method to get local tips
  static List<CareerTip> _getLocalTips({int? count}) {
    final tips = _localTips.map((json) => CareerTip.fromJson(json)).toList();
    if (count != null && count < tips.length) {
      tips.shuffle();
      return tips.take(count).toList();
    }
    return tips;
  }
}
