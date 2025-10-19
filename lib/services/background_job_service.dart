import 'package:http/http.dart' as http;
import '../data/rss_categories.dart';
import '../providers/job_provider.dart';

class BackgroundJobService {
  static Future<List<Job>> fetchJobsFromCategories(
      final List<String> categoryIds) async {
    final List<Job> allJobs = [];

    for (final categoryId in categoryIds) {
      final category = RssCategories.getCategoryById(categoryId);
      if (category == null) continue;

      try {
        final jobs = await _fetchJobsFromFeed(category.feedUrl, category);
        allJobs.addAll(jobs);
      } catch (e) {
        print('Error fetching jobs from ${category.englisht}: $e');
      }
    }

    return allJobs;
  }

  static Future<List<Job>> _fetchJobsFromFeed(
      final String feedUrl, final RssCategory category) async {
    try {
      final response = await http.get(
        Uri.parse(feedUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return _parseRssFeed(response.body, category);
      } else {
        print('Failed to fetch RSS feed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching RSS feed: $e');
      return [];
    }
  }

  static List<Job> _parseRssFeed(
      final String xmlContent, final RssCategory category) {
    final List<Job> jobs = [];

    try {
      // Simple XML parsing for RSS feeds
      final itemPattern = RegExp(r'<item>(.*?)</item>', dotAll: true);
      final items = itemPattern.allMatches(xmlContent);

      for (final match in items) {
        final itemContent = match.group(1) ?? '';

        final titleMatch =
            RegExp(r'<title><!\[CDATA\[(.*?)\]\]></title>|<title>(.*?)</title>')
                .firstMatch(itemContent);
        final linkMatch = RegExp(r'<link>(.*?)</link>').firstMatch(itemContent);
        final descriptionMatch = RegExp(
                r'<description><!\[CDATA\[(.*?)\]\]></description>|<description>(.*?)</description>')
            .firstMatch(itemContent);
        final pubDateMatch =
            RegExp(r'<pubDate>(.*?)</pubDate>').firstMatch(itemContent);

        final title = titleMatch?.group(1) ?? titleMatch?.group(2) ?? '';
        final link = linkMatch?.group(1) ?? '';
        final description =
            descriptionMatch?.group(1) ?? descriptionMatch?.group(2) ?? '';
        final pubDate = pubDateMatch?.group(1) ?? '';

        if (title.isNotEmpty && link.isNotEmpty) {
          // Generate a unique job ID from the link
          final jobId = link.hashCode.toString();
          // Use jobId as comments for consistency with main JobProvider
          final comments = jobId;

          final job = Job(
            id: link,
            jobId: jobId,
            title: _cleanText(title),
            company: _extractCompany(title),
            location: _extractLocation(description),
            description: _cleanText(description),
            salary: _extractSalary(description),
            type: _extractJobType(description),
            experience: _extractExperience(description),
            skills: _extractSkills(description),
            requirements: _extractRequirements(description),
            postedDate: _parseDate(pubDate) ?? DateTime.now(),
            closingDate: _parseDate(pubDate),
            author: _extractCompany(title),
            comments: comments,
            applicantCode: '',
            feedUrl: category.feedUrl,
            publisher: _extractCompany(title),
            isRemote: _isRemoteJob(description),
            guid: link,
            isFavorite: false,
            gradientColors: [],
            viewCount: 0,
            averageRating: 0.0,
            totalRatings: 0,
          );

          jobs.add(job);
        }
      }
    } catch (e) {
      print('Error parsing RSS feed: $e');
    }

    return jobs;
  }

  static String _cleanText(final String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'&[^;]+;'), '') // Remove HTML entities
        .replaceAll(
            RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .trim();
  }

  static String _extractCompany(final String title) {
    // Try to extract company name from title (usually before the job title)
    final parts = title.split(' - ');
    if (parts.length > 1) {
      return parts[0].trim();
    }
    return 'Company';
  }

  static String _extractLocation(final String description) {
    final locationPattern = RegExp(r'(?:Location|Based in|Office):\s*([^,\n]+)',
        caseSensitive: false);
    final match = locationPattern.firstMatch(description);
    return match?.group(1)?.trim() ?? 'Location not specified';
  }

  static String _extractSalary(final String description) {
    final salaryPattern = RegExp(r'(?:Salary|Pay|Compensation):\s*([^,\n]+)',
        caseSensitive: false);
    final match = salaryPattern.firstMatch(description);
    return match?.group(1)?.trim() ?? 'Salary not specified';
  }

  static String _extractJobType(final String description) {
    if (description.toLowerCase().contains('full-time')) return 'Full-time';
    if (description.toLowerCase().contains('part-time')) return 'Part-time';
    if (description.toLowerCase().contains('contract')) return 'Contract';
    if (description.toLowerCase().contains('freelance')) return 'Freelance';
    return 'Full-time';
  }

  static String _extractExperience(final String description) {
    final expPattern =
        RegExp(r'(?:Experience|Exp):\s*([^,\n]+)', caseSensitive: false);
    final match = expPattern.firstMatch(description);
    return match?.group(1)?.trim() ?? 'Experience not specified';
  }

  static List<String> _extractSkills(final String description) {
    final skills = <String>[];
    final commonSkills = [
      'JavaScript',
      'Python',
      'Java',
      'React',
      'Node.js',
      'Flutter',
      'Dart',
      'SQL',
      'MongoDB',
      'AWS',
      'Docker',
      'Git',
      'Agile',
      'Scrum'
    ];

    for (final skill in commonSkills) {
      if (description.toLowerCase().contains(skill.toLowerCase())) {
        skills.add(skill);
      }
    }

    return skills;
  }

  static String _extractRequirements(final String description) {
    final reqPattern = RegExp(r'(?:Requirements|Qualifications):\s*([^,\n]+)',
        caseSensitive: false);
    final match = reqPattern.firstMatch(description);
    return match?.group(1)?.trim() ?? 'Requirements not specified';
  }

  static DateTime? _parseDate(final String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date: $e');
    }
    return null;
  }

  static bool _isRemoteJob(final String description) {
    return description.toLowerCase().contains('remote') ||
        description.toLowerCase().contains('work from home') ||
        description.toLowerCase().contains('wfh');
  }
}
