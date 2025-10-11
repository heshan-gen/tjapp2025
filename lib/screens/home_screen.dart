// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/banner_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/category_selector.dart';
import '../widgets/banner_slider.dart';
import 'job_detail_screen.dart';
import 'job_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentMessageIndex = 0;
  Timer? _messageTimer;
  final Set<String> _expandedCards = <String>{};

  final List<String> _loadingMessages = [
    'Bringing you closer to your next big role...',
    'Exploring top career paths tailored for you...',
    'Opening doors to new career possibilities...',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (mounted) {
        context.read<JobProvider>().loadJobs();
        context.read<BannerProvider>().loadBanners();
      }
    });
    _startMessageRotation();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _messageTimer = null;
    super.dispose();
  }

  void _startMessageRotation() {
    _messageTimer = Timer.periodic(const Duration(seconds: 10), (final timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _loadingMessages.length;
          print(
              'DEBUG: Message changed to index $_currentMessageIndex: ${_loadingMessages[_currentMessageIndex]}');
        });
      }
    });
  }

  void _stopMessageRotation() {
    _messageTimer?.cancel();
    _messageTimer = null;
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'topjobs',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (final context, final themeProvider, final child) {
              return IconButton(
                icon: Icon(themeProvider.themeIcon),
                tooltip: themeProvider.themeTooltip,
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (final context, final jobProvider, final child) {
          // Stop message rotation when loading is complete
          if (!jobProvider.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((final _) {
              if (mounted) {
                _stopMessageRotation();
              }
            });
          }

          if (jobProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.beat(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    size: 50,
                  ),
                  const SizedBox(height: 30),
                  TypewriterText(
                    key: ValueKey(_currentMessageIndex),
                    text: _loadingMessages[_currentMessageIndex],
                    duration: const Duration(milliseconds: 80),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 10),
                const CategorySelector(),
                const SizedBox(height: 24),
                _buildSearchBarWithExpandButton(),
                const SizedBox(height: 24),
                _buildHotJobs(jobProvider),
                const SizedBox(height: 0),
                _buildRecentJobs(jobProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer2<JobProvider, BannerProvider>(
      builder: (final context, final jobProvider, final bannerProvider,
          final child) {
        return BannerSlider(
          banners: bannerProvider.banners,
          height: 160.0,
          borderRadius: 10.0,
          jobCount: jobProvider.jobs.length,
        );
      },
    );
  }

  Widget _buildSearchBarWithExpandButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Jobs',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Job title, company, or skills...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).hintColor,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    prefixStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (final value) {
                    if (mounted) {
                      context.read<JobProvider>().searchJobs(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 192, 20),
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                icon: const Icon(Icons.expand_rounded,
                    size: 20, color: Colors.black),
                onPressed: () {
                  // Toggle all cards expansion
                  if (mounted) {
                    setState(() {
                      if (_expandedCards.length ==
                          context
                              .read<JobProvider>()
                              .jobsWithViewCounts
                              .length) {
                        _expandedCards.clear();
                      } else {
                        _expandedCards.addAll(
                          context
                              .read<JobProvider>()
                              .jobsWithViewCounts
                              .map((final job) => job.comments),
                        );
                      }
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHotJobs(final JobProvider jobProvider) {
    // Filter jobs with DEFZZZ guid only
    final hotJobs = jobProvider.jobsWithViewCounts
        .where((final job) => job.guid.contains('DEFZZZ'))
        .take(100)
        .toList();

    if (hotJobs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Hot Jobs',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF892621),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Top ${hotJobs.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _expandedCards.isNotEmpty
              ? 140
              : 95, // Dynamic height based on expansion state
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hotJobs.length,
            itemBuilder: (final context, final index) {
              final job = hotJobs[index];
              return _buildJobCard(job, isHot: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentJobs(final JobProvider jobProvider) {
    // Group jobs by their source feed and get top 10 from each category
    final Map<String, List<Job>> jobsByCategory = {};

    for (final job in jobProvider.jobsWithViewCounts) {
      // Extract category from feed URL
      final String category = _getCategoryFromFeedUrl(job.feedUrl);

      if (!jobsByCategory.containsKey(category)) {
        jobsByCategory[category] = [];
      }
      jobsByCategory[category]!.add(job);
    }

    // Get top 10 jobs from each category
    final List<Job> recentJobs = [];
    for (final category in jobsByCategory.keys) {
      final categoryJobs = jobsByCategory[category]!;
      categoryJobs.sort((final a, final b) =>
          b.postedDate.compareTo(a.postedDate)); // Sort by date descending
      recentJobs.addAll(categoryJobs.take(10)); // Take 10 from each category
    }

    // Sort all recent jobs by date
    recentJobs.sort((final a, final b) => b.postedDate.compareTo(a.postedDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Recent Jobs',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (final context) => const JobListScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF0BE28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('View All',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.labelLarge?.color,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentJobs.length,
          itemBuilder: (final context, final index) {
            final job = recentJobs[index];
            return _buildJobCard(job);
          },
        ),
      ],
    );
  }

  Widget _buildJobCard(final Job job, {final bool isHot = false}) {
    final isExpanded = _expandedCards.contains(job.comments);

    return Container(
      width: isHot ? 300 : double.infinity,
      margin: EdgeInsets.only(
        right: isHot ? 5 : 0,
        bottom: 5,
      ),
      child: Card(
        elevation: 2,
        // color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (final context) => JobDetailScreen(job: job),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content row (always visible)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side content (job details)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  // color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: job.publisher.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          'https://www.topjobs.lk/logo/${job.publisher}',
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.fitWidth,
                                          errorBuilder: (final context,
                                              final error, final stackTrace) {
                                            return const Icon(
                                              Icons.work,
                                              color: Colors.white,
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.work,
                                        color: Theme.of(context).primaryColor,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.title
                                          .trim()
                                          .replaceAll(RegExp(r'\s+'), ' ')
                                          .replaceAll('?', '-'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.color,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      job.company
                                          .trim()
                                          .replaceAll(RegExp(r'\s+'), ' '),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Expanded content (only shown when expanded)
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    job.location,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.arrow_circle_right,
                                  size: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    job.description,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                // Job Type
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: const Color(0xFFF0BE28)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    job.type,
                                    style: const TextStyle(
                                      color: Color(0xFFF0BE28),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Remote indicator after closing date
                                if (job.isRemote) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Remote',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                // Closing Date right next to job type
                                if (job.closingDate != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color:
                                        _getClosingDateColor(job.closingDate!),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatClosingDate(job.closingDate!),
                                    style: TextStyle(
                                      color: _getClosingDateColor(
                                          job.closingDate!),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                // View count (only show if > 0)
                                if (job.viewCount > 0) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.visibility,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${job.viewCount} views',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Right side buttons
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        // Expand/Collapse button
                        GestureDetector(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                if (isExpanded) {
                                  _expandedCards.remove(job.comments);
                                } else {
                                  _expandedCards.add(job.comments);
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Favorite indicator
                        Consumer<JobProvider>(
                          builder:
                              (final context, final jobProvider, final child) {
                            final isFavorite =
                                jobProvider.isJobFavorite(job.comments);
                            return GestureDetector(
                              onTap: () {
                                jobProvider.toggleFavorite(job.comments);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isFavorite
                                          ? 'Removed from favorites'
                                          : 'Added to favorites',
                                    ),
                                    backgroundColor: isFavorite
                                        ? const Color.fromARGB(
                                            255, 252, 144, 12)
                                        : const Color.fromARGB(255, 5, 177, 56),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isFavorite
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? Colors.red
                                      : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  String _formatDate(final DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }

  String _formatClosingDate(final DateTime closingDate) {
    final now = DateTime.now();
    final difference = closingDate.difference(now);

    if (difference.inDays < 0) {
      return 'Closed';
    } else if (difference.inDays == 0) {
      return 'Closes today';
    } else if (difference.inDays == 1) {
      return 'Closes in 1 day';
    } else {
      return '${difference.inDays} days';
    }
  }

  Color _getClosingDateColor(final DateTime closingDate) {
    final now = DateTime.now();
    final difference = closingDate.difference(now);

    if (difference.inDays < 0) {
      return Colors.grey;
    } else if (difference.inDays < 3) {
      return Colors.red;
    } else if (difference.inDays <= 5) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getCategoryFromFeedUrl(final String feedUrl) {
    if (feedUrl.isEmpty) {
      return 'General';
    }

    if (feedUrl.contains('it_sware_db_qa_web_graphics_gis')) {
      return 'IT & Software';
    } else if (feedUrl.contains('it_hware_networks_systems')) {
      return 'IT Hardware & Networks';
    } else if (feedUrl.contains('accounting_auditing_finance')) {
      return 'Accounting & Finance';
    } else if (feedUrl.contains('banking_insurance')) {
      return 'Banking & Insurance';
    } else if (feedUrl.contains('sales_marketing_merchandising')) {
      return 'Sales & Marketing';
    } else if (feedUrl.contains('hr_training')) {
      return 'Human Resources';
    } else if (feedUrl.contains('corporate_management_analysts')) {
      return 'Corporate Management';
    } else if (feedUrl.contains('office_admin_secretary_receptionist')) {
      return 'Office Administration';
    } else if (feedUrl.contains('civil_eng_interior_design_architecture')) {
      return 'Civil Engineering & Architecture';
    } else if (feedUrl.contains('it_telecoms')) {
      return 'IT & Telecommunications';
    } else if (feedUrl.contains('customer_relations_public_relations')) {
      return 'Customer Relations';
    } else if (feedUrl.contains('logistics_warehouse_transport')) {
      return 'Logistics & Transport';
    } else if (feedUrl.contains('eng_mech_auto_elec')) {
      return 'Engineering';
    } else if (feedUrl.contains('manufacturing_operations')) {
      return 'Manufacturing';
    } else if (feedUrl.contains('media_advert_communication')) {
      return 'Media & Communication';
    } else if (feedUrl.contains('HOTELS_RESTAURANTS_HOSPITALITY')) {
      return 'Hospitality';
    } else if (feedUrl.contains('TRAVEL_TOURISM')) {
      return 'Travel & Tourism';
    } else if (feedUrl.contains('sports_fitness_recreation')) {
      return 'Sports & Fitness';
    } else if (feedUrl.contains('hospital_nursing_healthcare')) {
      return 'Healthcare';
    } else if (feedUrl.contains('legal_law')) {
      return 'Legal';
    } else if (feedUrl.contains('supervision_quality_control')) {
      return 'Quality Control';
    } else if (feedUrl.contains('apparel_clothing')) {
      return 'Apparel & Clothing';
    } else if (feedUrl.contains('ticketing_airline_marine')) {
      return 'Aviation & Marine';
    } else if (feedUrl.contains('EDUCATION')) {
      return 'Education';
    } else if (feedUrl.contains('rnd_science_research')) {
      return 'Research & Development';
    } else if (feedUrl.contains('agriculture_dairy_environment')) {
      return 'Agriculture & Environment';
    } else if (feedUrl.contains('security')) {
      return 'Security';
    } else if (feedUrl.contains('fashion_design_beauty')) {
      return 'Fashion & Beauty';
    } else if (feedUrl.contains('international_development')) {
      return 'International Development';
    } else if (feedUrl.contains('kpo_bpo')) {
      return 'KPO & BPO';
    } else if (feedUrl.contains('imports_exports')) {
      return 'Import & Export';
    } else {
      return 'General';
    }
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle? style;
  final TextAlign textAlign;

  const TypewriterText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 50),
    this.style,
    this.textAlign = TextAlign.center,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayText = '';
  int _currentIndex = 0;
  Timer? _timer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _startCursorBlink();
  }

  @override
  void didUpdateWidget(final TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      print('DEBUG: TypewriterText received new text: ${widget.text}');
      _resetTyping();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    _timer = null;
    _cursorTimer = null;
    super.dispose();
  }

  void _resetTyping() {
    print('DEBUG: Resetting typewriter animation');
    _timer?.cancel();
    _currentIndex = 0;
    _displayText = '';
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.duration, (final timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayText = widget.text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer =
        Timer.periodic(const Duration(milliseconds: 500), (final timer) {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    return RichText(
      textAlign: widget.textAlign,
      text: TextSpan(
        style: widget.style ??
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
        children: [
          TextSpan(text: _displayText),
          if (_showCursor && _currentIndex < widget.text.length)
            TextSpan(
              text: '|',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
