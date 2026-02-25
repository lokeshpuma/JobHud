import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() async {
  print('🚀 Testing Remotive API connection...');
  
  try {
    final url = Uri.parse('https://remotive.com/api/remote-jobs?limit=1');
    print('🌐 Sending request to: $url');
    
    // Add timeout to the request
    final response = await http.get(url).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Request timed out after 10 seconds'),
    );
    
    print('✅ Received response with status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        
        if (data == null) {
          throw FormatException('Empty response body');
        }
        
        print('\n📊 API Response Summary:');
        print('   • Total jobs: ${data['job-count']}');
        
        final jobs = data['jobs'] as List?;
        if (jobs != null && jobs.isNotEmpty) {
          print('   • First job: ${jobs[0]['title']}');
          print('   • Company: ${jobs[0]['company_name']}');
        } else {
          print('   • No jobs found in the response');
        }
        
        print('\n🎉 Success! Remotive API is working correctly!');
      } on FormatException catch (e) {
        print('❌ Error parsing response: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print('❌ Error: Server responded with status code ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } on TimeoutException catch (e) {
    print('⏱️  Error: $e');
  } on http.ClientException catch (e) {
    print('🌐 Network error: $e');
    print('Please check your internet connection and try again.');
  } catch (e) {
    print('❌ Unexpected error: $e');
  } finally {
    print('\n🔍 Test completed.');
  }
}
