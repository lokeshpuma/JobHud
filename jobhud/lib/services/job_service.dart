import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jobhud/models/job_model.dart';
import 'package:jobhud/models/job_filter_model.dart';

class JobService {
  static const String _baseUrl = 'https://remotive.com/api/remote-jobs';
  
  // Normalize job type to match filter options
  static String _normalizeJobType(dynamic jobType) {
    if (jobType == null) return 'Full-time';
    
    final type = jobType.toString().toLowerCase();
    
    // Map various job type formats to standard types
    if (type.contains('full') || type.contains('full-time') || type.contains('fulltime')) {
      return 'Full-time';
    } else if (type.contains('part') || type.contains('part-time') || type.contains('parttime')) {
      return 'Part-time';
    } else if (type.contains('contract')) {
      return 'Contract';
    } else if (type.contains('freelance') || type.contains('temporary')) {
      return 'Freelance';
    } else if (type.contains('intern')) {
      return 'Internship';
    }
    
    // Return original if no match, capitalize first letter
    return jobType.toString().split(' ').map((word) => 
      word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }
  
  // Fetch jobs from Remotive API with optional filters
  static Future<List<Job>> fetchJobs({
    int limit = 50,
    int offset = 0,
    JobFilter? filter,
  }) async {
    try {
      // Build query parameters
      final params = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      // Add filter parameters if they exist
      if (filter != null) {
        if (filter.location != null && filter.location!.isNotEmpty) {
          params['location'] = filter.location!;
        }
        if (filter.jobType != null && filter.jobType!.isNotEmpty) {
          // Map UI job types to API job types
          final type = filter.jobType!.toLowerCase();
          if (type == 'full-time') {
            params['job_type'] = 'full_time';
          } else if (type == 'part-time') {
            params['job_type'] = 'part_time';
          } else {
            params['job_type'] = type;
          }
        }
        if (filter.categories != null && filter.categories!.isNotEmpty) {
          params['category'] = filter.categories!.join(',');
        }
        if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
          params['search'] = filter.searchQuery!;
        }
      }

      // Build URI with parameters
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: params,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> jobs = data['jobs'] ?? [];
        
        return jobs.map((job) => Job(
          id: job['id'].toString(),
          title: job['title'] ?? 'No Title',
          company: job['company_name'] ?? 'No Company',
          location: job['candidate_required_location'] ?? 'Remote',
          type: _normalizeJobType(job['job_type']),
          salary: job['salary'] ?? 'Not specified',
          description: job['description'] ?? 'No description available',
          logoUrl: job['company_logo'] ?? '',
          url: job['url'] ?? 'https://remotive.com/remote-jobs',
          postedDate: job['publication_date'] != null 
              ? DateTime.parse(job['publication_date'])
              : null,
        )).toList();
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch jobs: $e');
    }
  }
  
  // Search jobs by keyword with filters and improved relevance
  static Future<List<Job>> searchJobs(String query, {JobFilter? filter}) async {
    try {
      // Build search parameters
      final params = {
        'search': query,
        if (filter?.location != null && filter!.location!.isNotEmpty)
          'location': filter.location,
        if (filter?.jobType != null && filter!.jobType!.isNotEmpty)
          'job_type': filter.jobType!.toLowerCase(),
        if (filter?.categories != null && filter!.categories!.isNotEmpty)
          'category': filter.categories!.join(','),
      };

      // First try exact match search
      final exactParams = Map<String, String>.from(params)..['exact_match'] = 'true';
      final exactUri = Uri.parse(_baseUrl).replace(
        queryParameters: exactParams,
      );

      final response = await http.get(exactUri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> jobs = data['jobs'] ?? [];
        
        // If no exact matches, try fuzzy search
        if (jobs.isEmpty) {
          final fuzzyUri = Uri.parse(_baseUrl).replace(
            queryParameters: params,
          );
          final fuzzyResponse = await http.get(fuzzyUri);
          
          if (fuzzyResponse.statusCode == 200) {
            final fuzzyData = json.decode(fuzzyResponse.body);
            jobs = fuzzyData['jobs'] ?? [];
          }
        }
        
        // Process and score jobs based on search relevance
        final List<Map<String, dynamic>> processedJobs = [];
        final queryTerms = query.toLowerCase().split(' ').where((t) => t.length > 2).toList();
        
        for (var job in jobs) {
          int score = 0;
          final title = (job['title'] ?? '').toString().toLowerCase();
          final company = (job['company_name'] ?? '').toString().toLowerCase();
          final description = (job['description'] ?? '').toString().toLowerCase();
          final requirements = (job['requirements'] ?? '').toString().toLowerCase();
          final category = (job['category'] ?? '').toString().toLowerCase();
          
          // Score based on term matches in different fields
          for (final term in queryTerms) {
            if (term.length < 3) continue; // Skip very short terms
            
            if (title.contains(term)) score += 5;
            if (company.contains(term)) score += 4;
            if (description.contains(term)) score += 2;
            if (requirements.contains(term)) score += 3;
            if (category.contains(term)) score += 4;
          }
          
          // Add job with score
          processedJobs.add({
            'job': job,
            'score': score,
          });
        }
        
        // Sort by score and take top 50
        processedJobs.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
        final topJobs = processedJobs.take(50).toList();
        
        return topJobs.map((item) {
          final job = item['job'];
          return Job(
            id: job['id'].toString(),
            title: job['title'] ?? 'No Title',
            company: job['company_name'] ?? 'No Company',
            location: job['candidate_required_location'] ?? 'Remote',
            type: _normalizeJobType(job['job_type']),
            salary: job['salary'] ?? 'Not specified',
            description: job['description'] ?? 'No description available',
            logoUrl: job['company_logo'] ?? '',
            url: job['url'] ?? 'https://remotive.com/remote-jobs',
            postedDate: job['publication_date'] != null 
                ? DateTime.parse(job['publication_date'])
                : null,
          );
        }).toList();
      } else {
        throw Exception('Failed to search jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search jobs: $e');
    }
  }
}
