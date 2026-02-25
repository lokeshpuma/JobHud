import 'dart:convert';
import 'package:http/http.dart' as http;

class InterviewPrepService {
  final String? apiKey;
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  InterviewPrepService({this.apiKey});

  Future<List<String>> _getDefaultChecklist({
    required String companyName,
    required String position,
  }) async {
    return [
      'Research $companyName\'s company culture and values',
      'Review common $position interview questions',
      'Prepare your portfolio and resume',
      'Practice coding problems',
      'Prepare questions to ask the interviewer',
      'Dress professionally for the interview',
      'Test your internet connection and equipment (if virtual)',
      'Plan your route and arrive 10-15 minutes early (if in-person)',
    ];
  }

  Future<List<String>> generateInterviewChecklist({
    required String companyName,
    required String position,
  }) async {
    // Return default checklist if no API key is provided
    if (apiKey == null || apiKey!.isEmpty) {
      return _getDefaultChecklist(
        companyName: companyName,
        position: position,
      );
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful career coach that provides interview preparation advice.'
            },
            {
              'role': 'user',
              'content': '''
              Create a detailed interview preparation checklist for a $position position at $companyName.
              Include:
              1. Company research points
              2. Technical skills to review
              3. Common interview questions
              4. Questions to ask the interviewer
              5. Documents to prepare
              6. Dress code suggestions
              
              Format the response as a numbered list with clear sections.
              '''
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content.split('\n').where((item) => item.trim().isNotEmpty).toList();
      } else {
        throw Exception('Failed to generate checklist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating checklist: $e');
    }
  }
}
