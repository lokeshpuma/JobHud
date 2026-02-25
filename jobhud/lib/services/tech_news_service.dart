import 'dart:convert';
import 'package:http/http.dart' as http;

class TechNewsService {
  // For development, you can set your API key directly here
  // In production, use a secure method to store and access the API key
  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<List<Map<String, dynamic>>> fetchTechNews() async {
    print('Starting to fetch tech news...');
    print('API Key is ${_apiKey.isEmpty ? 'not set' : 'set'}');
    
    try {
      if (_apiKey.isEmpty) {
        print('Error: OPENAI_API_KEY is not configured');
        print('Please add your OpenAI API key to the .env file');
        throw Exception('OpenAI API key is not configured. Please check your .env file.');
      }

      print('Sending request to OpenAI API...');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that provides the latest tech news and trends. Provide 8-9 concise, informative tech news articles with titles, brief summaries, and relevant details. Format as a JSON array of objects with title, summary, source, and publishedDate fields. Current date is ${DateTime.now().toIso8601String()}.',
            },
            {
              'role': 'user',
              'content': 'Provide 8-9 current tech news articles with titles, summaries, and sources in JSON format. The response must be a valid JSON array of objects with the following fields: title (string), summary (string), source (string), and publishedDate (string in ISO 8601 format).',
            },
          ],
          'temperature': 0.7,
        }),
      );

      print('Received response with status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          print('Successfully parsed response body');
          
          final String content = data['choices'][0]['message']['content'];
          print('Content received from API: $content');
          
          // Parse the JSON content from the response
          final List<dynamic> articles = jsonDecode(content);
          print('Successfully parsed ${articles.length} articles');
          
          // Convert to List<Map<String, dynamic>>
          return articles.map((article) => article as Map<String, dynamic>).toList();
        } catch (e) {
          print('Error parsing API response: $e');
          print('Response body: ${response.body}');
          throw Exception('Failed to parse API response: $e');
        }
      } else {
        print('API request failed with status ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('API request failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error in fetchTechNews: $e');
      print('Stack trace: $stackTrace');
      print('Falling back to mock data');
      return _getMockTechNews();
    }
  }

  // Mock data to use when API call fails
  static List<Map<String, dynamic>> _getMockTechNews() {
    return [
      {
        'title': 'Advancements in AI Technology',
        'summary': 'Recent breakthroughs in AI are changing how we interact with technology.',
        'source': 'Tech Insights',
        'publishedDate': DateTime.now().toIso8601String(),
      },
      {
        'title': 'The Future of Remote Work',
        'summary': 'How remote work is evolving with new collaboration tools and practices.',
        'source': 'Workplace Weekly',
        'publishedDate': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'title': 'The Rise of Quantum Computing',
        'summary': 'Quantum computing is making significant strides in solving complex problems.',
        'source': 'Quantum Today',
        'publishedDate': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      },
      {
        'title': '5G and the Future of Connectivity',
        'summary': 'How 5G technology is transforming mobile and IoT connectivity.',
        'source': 'Network World',
        'publishedDate': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
      },
    ];
  }
}
