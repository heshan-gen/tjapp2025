import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class WebScrapingService {
  static Future<ScrapedJobContent?> fetchJobDescription(final String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate',
          'Connection': 'keep-alive',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // Look for element with id="remark"
        final remarkElement = document.getElementById('remark');

        if (remarkElement != null) {
          // Extract text content
          final String description = remarkElement.text.trim();

          // Extract images from the remark element
          final List<String> imageUrls = [];
          final imgElements = remarkElement.querySelectorAll('img');
          for (final img in imgElements) {
            final src = img.attributes['src'];
            if (src != null && src.isNotEmpty) {
              // Handle relative URLs
              if (src.startsWith('http')) {
                imageUrls.add(src);
              } else if (src.startsWith('/')) {
                final uri = Uri.parse(url);
                imageUrls.add('${uri.scheme}://${uri.host}$src');
              } else {
                imageUrls.add('$url/$src');
              }
            }
          }

          return ScrapedJobContent(
            description: description,
            imageUrls: imageUrls,
          );
        } else {
          print('Element with id="remark" not found on page');
        }
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      print('Error fetching job description: $e');
      return null;
    }
  }
}

class ScrapedJobContent {
  final String description;
  final List<String> imageUrls;

  ScrapedJobContent({
    required this.description,
    required this.imageUrls,
  });
}
