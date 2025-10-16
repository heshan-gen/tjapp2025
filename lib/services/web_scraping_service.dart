import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class WebScrapingService {
  static Future<ScrapedJobContent?> fetchJobDescription(
      final String url) async {
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
          String? anchorLink;
          final imgElements = remarkElement.querySelectorAll('img');
          for (final img in imgElements) {
            final src = img.attributes['src'];
            if (src != null && src.isNotEmpty) {
              // Handle relative URLs
              String fullImageUrl;
              if (src.startsWith('http')) {
                fullImageUrl = src;
              } else if (src.startsWith('/')) {
                final uri = Uri.parse(url);
                fullImageUrl = '${uri.scheme}://${uri.host}$src';
              } else {
                fullImageUrl = '$url/$src';
              }
              imageUrls.add(fullImageUrl);

              // Check if the image is wrapped in an anchor tag
              // First check direct parent
              var parentAnchor = img.parent;
              if (parentAnchor?.localName == 'a') {
                final href = parentAnchor?.attributes['href'];
                if (href != null && href.isNotEmpty) {
                  // Handle relative URLs for anchor links
                  if (href.startsWith('http')) {
                    anchorLink = href;
                  } else if (href.startsWith('/')) {
                    final uri = Uri.parse(url);
                    anchorLink = '${uri.scheme}://${uri.host}$href';
                  } else {
                    anchorLink = '$url/$href';
                  }
                  break; // Use the first anchor link found
                }
              } else {
                // Check grandparent if direct parent is not anchor
                parentAnchor = img.parent?.parent;
                if (parentAnchor?.localName == 'a') {
                  final href = parentAnchor?.attributes['href'];
                  if (href != null && href.isNotEmpty) {
                    // Handle relative URLs for anchor links
                    if (href.startsWith('http')) {
                      anchorLink = href;
                    } else if (href.startsWith('/')) {
                      final uri = Uri.parse(url);
                      anchorLink = '${uri.scheme}://${uri.host}$href';
                    } else {
                      anchorLink = '$url/$href';
                    }
                    break; // Use the first anchor link found
                  }
                }
              }
            }
          }

          // If no anchor link found from images, try searching for any anchor tags in remark
          if (anchorLink == null) {
            final anchorElements = remarkElement.querySelectorAll('a');
            for (final anchor in anchorElements) {
              final href = anchor.attributes['href'];
              if (href != null && href.isNotEmpty && href.startsWith('http')) {
                anchorLink = href;
                break;
              }
            }
          }

          // Check for application buttons in btn-area div
          String applicationType = 'do_not_receive'; // Default fallback
          String? companyEmail; // Extract company email for email applications
          final btnAreaElement = document.querySelector('.btn-area');
          if (btnAreaElement != null) {
            final buttonTexts = btnAreaElement.text.toLowerCase();
            if (buttonTexts.contains('apply by email')) {
              applicationType = 'email';
              print('DEBUG: Found email application type');

              // Look for txtAVECompanyEmail input field
              final emailInput = document.getElementById('txtAVECompanyEmail');
              print('DEBUG: Email input element found: ${emailInput != null}');

              if (emailInput != null) {
                print(
                    'DEBUG: Email input attributes: ${emailInput.attributes}');
                print('DEBUG: Email input text: ${emailInput.text}');

                // Try to get value from different attributes
                final emailValue = emailInput.attributes['value'] ??
                    emailInput.attributes['data-value'] ??
                    emailInput.text.trim();

                // Set companyEmail only if we have a non-empty value
                companyEmail = emailValue.isNotEmpty ? emailValue : null;

                print('DEBUG: Initial company email: $companyEmail');

                // If still empty, try to find email in nearby text or other elements
                if (companyEmail == null || companyEmail.isEmpty) {
                  // Look for email pattern in the input's parent or nearby elements
                  final parent = emailInput.parent;
                  if (parent != null) {
                    final parentText = parent.text;
                    print('DEBUG: Parent text: $parentText');
                    final emailRegex = RegExp(
                        r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
                    final match = emailRegex.firstMatch(parentText);
                    if (match != null) {
                      companyEmail = match.group(0);
                      print('DEBUG: Found email in parent: $companyEmail');
                    }
                  }
                }
              }

              // If still no email found, search the entire document for email patterns
              if (companyEmail == null || companyEmail.isEmpty) {
                print('DEBUG: Searching entire document for email patterns');
                final emailRegex = RegExp(
                    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
                final allText = document.body?.text ?? '';
                final matches = emailRegex.allMatches(allText);
                print(
                    'DEBUG: Found ${matches.length} email matches in document');
                if (matches.isNotEmpty) {
                  // Get the first email found
                  companyEmail = matches.first.group(0);
                  print('DEBUG: Using first email found: $companyEmail');
                }
              }

              print('DEBUG: Final company email: $companyEmail');
            } else if (buttonTexts.contains('apply by online cv')) {
              applicationType = 'online_cv';
            }
          }

          return ScrapedJobContent(
            description: description,
            imageUrls: imageUrls,
            applicationType: applicationType,
            anchorLink: anchorLink,
            companyEmail: companyEmail,
          );
        } else {}
      } else {}

      return null;
    } catch (e) {
      return null;
    }
  }
}

class ScrapedJobContent {
  final String description;
  final List<String> imageUrls;
  final String applicationType; // 'email', 'online_cv', or 'do_not_receive'
  final String? anchorLink; // Link from anchor tag wrapping images
  final String? companyEmail; // Company email for email applications

  ScrapedJobContent({
    required this.description,
    required this.imageUrls,
    required this.applicationType,
    this.anchorLink,
    this.companyEmail,
  });
}
