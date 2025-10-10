import 'dart:convert';
import 'package:http/http.dart' as http;

class CompanyService {
  // Note: You'll need to get a Google Custom Search API key and Search Engine ID
  // For now, I'll use a placeholder approach that searches for company info
  static const String _baseUrl = 'https://www.googleapis.com/customsearch/v1';

  // You need to replace these with your actual API credentials
  static const String _apiKey =
      'AIzaSyDxRJ6Mb8kQIyL_adLUPUAtXVLNsJN7Vc4'; // Replace with your API key
  static const String _searchEngineId =
      '8199c181d2c8f44f5'; // Replace with your Search Engine ID

  /// Search for company information using Google Custom Search API
  static Future<String> getCompanyInfo(final String companyName) async {
    try {
      // Clean the company name for better search results
      final cleanCompanyName =
          companyName.trim().replaceAll(RegExp(r'\s+'), ' ');

      // Create search query
      final query = '$cleanCompanyName company profile about information';

      final url = Uri.parse(
          '$_baseUrl?key=$_apiKey&cx=$_searchEngineId&q=${Uri.encodeComponent(query)}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['items'] != null && data['items'].isNotEmpty) {
          // Extract snippet from the first search result
          final firstResult = data['items'][0];
          final snippet = firstResult['snippet'] ?? '';

          // Clean up the snippet
          final String companyInfo = snippet
              .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
              .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
              .trim();

          print('Company info length: ${companyInfo.length}');
          print(
              'Company info preview: ${companyInfo.substring(0, companyInfo.length > 100 ? 100 : companyInfo.length)}...');

          return companyInfo.isNotEmpty
              ? companyInfo
              : _getDefaultCompanyInfo(cleanCompanyName);
        }
      }

      return _getDefaultCompanyInfo(cleanCompanyName);
    } catch (e) {
      print('Error fetching company info: $e');
      return _getDefaultCompanyInfo(companyName);
    }
  }

  /// Fallback method when API fails or returns no results
  static String _getDefaultCompanyInfo(final String companyName) {
    return 'Learn more about $companyName and their career opportunities. Visit their website for detailed information about the company culture, values, and available positions.';
  }

  /// Alternative method using web scraping (requires additional dependencies)
  /// This is a simpler approach that doesn't require API keys
  static Future<String> getCompanyInfoSimple(final String companyName) async {
    try {
      // This is a simplified approach that returns a generic message
      // In a real implementation, you might want to scrape company websites
      // or use other APIs that don't require authentication

      final cleanCompanyName =
          companyName.trim().replaceAll(RegExp(r'\s+'), ' ');

      // Return a more dynamic message based on company name
      return 'Discover career opportunities at $cleanCompanyName. We are committed to providing excellent career growth and professional development opportunities for our team members.';
    } catch (e) {
      print('Error in simple company info: $e');
      return _getDefaultCompanyInfo(companyName);
    }
  }
}
