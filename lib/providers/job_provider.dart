// ignore_for_file: unused_local_variable, curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../data/rss_categories.dart';
import '../services/view_count_service.dart';

class Job {
  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.description,
    required this.requirements,
    required this.type,
    required this.experience,
    required this.postedDate,
    this.closingDate,
    this.author = '',
    this.jobId = '',
    this.comments = '',
    this.applicantCode = '',
    this.feedUrl = '',
    this.publisher = '',
    this.isRemote = false,
    this.skills = const [],
    this.guid = '',
    this.isFavorite = false,
    this.gradientColors = const [],
    this.viewCount = 0,
  });
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String description;
  final String requirements;
  final String type; // Full-time, Part-time, Contract, etc.
  final String experience; // Entry, Mid, Senior
  final DateTime postedDate;
  final DateTime? closingDate;
  final String author;
  final String jobId; // js field
  final String comments;
  final String applicantCode; // ac field
  final String feedUrl; // Track which RSS feed this job came from
  final String publisher; // Company logo/publisher from dc:publisher
  final bool isRemote;
  final List<String> skills;
  final String guid;
  final bool isFavorite;
  final List<Color> gradientColors;
  final int viewCount;
}

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  List<Job> _categoryJobs = []; // Separate list for category-specific jobs
  List<Job> _filteredCategoryJobs = []; // Filtered category jobs
  final Set<String> _favoriteJobIds = {}; // Track favorite job IDs

  // Random gradient colors - Dark colors for better white text contrast
  final List<List<Color>> _gradientColors = [
    [
      const Color.fromARGB(255, 26, 165, 184),
      const Color.fromARGB(255, 141, 35, 151)
    ], // Teal to Purple (keep original)
    [
      const Color.fromARGB(255, 220, 38, 38),
      const Color.fromARGB(255, 185, 28, 28)
    ], // Red gradient
    [
      const Color.fromARGB(255, 37, 99, 235),
      const Color.fromARGB(255, 29, 78, 216)
    ], // Blue gradient
    [
      const Color.fromARGB(255, 217, 119, 6),
      const Color.fromARGB(255, 180, 83, 9)
    ], // Orange gradient
    [
      const Color.fromARGB(255, 147, 51, 234),
      const Color.fromARGB(255, 124, 58, 237)
    ], // Purple gradient
    [
      const Color.fromARGB(255, 22, 163, 74),
      const Color.fromARGB(255, 21, 128, 61)
    ], // Green gradient
    [
      const Color.fromARGB(255, 239, 68, 68),
      const Color.fromARGB(255, 220, 38, 38)
    ], // Red-orange gradient
    [
      const Color.fromARGB(255, 67, 56, 202),
      const Color.fromARGB(255, 79, 70, 229)
    ], // Indigo gradient
    [
      const Color.fromARGB(255, 14, 116, 144),
      const Color.fromARGB(255, 21, 94, 117)
    ], // Cyan gradient
    [
      const Color.fromARGB(255, 120, 53, 15),
      const Color.fromARGB(255, 92, 38, 8)
    ], // Brown gradient
    [
      const Color.fromARGB(255, 168, 85, 247),
      const Color.fromARGB(255, 139, 69, 19)
    ], // Purple to Brown
    [
      const Color.fromARGB(255, 34, 197, 94),
      const Color.fromARGB(255, 16, 185, 129)
    ], // Green to Teal
    [
      const Color.fromARGB(255, 239, 68, 68),
      const Color.fromARGB(255, 168, 85, 247)
    ], // Red to Purple
    [
      const Color.fromARGB(255, 59, 130, 246),
      const Color.fromARGB(255, 147, 51, 234)
    ], // Blue to Purple
    [
      const Color.fromARGB(255, 245, 101, 101),
      const Color.fromARGB(255, 34, 197, 94)
    ], // Pink to Green
  ];

  List<Color> _getRandomGradientColors() {
    final random = Random();
    return _gradientColors[random.nextInt(_gradientColors.length)];
  }

  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedLocation = '';
  String _selectedType = '';
  String _selectedExperience = '';
  String? _selectedCategory;

  // Search debouncing
  Timer? _searchTimer;

  // SharedPreferences key for storing favorites
  static const String _favoritesKey = 'favorite_job_ids';

  // RSS Feed URLs from topjobs.lk - using same URLs as RssCategories
  static const List<String> _rssFeeds = [
    'http://www.topjobs.lk/feeds/legasy/it_sware_db_qa_web_graphics_gis.rss',
    'http://www.topjobs.lk/feeds/legasy/it_hware_networks_systems.rss',
    'http://www.topjobs.lk/feeds/legasy/accounting_auditing_finance.rss',
    'http://www.topjobs.lk/feeds/legasy/banking_insurance.rss',
    'http://www.topjobs.lk/feeds/legasy/sales_marketing_merchandising.rss',
    'http://www.topjobs.lk/feeds/legasy/hr_training.rss',
    'http://www.topjobs.lk/feeds/legasy/corporate_management_analysts.rss',
    'http://www.topjobs.lk/feeds/legasy/office_admin_secretary_receptionist.rss',
    'http://www.topjobs.lk/feeds/legasy/civil_eng_interior_design_architecture.rss',
    'http://www.topjobs.lk/feeds/legasy/it_telecoms.rss',
    'http://www.topjobs.lk/feeds/legasy/customer_relations_public_relations.rss',
    'http://www.topjobs.lk/feeds/legasy/logistics_warehouse_transport.rss',
    'http://www.topjobs.lk/feeds/legasy/eng_mech_auto_elec.rss',
    'http://www.topjobs.lk/feeds/legasy/manufacturing_operations.rss',
    'http://www.topjobs.lk/feeds/legasy/media_advert_communication.rss',
    'http://www.topjobs.lk/feeds/legasy/HOTELS_RESTAURANTS_HOSPITALITY.rss',
    'http://www.topjobs.lk/feeds/legasy/TRAVEL_TOURISM.rss',
    'http://www.topjobs.lk/feeds/legasy/sports_fitness_recreation.rss',
    'http://www.topjobs.lk/feeds/legasy/hospital_nursing_healthcare.rss',
    'http://www.topjobs.lk/feeds/legasy/legal_law.rss',
    'http://www.topjobs.lk/feeds/legasy/supervision_quality_control.rss',
    'http://www.topjobs.lk/feeds/legasy/apparel_clothing.rss',
    'http://www.topjobs.lk/feeds/legasy/ticketing_airline_marine.rss',
    'http://www.topjobs.lk/feeds/legasy/EDUCATION.rss',
    'http://www.topjobs.lk/feeds/legasy/rnd_science_research.rss',
    'http://www.topjobs.lk/feeds/legasy/agriculture_dairy_environment.rss',
    'http://www.topjobs.lk/feeds/legasy/security.rss',
    'http://www.topjobs.lk/feeds/legasy/fashion_design_beauty.rss',
    'http://www.topjobs.lk/feeds/legasy/international_development.rss',
    'http://www.topjobs.lk/feeds/legasy/kpo_bpo.rss',
    'http://www.topjobs.lk/feeds/legasy/imports_exports.rss',
  ];

  List<Job> get jobs => _filteredJobs;
  List<Job> get categoryJobs => _filteredCategoryJobs.isNotEmpty
      ? _filteredCategoryJobs
      : _categoryJobs; // Getter for category-specific jobs
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedLocation => _selectedLocation;
  String get selectedType => _selectedType;
  String get selectedExperience => _selectedExperience;
  String? get selectedCategory => _selectedCategory;
  Set<String> get favoriteJobIds => _favoriteJobIds;

  // Load jobs from RSS feeds
  Future<void> loadJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<Job> allJobs = [];

      // Fetch jobs from all RSS feeds concurrently
      final List<Future<List<Job>>> futures =
          _rssFeeds.map((final feedUrl) => _fetchJobsFromRSS(feedUrl)).toList();
      final List<List<Job>> results = await Future.wait(futures);

      // Combine all jobs from all feeds
      for (final jobList in results) {
        allJobs.addAll(jobList);
      }

      _jobs = allJobs;
      _filteredJobs = allJobs;

      // Load favorites after jobs are loaded
      await _loadFavorites();

      // Load view counts in background (non-blocking)
      loadViewCounts();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading jobs: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load jobs from a specific category RSS feed
  Future<void> loadJobsFromCategory(final String feedUrl) async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<Job> categoryJobs = await _fetchJobsFromRSS(feedUrl);

      // Store category jobs separately, don't replace the main jobs list
      _categoryJobs = categoryJobs;
      _filteredCategoryJobs = categoryJobs; // Initialize filtered category jobs
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading jobs from category: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch jobs from a single RSS feed
  Future<List<Job>> _fetchJobsFromRSS(final String feedUrl) async {
    try {
      final response = await http.get(Uri.parse(feedUrl));
      if (response.statusCode == 200) {
        return _parseRSSFeed(response.body, feedUrl);
      }
    } catch (e) {
      print('Error fetching RSS feed $feedUrl: $e');
    }
    return [];
  }

  // Safe substring method to prevent RangeError
  String _safeSubstring(final String text, final int start, int end) {
    if (start < 0 || start >= text.length) {
      return '';
    }
    if (end < start) {
      return '';
    }
    if (end > text.length) {
      end = text.length;
    }
    return text.substring(start, end);
  }

  // Safe method to extract content from XML tags
  String _extractXmlContent(
      final String line, final String startTag, final String endTag) {
    try {
      if (!line.startsWith(startTag) || !line.endsWith(endTag)) {
        return '';
      }

      final startIndex = startTag.length;
      final endIndex = line.length - endTag.length;

      // Additional validation to prevent negative indices
      if (startIndex < 0 || endIndex < 0 || startIndex >= endIndex) {
        return '';
      }

      return _safeSubstring(line, startIndex, endIndex);
    } catch (e) {
      print(
          'Error extracting XML content from "$line" with tags "$startTag" and "$endTag": $e');
      return '';
    }
  }

  // Parse RSS XML and extract all jobs
  List<Job> _parseRSSFeed(final String xmlContent, final String feedUrl) {
    final List<Job> jobs = [];

    try {
      // Validate XML content before parsing
      if (xmlContent.isEmpty) {
        print('Empty XML content for feed: $feedUrl');
        return jobs;
      }

      if (!xmlContent.contains('<rss') && !xmlContent.contains('<feed')) {
        print('Invalid RSS/Atom feed format for: $feedUrl');
        return jobs;
      }

      // Simple XML parsing for RSS feed
      final lines = xmlContent.split('\n');
      String currentTitle = '';
      String currentDescription = '';
      String currentLink = '';
      String currentGuid = '';
      String currentPubDate = '';
      String currentClosingDate = '';
      String currentAuthor = '';
      String currentJobId = '';
      String currentComments = '';
      String currentLocation = '';
      String currentApplicantCode = '';
      String currentPublisher = '';

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();

        // Skip empty lines or lines that are too short to contain valid XML
        if (line.isEmpty || line.length < 3) {
          continue;
        }

        if (line.startsWith('<title>') && line.endsWith('</title>')) {
          currentTitle = _extractXmlContent(line, '<title>', '</title>');
        } else if (line.startsWith('<description>') &&
            line.endsWith('</description>')) {
          currentDescription =
              _extractXmlContent(line, '<description>', '</description>');
        } else if (line.startsWith('<link>') && line.endsWith('</link>')) {
          currentLink = _extractXmlContent(line, '<link>', '</link>');
        } else if (line.startsWith('<guid>') && line.endsWith('</guid>')) {
          currentGuid = _extractXmlContent(line, '<guid>', '</guid>');
        } else if (line.startsWith('<pubDate>') &&
            line.endsWith('</pubDate>')) {
          currentPubDate = _extractXmlContent(line, '<pubDate>', '</pubDate>');
        } else if (line.startsWith('<closingDate>') &&
            line.endsWith('</closingDate>')) {
          currentClosingDate =
              _extractXmlContent(line, '<closingDate>', '</closingDate>');
        } else if (line.startsWith('<author>') && line.endsWith('</author>')) {
          currentAuthor = _extractXmlContent(line, '<author>', '</author>');
        } else if (line.startsWith('<js>') && line.endsWith('</js>')) {
          currentJobId = _extractXmlContent(line, '<js>', '</js>');
        } else if (line.startsWith('<comments>') &&
            line.endsWith('</comments>')) {
          currentComments =
              _extractXmlContent(line, '<comments>', '</comments>');
        } else if (line.startsWith('<lc>') && line.endsWith('</lc>')) {
          currentLocation = _extractXmlContent(line, '<lc>', '</lc>');
        } else if (line.startsWith('<ac>') && line.endsWith('</ac>')) {
          currentApplicantCode = _extractXmlContent(line, '<ac>', '</ac>');
        } else if (line.startsWith('<dc:creator') &&
            line.contains('>') &&
            line.contains('</dc:creator>')) {
          // Extract company from Dublin Core creator field
          try {
            final startIndex = line.indexOf('>') + 1;
            final endIndex = line.lastIndexOf('</dc:creator>');
            if (startIndex > 0 &&
                endIndex > startIndex &&
                endIndex <= line.length &&
                startIndex < line.length) {
              currentAuthor = _safeSubstring(line, startIndex, endIndex);
            }
          } catch (e) {
            print('Error parsing dc:creator: "$line" - $e');
            currentAuthor = '';
          }
        } else if (line.startsWith('<dc:publisher') &&
            line.contains('>') &&
            line.contains('</dc:publisher>')) {
          // Extract publisher/logo from Dublin Core publisher field
          try {
            final startIndex = line.indexOf('>') + 1;
            final endIndex = line.lastIndexOf('</dc:publisher>');
            if (startIndex > 0 &&
                endIndex > startIndex &&
                endIndex <= line.length &&
                startIndex < line.length) {
              currentPublisher = _safeSubstring(line, startIndex, endIndex);
            }
          } catch (e) {
            print('Error parsing dc:publisher: "$line" - $e');
            currentPublisher = '';
          }
        } else if (line == '</item>') {
          // Add all jobs regardless of guid
          if (currentTitle.isNotEmpty) {
            final job = Job(
              id: currentLink.isNotEmpty
                  ? currentLink
                  : DateTime.now().millisecondsSinceEpoch.toString(),
              title: currentTitle,
              company: currentAuthor.isNotEmpty
                  ? currentAuthor
                  : _extractCompanyFromTitle(currentTitle),
              location: currentLocation.isNotEmpty
                  ? currentLocation
                  : _extractLocationFromDescription(currentDescription),
              salary: _extractSalaryFromDescription(currentDescription),
              description: currentDescription,
              requirements:
                  _extractRequirementsFromDescription(currentDescription),
              type: _extractJobTypeFromDescription(currentDescription),
              experience: _extractExperienceFromDescription(currentDescription),
              postedDate: _parseDate(currentPubDate),
              closingDate: currentClosingDate.isNotEmpty
                  ? _parseDate(currentClosingDate)
                  : null,
              author: currentAuthor,
              jobId: currentJobId,
              comments: currentComments,
              applicantCode: currentApplicantCode,
              feedUrl: feedUrl, // Add the feed URL
              publisher: currentPublisher, // Add the publisher/logo
              isRemote: _isRemoteJob(currentDescription),
              skills: _extractSkillsFromDescription(currentDescription),
              guid: currentGuid,
              isFavorite: false, // Default to not favorite
              gradientColors:
                  _getRandomGradientColors(), // Add random gradient colors
              viewCount: 0, // Default view count
            );
            jobs.add(job);
          }

          // Reset for next item
          currentTitle = '';
          currentDescription = '';
          currentLink = '';
          currentGuid = '';
          currentPubDate = '';
          currentClosingDate = '';
          currentAuthor = '';
          currentJobId = '';
          currentComments = '';
          currentLocation = '';
          currentApplicantCode = '';
          currentPublisher = '';
          currentGuid = '';
        }
      }
    } catch (e) {
      print('Error parsing RSS feed from $feedUrl: $e');
      if (e is RangeError) {
        print(
            'RangeError details: ${e.message} - start: ${e.start}, end: ${e.end}');
        print('Stack trace: ${StackTrace.current}');
      }
      // Print some debug information about the XML content
      if (xmlContent.isNotEmpty) {
        print('XML content length: ${xmlContent.length}');
        print(
            'First 200 characters: ${xmlContent.substring(0, xmlContent.length > 200 ? 200 : xmlContent.length)}');
      }
    }

    return jobs;
  }

  // Helper methods to extract information from job descriptions
  String _extractCompanyFromTitle(final String title) {
    try {
      // Try to extract company name from title (usually after "at" or " - ")
      if (title.contains(' at ')) {
        final parts = title.split(' at ');
        if (parts.length > 1) {
          final lastPart = parts.last;
          if (lastPart.contains(' - ')) {
            final subParts = lastPart.split(' - ');
            return subParts.isNotEmpty
                ? subParts.first.trim()
                : 'Company Not Specified';
          }
          return lastPart.trim();
        }
      } else if (title.contains(' - ')) {
        final parts = title.split(' - ');
        return parts.length > 1 ? parts.last.trim() : 'Company Not Specified';
      }
    } catch (e) {
      print('Error extracting company from title "$title": $e');
    }
    return 'Company Not Specified';
  }

  String _extractLocationFromDescription(final String description) {
    try {
      // Look for common location patterns
      final locationPatterns = [
        RegExp(r'Location[:\s]+([^<\n]+)', caseSensitive: false),
        RegExp(r'Based in[:\s]+([^<\n]+)', caseSensitive: false),
        RegExp(
            r'Colombo|Kandy|Galle|Negombo|Jaffna|Anuradhapura|Ratnapura|Kurunegala|Matara|Batticaloa',
            caseSensitive: false),
      ];

      for (final pattern in locationPatterns) {
        try {
          final match = pattern.firstMatch(description);
          if (match != null && match.groupCount > 0) {
            // Check if the first capture group exists and is not null
            final locationGroup = match.group(1);
            if (locationGroup != null && locationGroup.isNotEmpty) {
              return locationGroup.trim();
            }
          } else if (match != null && match.groupCount == 0) {
            // For patterns without capture groups, return the full match
            final fullMatch = match.group(0);
            if (fullMatch != null && fullMatch.isNotEmpty) {
              return fullMatch.trim();
            }
          }
        } catch (e) {
          print('Error matching location pattern: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error extracting location from description: $e');
    }
    return 'Sri Lanka';
  }

  String _extractSalaryFromDescription(final String description) {
    try {
      // Look for salary patterns
      final salaryPatterns = [
        RegExp(r'Salary[:\s]+([^<\n]+)', caseSensitive: false),
        RegExp(r'Rs\.?\s*[\d,]+(?:\s*-\s*Rs\.?\s*[\d,]+)?',
            caseSensitive: false),
        RegExp(r'LKR\s*[\d,]+(?:\s*-\s*LKR\s*[\d,]+)?', caseSensitive: false),
      ];

      for (final pattern in salaryPatterns) {
        try {
          final match = pattern.firstMatch(description);
          if (match != null && match.groupCount > 0) {
            // Check if the first capture group exists and is not null
            final salaryGroup = match.group(1);
            if (salaryGroup != null && salaryGroup.isNotEmpty) {
              return salaryGroup.trim();
            }
          } else if (match != null && match.groupCount == 0) {
            // For patterns without capture groups, return the full match
            final fullMatch = match.group(0);
            if (fullMatch != null && fullMatch.isNotEmpty) {
              return fullMatch.trim();
            }
          }
        } catch (e) {
          print('Error matching salary pattern: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error extracting salary from description: $e');
    }
    return 'Salary Not Specified';
  }

  String _extractRequirementsFromDescription(final String description) {
    try {
      // Extract requirements section
      final reqPattern =
          RegExp(r'Requirements?[:\s]+([^<\n]+)', caseSensitive: false);
      final match = reqPattern.firstMatch(description);
      if (match != null && match.groupCount > 0) {
        final reqGroup = match.group(1);
        if (reqGroup != null && reqGroup.isNotEmpty) {
          return reqGroup.trim();
        }
      }
      return 'Requirements not specified';
    } catch (e) {
      print('Error extracting requirements from description: $e');
      return 'Requirements not specified';
    }
  }

  String _extractJobTypeFromDescription(final String description) {
    final lowerDesc = description.toLowerCase();
    if (lowerDesc.contains('full time') || lowerDesc.contains('full-time'))
      return 'Full time';
    if (lowerDesc.contains('part time') || lowerDesc.contains('part-time'))
      return 'Part time';
    if (lowerDesc.contains('contract')) return 'Contract';
    if (lowerDesc.contains('intern')) return 'Internship';
    return 'Full time';
  }

  String _extractExperienceFromDescription(final String description) {
    final lowerDesc = description.toLowerCase();
    if (lowerDesc.contains('senior') ||
        lowerDesc.contains('5+') ||
        lowerDesc.contains('10+')) return 'Senior';
    if (lowerDesc.contains('junior') ||
        lowerDesc.contains('entry') ||
        lowerDesc.contains('1+')) return 'Entry';
    if (lowerDesc.contains('mid') ||
        lowerDesc.contains('3+') ||
        lowerDesc.contains('2+')) return 'Mid';
    return 'Mid';
  }

  bool _isRemoteJob(final String description) {
    final lowerDesc = description.toLowerCase();
    return lowerDesc.contains('remote') ||
        lowerDesc.contains('work from home') ||
        lowerDesc.contains('wfh');
  }

  List<String> _extractSkillsFromDescription(final String description) {
    try {
      final skills = <String>[];
      final commonSkills = [
        'Java',
        'Python',
        'JavaScript',
        'React',
        'Angular',
        'Vue',
        'Node.js',
        'Flutter',
        'React Native',
        'iOS',
        'Android',
        'SQL',
        'MongoDB',
        'AWS',
        'Azure',
        'Docker',
        'Kubernetes',
        'Git',
        'Agile',
        'Scrum'
      ];

      final lowerDesc = description.toLowerCase();
      for (final skill in commonSkills) {
        try {
          if (lowerDesc.contains(skill.toLowerCase())) {
            skills.add(skill);
          }
        } catch (e) {
          print('Error checking skill "$skill": $e');
          continue;
        }
      }

      return skills;
    } catch (e) {
      print('Error extracting skills from description: $e');
      return <String>[];
    }
  }

  DateTime _parseDate(final String dateString) {
    try {
      // Try to parse common date formats
      final formats = [
        'EEE, dd MMM yyyy HH:mm:ss z',
        'dd MMM yyyy HH:mm:ss z',
        'yyyy-MM-dd HH:mm:ss',
      ];

      for (final format in formats) {
        try {
          return DateTime.parse(dateString);
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // If parsing fails, return current date
    }
    return DateTime.now();
  }

  void searchJobs(final String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query;
      _applyFilters();
      _applyCategoryFilters();
    });
  }

  void filterByLocation(final String location) {
    _selectedLocation = location;
    _applyFilters();
    _applyCategoryFilters();
  }

  void filterByType(final String type) {
    _selectedType = type;
    _applyFilters();
    _applyCategoryFilters();
  }

  void filterByExperience(final String experience) {
    _selectedExperience = experience;
    _applyFilters();
    _applyCategoryFilters();
  }

  void filterByCategory(final String? category) {
    _selectedCategory = category;
    _applyFilters();
    _applyCategoryFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedLocation = '';
    _selectedType = '';
    _selectedExperience = '';
    _selectedCategory = null;
    _filteredJobs = _jobs;
    _filteredCategoryJobs = _categoryJobs;
    notifyListeners();
  }

  void _applyFilters() {
    final newFilteredJobs = _jobs.where((final job) {
      final bool matchesSearch = _searchQuery.isEmpty ||
          job.title
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          job.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.guid.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.skills.any((final skill) =>
              skill.toLowerCase().contains(_searchQuery.toLowerCase()));

      final bool matchesLocation = _selectedLocation.isEmpty ||
          _matchesLocationExactly(job.location, _selectedLocation) ||
          (_selectedLocation.toLowerCase() == 'remote' && job.isRemote);

      final bool matchesType = _selectedType.isEmpty ||
          job.type == _selectedType ||
          (job.type == 'Full time' && _selectedType == 'Full-time') ||
          (job.type == 'Part time' && _selectedType == 'Part-time') ||
          (job.type == 'Full-time' && _selectedType == 'Full time') ||
          (job.type == 'Part-time' && _selectedType == 'Part time');

      final bool matchesExperience =
          _selectedExperience.isEmpty || job.experience == _selectedExperience;

      final bool matchesCategory = _selectedCategory == null ||
          _selectedCategory!.isEmpty ||
          job.feedUrl == _selectedCategory;

      return matchesSearch &&
          matchesLocation &&
          matchesType &&
          matchesExperience &&
          matchesCategory;
    }).toList();

    // Only update and notify if the filtered list actually changed
    if (_filteredJobs.length != newFilteredJobs.length ||
        !_listsEqual(_filteredJobs, newFilteredJobs)) {
      _filteredJobs = newFilteredJobs;
      notifyListeners();
    }
  }

  void _applyCategoryFilters() {
    _filteredCategoryJobs = _categoryJobs.where((final job) {
      final bool matchesSearch = _searchQuery.isEmpty ||
          job.title
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          job.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.guid.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.skills.any((final skill) =>
              skill.toLowerCase().contains(_searchQuery.toLowerCase()));

      final bool matchesLocation = _selectedLocation.isEmpty ||
          _matchesLocationExactly(job.location, _selectedLocation) ||
          (_selectedLocation.toLowerCase() == 'remote' && job.isRemote);

      final bool matchesType = _selectedType.isEmpty ||
          job.type == _selectedType ||
          (job.type == 'Full time' && _selectedType == 'Full-time') ||
          (job.type == 'Part time' && _selectedType == 'Part-time') ||
          (job.type == 'Full-time' && _selectedType == 'Full time') ||
          (job.type == 'Part-time' && _selectedType == 'Part time');

      final bool matchesExperience =
          _selectedExperience.isEmpty || job.experience == _selectedExperience;

      final bool matchesCategory = _selectedCategory == null ||
          _selectedCategory!.isEmpty ||
          job.feedUrl == _selectedCategory;

      return matchesSearch &&
          matchesLocation &&
          matchesType &&
          matchesExperience &&
          matchesCategory;
    }).toList();

    notifyListeners();
  }

  Job? getJobById(final String id) {
    try {
      return _jobs.firstWhere((final job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get job count for a specific category by feedUrl
  int getJobCountByCategory(final String feedUrl) {
    return _jobs.where((final job) => job.feedUrl == feedUrl).length;
  }

  // Get all job counts by category
  Map<String, int> getAllJobCountsByCategory() {
    final Map<String, int> counts = {};
    for (final category in RssCategories.categories) {
      counts[category.feedUrl] = getJobCountByCategory(category.feedUrl);
    }
    return counts;
  }

  // Get unique locations from all jobs
  List<String> getUniqueLocations() {
    final Set<String> uniqueLocations = {};

    // Add locations from main jobs
    for (final job in _jobs) {
      if (job.location.isNotEmpty) {
        uniqueLocations.add(job.location);
      }
      // Also add "Remote" if job is remote
      if (job.isRemote) {
        uniqueLocations.add('Remote');
      }
    }

    // Add locations from category jobs
    for (final job in _categoryJobs) {
      if (job.location.isNotEmpty) {
        uniqueLocations.add(job.location);
      }
      // Also add "Remote" if job is remote
      if (job.isRemote) {
        uniqueLocations.add('Remote');
      }
    }

    final List<String> locations = uniqueLocations.toList();
    locations.sort();
    return locations;
  }

  // Helper method to match locations exactly, avoiding partial matches
  bool _matchesLocationExactly(
      final String jobLocation, final String selectedLocation) {
    if (selectedLocation.isEmpty) return true;

    final jobLoc = jobLocation.toLowerCase().trim();
    final selectedLoc = selectedLocation.toLowerCase().trim();

    // Exact match
    if (jobLoc == selectedLoc) return true;

    // Check if the job location starts with the selected location followed by a space or end
    // This prevents "Colombo 1" from matching "Colombo 10"
    final regex = RegExp(r'^' + RegExp.escape(selectedLoc) + r'(?:\s|$)');
    return regex.hasMatch(jobLoc);
  }

  // Helper method to compare two job lists efficiently
  bool _listsEqual(final List<Job> list1, final List<Job> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].comments != list2[i].comments) return false;
    }
    return true;
  }

  // Load favorites from device storage
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedFavorites = prefs.getStringList(_favoritesKey);
      if (savedFavorites != null) {
        _favoriteJobIds.clear();
        _favoriteJobIds.addAll(savedFavorites);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // Save favorites to device storage
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoriteJobIds.toList());
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // Initialize favorites when JobProvider is created
  Future<void> initializeFavorites() async {
    await _loadFavorites();
  }

  // Favorite methods - using job.comments as unique identifier
  bool isJobFavorite(final String jobComments) {
    return _favoriteJobIds.contains(jobComments);
  }

  void toggleFavorite(final String jobComments) {
    if (_favoriteJobIds.contains(jobComments)) {
      _favoriteJobIds.remove(jobComments);
    } else {
      _favoriteJobIds.add(jobComments);
    }
    _saveFavorites(); // Save to device storage
    notifyListeners();
  }

  void addToFavorites(final String jobComments) {
    _favoriteJobIds.add(jobComments);
    _saveFavorites(); // Save to device storage
    notifyListeners();
  }

  void removeFromFavorites(final String jobComments) {
    _favoriteJobIds.remove(jobComments);
    _saveFavorites(); // Save to device storage
    notifyListeners();
  }

  List<Job> getFavoriteJobs() {
    return _jobs
        .where((final job) => _favoriteJobIds.contains(job.comments))
        .toList();
  }

  // View count methods
  Map<String, int> _viewCounts = {};
  StreamSubscription<Map<String, int>>? _viewCountSubscription;

  /// Load view counts for all jobs (optimized)
  Future<void> loadViewCounts() async {
    try {
      // Load view counts in background without blocking UI
      _loadViewCountsInBackground();
    } catch (e) {
      // Silently fail to avoid blocking the app
    }
  }

  /// Load view counts in background (optimized)
  Future<void> _loadViewCountsInBackground() async {
    try {
      // Only load view counts for visible jobs (first 50) to improve performance
      final visibleJobs =
          _jobs.take(50).map((final job) => job.comments).toList();

      if (visibleJobs.isNotEmpty) {
        _viewCounts = await ViewCountService.getViewCounts(visibleJobs);
      }

      // Initialize all jobs with 0 view count
      for (final job in _jobs) {
        _viewCounts.putIfAbsent(job.comments, () => 0);
      }

      // Notify listeners
      notifyListeners();
    } catch (e) {
      // Silently fail - initialize with 0 counts
      for (final job in _jobs) {
        _viewCounts.putIfAbsent(job.comments, () => 0);
      }
      // Notify listeners
      notifyListeners();
    }
  }

  /// Get view count for a specific job
  int getViewCount(final String jobComments) {
    return _viewCounts[jobComments] ?? 0;
  }

  /// Increment view count for a job
  Future<void> incrementViewCount(final String jobComments) async {
    try {
      // Update local count immediately for better UX
      _viewCounts[jobComments] = (_viewCounts[jobComments] ?? 0) + 1;
      notifyListeners();

      // Update Firebase in background (non-blocking) with debouncing
      _debouncedFirebaseUpdate(jobComments);
    } catch (e) {
      // Silently fail
    }
  }

  Timer? _firebaseUpdateTimer;
  final Set<String> _pendingUpdates = {};

  void _debouncedFirebaseUpdate(final String jobComments) {
    _pendingUpdates.add(jobComments);

    _firebaseUpdateTimer?.cancel();
    _firebaseUpdateTimer = Timer(const Duration(seconds: 2), () {
      if (_pendingUpdates.isNotEmpty) {
        _batchUpdateViewCounts();
      }
    });
  }

  Future<void> _batchUpdateViewCounts() async {
    if (_pendingUpdates.isEmpty) return;

    final updates = List<String>.from(_pendingUpdates);
    _pendingUpdates.clear();

    try {
      // Batch update all pending view counts
      await ViewCountService.batchIncrementViewCounts(updates);
    } catch (e) {
      // Silently fail - local counts are already updated
    }
  }

  /// Update view count for a specific job (used when loading from Firestore)
  void updateViewCount(final String jobComments, final int viewCount) {
    _viewCounts[jobComments] = viewCount;
    notifyListeners();
  }

  /// Get jobs with updated view counts (optimized to avoid unnecessary object creation)
  List<Job> get jobsWithViewCounts {
    // Only recreate jobs if view counts have changed
    if (_viewCounts.isEmpty) {
      return _jobs;
    }

    return _jobs.map((final job) {
      final viewCount = getViewCount(job.comments);
      // Only create new job if view count is different
      if (job.viewCount != viewCount) {
        return Job(
          id: job.id,
          title: job.title,
          company: job.company,
          location: job.location,
          salary: job.salary,
          description: job.description,
          requirements: job.requirements,
          type: job.type,
          experience: job.experience,
          postedDate: job.postedDate,
          closingDate: job.closingDate,
          author: job.author,
          jobId: job.jobId,
          comments: job.comments,
          applicantCode: job.applicantCode,
          feedUrl: job.feedUrl,
          publisher: job.publisher,
          isRemote: job.isRemote,
          skills: job.skills,
          guid: job.guid,
          isFavorite: job.isFavorite,
          gradientColors: job.gradientColors,
          viewCount: viewCount,
        );
      }
      return job;
    }).toList();
  }

  /// Get category jobs with updated view counts (optimized)
  List<Job> get categoryJobsWithViewCounts {
    // Only recreate jobs if view counts have changed
    if (_viewCounts.isEmpty) {
      return _categoryJobs;
    }

    return _categoryJobs.map((final job) {
      final viewCount = getViewCount(job.comments);
      // Only create new job if view count is different
      if (job.viewCount != viewCount) {
        return Job(
          id: job.id,
          title: job.title,
          company: job.company,
          location: job.location,
          salary: job.salary,
          description: job.description,
          requirements: job.requirements,
          type: job.type,
          experience: job.experience,
          postedDate: job.postedDate,
          closingDate: job.closingDate,
          author: job.author,
          jobId: job.jobId,
          comments: job.comments,
          applicantCode: job.applicantCode,
          feedUrl: job.feedUrl,
          publisher: job.publisher,
          isRemote: job.isRemote,
          skills: job.skills,
          guid: job.guid,
          isFavorite: job.isFavorite,
          gradientColors: job.gradientColors,
          viewCount: viewCount,
        );
      }
      return job;
    }).toList();
  }

  /// Dispose resources
  @override
  void dispose() {
    _viewCountSubscription?.cancel();
    _searchTimer?.cancel();
    _firebaseUpdateTimer?.cancel();
    super.dispose();
  }
}
