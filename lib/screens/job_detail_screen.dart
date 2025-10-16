// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../services/company_service.dart';
import '../services/web_scraping_service.dart';
import '../widgets/image_viewer_dialog.dart';
import 'job_apply_screen.dart';
// import '../widgets/job_rating_widget.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({
    super.key,
    required this.job,
    this.sourceContext = 'job_list',
  });
  final Job job;
  final String sourceContext;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen>
    with TickerProviderStateMixin {
  // ignore: unused_field, use_late_for_private_fields_and_variables
  String? _companyInfo;
  // ignore: unused_field
  bool _isLoadingCompanyInfo = true;
  ScrapedJobContent? _scrapedContent;
  bool _isLoadingScrapedContent = false;
  String? _scrapingError;

  // Swipe animation controllers
  late AnimationController _indicatorAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _pageTransitionController;
  late Animation<double> _indicatorAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _pageTransitionAnimation;

  // Swipe state
  double _swipeOffset = 0.0;
  bool _isSwiping = false;
  String? _swipeDirection;
  final bool _isTransitioning = false;

  LinearGradient _getJobGradient() {
    // Use job's specific gradient colors if available, otherwise fallback to default
    if (widget.job.gradientColors.isNotEmpty) {
      return LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: widget.job.gradientColors,
      );
    }

    // Fallback to default gradient - Dark colors for better white text contrast
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(255, 37, 99, 235),
        Color.fromARGB(255, 147, 51, 234),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
    _loadScrapedContent();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _indicatorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _indicatorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _indicatorAnimationController,
      curve: Curves.easeInOut,
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeInOut,
    ));

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _pageTransitionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    ));

    // Start content animation on init
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _indicatorAnimationController.dispose();
    _contentAnimationController.dispose();
    _pageTransitionController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyInfo() async {
    try {
      final companyInfo =
          await CompanyService.getCompanyInfo(widget.job.company);
      if (mounted) {
        setState(() {
          _companyInfo = companyInfo;
          _isLoadingCompanyInfo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _companyInfo =
              'Learn more about ${widget.job.company} and their career opportunities. Visit their website for detailed information about the company culture, values, and available positions.';
          _isLoadingCompanyInfo = false;
        });
      }
    }
  }

  Future<void> _loadScrapedContent() async {
    setState(() {
      _isLoadingScrapedContent = true;
      _scrapingError = null;
    });

    try {
      // First, get the application type by checking the page
      final initialUrl = _generateApplicationUrl();
      final scrapedContent =
          await WebScrapingService.fetchJobDescription(initialUrl);

      if (mounted) {
        setState(() {
          _scrapedContent = scrapedContent;
          _isLoadingScrapedContent = false;
          if (scrapedContent == null) {
            _scrapingError = 'Unable to fetch additional job details';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingScrapedContent = false;
          _scrapingError = 'Failed to load additional details: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _retryScraping() async {
    await _loadScrapedContent();
  }

  void _navigateToJob(final Job job) {
    // Increment view count for the new job
    context.read<JobProvider>().incrementViewCount(job.comments);

    // Replace current screen with new job detail screen with custom transition
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (final context, final animation, final secondaryAnimation) =>
                JobDetailScreen(
          job: job,
          sourceContext: widget.sourceContext,
        ),
        transitionsBuilder: (final context, final animation,
            final secondaryAnimation, final child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _handleSwipeStart(final DragStartDetails details) {
    setState(() {
      _isSwiping = true;
      _swipeOffset = 0.0;
      _swipeDirection = null;
    });
    _indicatorAnimationController.forward();
  }

  void _handleSwipeUpdate(final DragUpdateDetails details) {
    if (!_isSwiping) return;

    setState(() {
      _swipeOffset = details.delta.dx;
      _swipeDirection = details.delta.dx > 0 ? 'right' : 'left';
    });
  }

  void _handleSwipeEnd(final DragEndDetails details) {
    if (!_isSwiping) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    const threshold = 100.0; // Minimum swipe distance
    const velocityThreshold = 300.0; // Minimum velocity for quick swipe

    setState(() {
      _isSwiping = false;
    });

    _indicatorAnimationController.reverse();

    // Check if swipe is significant enough
    if ((_swipeOffset.abs() > threshold ||
        velocity.abs() > velocityThreshold)) {
      if (_swipeDirection == 'left' && velocity < -velocityThreshold) {
        _navigateToNextJob();
      } else if (_swipeDirection == 'right' && velocity > velocityThreshold) {
        _navigateToPreviousJob();
      }
    }

    setState(() {
      _swipeOffset = 0.0;
      _swipeDirection = null;
    });
  }

  void _navigateToNextJob() {
    final jobProvider = context.read<JobProvider>();
    final jobList = jobProvider.getJobListForNavigation(widget.sourceContext);
    final currentIndex =
        jobList.indexWhere((final job) => job.comments == widget.job.comments);

    if (currentIndex < jobList.length - 1) {
      _navigateToJob(jobList[currentIndex + 1]);
    }
  }

  void _navigateToPreviousJob() {
    final jobProvider = context.read<JobProvider>();
    final jobList = jobProvider.getJobListForNavigation(widget.sourceContext);
    final currentIndex =
        jobList.indexWhere((final job) => job.comments == widget.job.comments);

    if (currentIndex > 0) {
      _navigateToJob(jobList[currentIndex - 1]);
    }
  }

  Widget _buildSwipeIndicators() {
    if (!_isSwiping) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _indicatorAnimation,
        builder: (final context, final child) {
          return Opacity(
            opacity: _indicatorAnimation.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_swipeDirection == 'right')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Previous',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_swipeDirection == 'left')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransitionOverlay() {
    if (!_isTransitioning) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _pageTransitionAnimation,
      builder: (final context, final child) {
        return Container(
          color: Colors.black.withOpacity(_pageTransitionAnimation.value * 0.3),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: _getJobGradient().colors.first,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading job details...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationBar(final BuildContext context) {
    return Consumer<JobProvider>(
      builder: (final context, final jobProvider, final child) {
        // Get the appropriate job list based on source context
        final jobList =
            jobProvider.getJobListForNavigation(widget.sourceContext);
        final currentIndex = jobList
            .indexWhere((final job) => job.comments == widget.job.comments);
        final previousJob = currentIndex > 0 ? jobList[currentIndex - 1] : null;
        final nextJob = currentIndex < jobList.length - 1
            ? jobList[currentIndex + 1]
            : null;
        final totalJobs = jobList.length;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              // Progress indicator
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (currentIndex + 1) / totalJobs,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _getJobGradient(),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Navigation controls
              Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                    // BoxShadow(
                    //   color: Theme.of(context).primaryColor.withOpacity(0.1),
                    //   blurRadius: 10,
                    //   offset: const Offset(0, 2),
                    // ),
                  ],
                ),
                child: Row(
                  children: [
                    // Previous button
                    Expanded(
                      child: _buildNavigationButton(
                        context: context,
                        isEnabled: previousJob != null,
                        isPrevious: true,
                        onTap: previousJob != null
                            ? () => _navigateToJob(previousJob)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Job counter with enhanced design
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: _getJobGradient(),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _getJobGradient().colors.first.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${currentIndex + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'of $totalJobs',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Next button
                    Expanded(
                      child: _buildNavigationButton(
                        context: context,
                        isEnabled: nextJob != null,
                        isPrevious: false,
                        onTap: nextJob != null
                            ? () => _navigateToJob(nextJob)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationButton({
    required final BuildContext context,
    required final bool isEnabled,
    required final bool isPrevious,
    required final VoidCallback? onTap,
  }) {
    final jobGradient = _getJobGradient();
    final gradientColors = jobGradient.colors;
    final primaryColor = gradientColors.first;
    final secondaryColor =
        gradientColors.length > 1 ? gradientColors[1] : primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Use white colors in dark mode, gradient colors in light mode
    final buttonColor =
        isEnabled ? (isDarkMode ? Colors.white : primaryColor) : Colors.grey;
    final iconBackgroundColor = isEnabled
        ? (isDarkMode
            ? Colors.white.withOpacity(0.2)
            : primaryColor.withOpacity(0.2))
        : Colors.grey.withOpacity(0.2);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ]
                      : [
                          primaryColor.withOpacity(0.1),
                          secondaryColor.withOpacity(0.05),
                        ],
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.1),
                    Colors.grey.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isEnabled
                ? (isDarkMode
                    ? Colors.white.withOpacity(0.3)
                    : primaryColor.withOpacity(0.3))
                : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPrevious) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: buttonColor,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Previous',
                style: TextStyle(
                  color: buttonColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                'Next',
                style: TextStyle(
                  color: buttonColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: buttonColor,
                    size: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getApplicationTypeDisplayText(final String applicationType) {
    switch (applicationType) {
      case 'email':
        return 'Apply by Email';
      case 'online_cv':
        return 'Apply by Online CV';
      case 'do_not_receive':
      default:
        return 'Apply Now';
    }
  }

  // String _getApplicationUrl() {
  //   // Only show the anchor link from scraped content
  //   if (_scrapedContent?.anchorLink != null &&
  //       _scrapedContent!.anchorLink!.isNotEmpty) {
  //     return _scrapedContent!.anchorLink!;
  //   } else {
  //     return 'No anchor link found';
  //   }
  // }

  String _generateApplicationUrl(
      {final String applicationType = 'do_not_receive'}) {
    String pgValue;
    switch (applicationType) {
      case 'email':
        pgValue = 'tjappave';
        break;
      case 'online_cv':
        pgValue = 'tjappavo';
        break;
      case 'do_not_receive':
      default:
        pgValue = 'tjappdonotvish';
        break;
    }

    final Uri toLaunch = Uri(
      scheme: 'https',
      host: 'www.topjobs.lk',
      path: 'employer/JobAdvertismentServlet',
      queryParameters: {
        'ac': widget.job.applicantCode,
        'jc': widget.job.comments,
        'ec': widget.job.guid,
        'pg': pgValue,
      },
    );
    return toLaunch.toString();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: _getJobGradient(),
          ),
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
          Consumer<JobProvider>(
            builder: (final context, final jobProvider, final child) {
              final isFavorite = jobProvider.isJobFavorite(widget.job.comments);
              return Container(
                margin: EdgeInsets.zero,
                // decoration: BoxDecoration(
                //   color: Colors.white.withOpacity(0.2),
                //   borderRadius: BorderRadius.circular(12),
                // ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    jobProvider.toggleFavorite(widget.job.comments);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? 'Job removed from favorites'
                              : 'Job saved to favorites',
                        ),
                        backgroundColor: isFavorite
                            ? const Color.fromARGB(255, 252, 144, 12)
                            : const Color.fromARGB(255, 5, 177, 56),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: _handleSwipeStart,
            onPanUpdate: _handleSwipeUpdate,
            onPanEnd: _handleSwipeEnd,
            child: AnimatedBuilder(
              animation: _contentAnimationController,
              builder: (final context, final child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  transform:
                      Matrix4.translationValues(_swipeOffset * 0.1, 0, 0),
                  child: FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: SlideTransition(
                      position: _contentSlideAnimation,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNavigationBar(context),
                            _buildJobHeader(context),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  _buildJobInfo(),
                                  const SizedBox(height: 20),
                                  _buildJobDescription(),
                                  if (widget.job.requirements !=
                                      'Requirements not specified') ...[
                                    const SizedBox(height: 20),
                                    _buildRequirements(),
                                  ],
                                  if (widget.job.skills.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    _buildSkills(context),
                                  ],
                                  if (widget.job.company.toLowerCase() !=
                                      'company name withheld') ...[
                                    const SizedBox(height: 20),
                                    _buildCompanyInfo(context),
                                  ],
                                  const SizedBox(height: 20),
                                  _buildRatingSection(context),
                                  const SizedBox(
                                      height:
                                          20), // Add bottom padding for fixed footer
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildSwipeIndicators(),
          _buildTransitionOverlay(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: _buildActionButtons(context),
        ),
      ),
    );
  }

  Widget _buildJobHeader(final BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: _getJobGradient(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.job.publisher == 'defzzz.gif'
                    ? // Show only hot icon for defzzz.gif
                    Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.red,
                          size: 32,
                        ),
                      )
                    : Container(
                        width: 160,
                        height: 70,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: widget.job.publisher.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  'https://www.topjobs.lk/logo/${widget.job.publisher}',
                                  width: 140,
                                  height: 70,
                                  fit: BoxFit.fitHeight,
                                  errorBuilder: (final context, final error,
                                      final stackTrace) {
                                    return const Icon(
                                      Icons.work,
                                      color: Colors.white,
                                      size: 35,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.work,
                                color: Colors.white,
                                size: 35,
                              ),
                      ),
                const SizedBox(height: 16),
                Text(
                  widget.job.title
                      .trim()
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .replaceAll('?', '-'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.job.company.trim().replaceAll(RegExp(r'\s+'), ' '),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoChip(
                      icon: Icons.location_on,
                      text: widget.job.location,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    if (widget.job.isRemote) ...[
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        icon: Icons.home_work,
                        text: 'Remote',
                        color: Colors.greenAccent,
                        backgroundColor: Colors.greenAccent.withOpacity(0.2),
                      ),
                    ],
                    if (widget.job.salary != 'Salary Not Specified') ...[
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        icon: Icons.attach_money,
                        text: widget.job.salary,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ],
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.schedule,
                      text: widget.job.type,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
            ),
            // const SizedBox(height: 16),
            // Center(
            //   child: SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         _buildBadge(
            //           text: widget.job.type,
            //           color: Theme.of(context).cardColor,
            //           backgroundColor: Colors.white.withOpacity(0.2),
            //         ),
            //         const SizedBox(width: 8),
            //         _buildBadge(
            //           text: widget.job.experience,
            //           color: Theme.of(context).cardColor,
            //           backgroundColor: Colors.white.withOpacity(0.2),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required final IconData icon,
    required final String text,
    required final Color color,
    final Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildBadge({
  //   required final String text,
  //   required final Color color,
  //   required final Color backgroundColor,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //     decoration: BoxDecoration(
  //       color: backgroundColor,
  //       borderRadius: BorderRadius.circular(5),
  //       border: Border.all(
  //         color: Colors.white.withOpacity(0.3),
  //         width: 1,
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(
  //           text,
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontSize: 10,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildJobInfo() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0DA2DD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Color(0xFF0DA2DD),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Job Information',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Priority 5-6: Experience and Posted Date
            _buildInfoRowPair(
              'Experience',
              widget.job.experience,
              Icons.trending_up,
              'Posted',
              _formatDate(widget.job.postedDate),
              Icons.schedule,
            ),
            // Priority 7-8: Closing Date and Job ID (if available)
            if (widget.job.closingDate != null)
              _buildInfoRowPair(
                'Closing Date',
                _formatDate(widget.job.closingDate!),
                Icons.event,
                'Job ID',
                widget.job.jobId.isNotEmpty ? widget.job.jobId : 'N/A',
                Icons.tag,
              ),

            // // Application Button Type
            // if (_scrapedContent != null)
            //   _buildInfoRowPair(
            //     'Application Type',
            //     _getApplicationTypeDisplayText(
            //         _scrapedContent!.applicationType),
            //     Icons.touch_app,
            //     'Application URL',
            //     _getApplicationUrl(),
            //     Icons.link,
            //   ),

            // Priority 3-4: Salary and Type (key decision factors)
            // if (widget.job.salary != "Salary Not Specified")
            //   _buildInfoRowPair(
            //     'Salary',
            //     widget.job.salary,
            //     Icons.attach_money,
            //     'Type',
            //     widget.job.type,
            //     Icons.work_outline,
            //   )
            // else
            //   Container(
            //     margin: const EdgeInsets.only(bottom: 12),
            //     child: Row(
            //       children: [
            //         Expanded(
            //           child: _buildInfoRow(
            //               'Type', widget.job.type, Icons.work_outline),
            //         ),
            //         const SizedBox(width: 12),
            //         const Expanded(child: SizedBox()),
            //       ],
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowPair(
      final String label1,
      final String value1,
      final IconData icon1,
      final String label2,
      final String value2,
      final IconData icon2) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoRow(label1, value1, icon1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: label2.isEmpty
                ? const SizedBox()
                : _buildInfoRow(label2, value2, icon2),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      final String label, final String value, final IconData icon) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(
          // color: const Color(0xFFF8FAFC),
          // borderRadius: BorderRadius.circular(10),
          // border: Border.all(
          //   color: const Color(0xFFE2E8F0),
          //   width: 1,
          // ),
          ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 138, 138, 138).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDescription() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Job Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(
                  // color: const Color(0xFFF8FAFC),
                  // borderRadius: BorderRadius.circular(12),
                  // border: Border.all(
                  //   color: const Color(0xFFE2E8F0),
                  //   width: 1,
                  // ),
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show original description first
                  if (widget.job.description != 'Please refer the vacancy...')
                    Text(
                      widget.job.description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),

                  // Show loading indicator for scraped content
                  if (_isLoadingScrapedContent) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LoadingAnimationWidget.beat(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          size: 50,
                        ),
                      ),
                    ),
                  ],

                  // Show error message with retry button
                  if (_scrapingError != null && !_isLoadingScrapedContent) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber,
                              color: Colors.orange[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _scrapingError!,
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _retryScraping,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.orange[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Show scraped content if available
                  if (_scrapedContent != null && !_isLoadingScrapedContent) ...[
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE2E8F0)),
                    // const SizedBox(height: 16),
                    // const Text(
                    //   'Additional Details',
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.bold,
                    //     color: Theme.of(context).textTheme.titleMedium?.color,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    Text(
                      _scrapedContent!.description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),

                    // Display images if available
                    if (_scrapedContent!.imageUrls.isNotEmpty) ...[
                      // const SizedBox(height: 16),
                      // const Text(
                      //   'Images',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.bold,
                      //     color: Theme.of(context).textTheme.titleMedium?.color,
                      //   ),
                      // ),
                      const SizedBox(height: 8),
                      ..._scrapedContent!.imageUrls.asMap().entries.map(
                        (final entry) {
                          final index = entry.key;
                          final imageUrl = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                showImageViewer(
                                  context,
                                  imageUrl,
                                  title: 'Artwork ${index + 1}',
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (final context, final error,
                                          final stackTrace) {
                                        return Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 48,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Zoom icon overlay
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_in,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirements() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.checklist_outlined,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Requirements',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.job.requirements,
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkills(final BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.stars_outlined,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Required Skills',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.job.skills.map((final skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFF7C3AED),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(final BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // child: Padding(
      //   padding: const EdgeInsets.all(8),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Row(
      //         children: [
      //           Container(
      //             padding: const EdgeInsets.all(4),
      //             decoration: BoxDecoration(
      //               color: const Color(0xFF06B6D4).withOpacity(0.1),
      //               borderRadius: BorderRadius.circular(5),
      //             ),
      //             child: const Icon(
      //               Icons.business_outlined,
      //               color: Color(0xFF06B6D4),
      //               size: 20,
      //             ),
      //           ),
      //           const SizedBox(width: 12),
      //           Text(
      //             'About Company',
      //             style: TextStyle(
      //               fontSize: 14,
      //               fontWeight: FontWeight.bold,
      //               color: Theme.of(context).textTheme.titleMedium?.color,
      //             ),
      //           ),
      //         ],
      //       ),
      //       const SizedBox(height: 20),
      //       Container(
      //         padding: const EdgeInsets.only(bottom: 5),
      //         child: Row(
      //           children: [
      //             Container(
      //               width: 40,
      //               height: 40,
      //               decoration: BoxDecoration(
      //                 gradient: const LinearGradient(
      //                   colors: [
      //                     Color(0xFF06B6D4),
      //                     Color(0xFF0891B2),
      //                   ],
      //                 ),
      //                 borderRadius: BorderRadius.circular(5),
      //                 boxShadow: [
      //                   BoxShadow(
      //                     color: const Color(0xFF06B6D4).withOpacity(0.3),
      //                     blurRadius: 8,
      //                     offset: const Offset(0, 4),
      //                   ),
      //                 ],
      //               ),
      //               child: const Icon(
      //                 Icons.business,
      //                 color: Colors.white,
      //                 size: 24,
      //               ),
      //             ),
      //             const SizedBox(width: 16),
      //             Expanded(
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Text(
      //                     widget.job.company
      //                         .trim()
      //                         .replaceAll(RegExp(r'\s+'), ' '),
      //                     style: TextStyle(
      //                       fontSize: 16,
      //                       fontWeight: FontWeight.bold,
      //                       color:
      //                           Theme.of(context).textTheme.titleLarge?.color,
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       const SizedBox(height: 10),
      //       if (_isLoadingCompanyInfo)
      //         Center(
      //           child: Padding(
      //             padding: const EdgeInsets.all(16.0),
      //             child: LoadingAnimationWidget.beat(
      //               color: Theme.of(context).brightness == Brightness.dark
      //                   ? Colors.white
      //                   : Theme.of(context).primaryColor,
      //               size: 50,
      //             ),
      //           ),
      //         )
      //       else
      //         Text(
      //           _companyInfo ?? 'About Company',
      //           style: TextStyle(
      //             fontSize: 12,
      //             color: Theme.of(context).textTheme.titleLarge?.color,
      //             height: 1.5,
      //           ),
      //         ),
      //       const SizedBox(height: 8),
      //       GestureDetector(
      //         onTap: () {
      //           // Open map with company location
      //           _openMap();
      //         },
      //         child: Container(
      //           padding:
      //               const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      //           decoration: BoxDecoration(
      //             color: const Color(0xFF06B6D4).withOpacity(0.1),
      //             borderRadius: BorderRadius.circular(8),
      //             border: Border.all(
      //               color: const Color(0xFF06B6D4).withOpacity(0.3),
      //               width: 1,
      //             ),
      //           ),
      //           child: const Row(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Icon(
      //                 Icons.location_on,
      //                 size: 16,
      //                 color: Color(0xFF06B6D4),
      //               ),
      //               SizedBox(width: 4),
      //               Text(
      //                 'View on Map',
      //                 style: TextStyle(
      //                   fontSize: 12,
      //                   color: Color(0xFF06B6D4),
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  // Future<void> _openMap() async {
  //   try {
  //     // You can customize this URL based on your needs
  //     // This will open the default map app with a search for the company name
  //     final companyName = widget.job.company.trim();
  //     final encodedCompany = Uri.encodeComponent(companyName);
  //     final mapUrl =
  //         'https://www.google.com/maps/search/?api=1&query=$encodedCompany';

  //     final Uri uri = Uri.parse(mapUrl);
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri, mode: LaunchMode.externalApplication);
  //     } else {
  //       // Fallback to a general search
  //       final fallbackUrl =
  //           'https://www.google.com/maps/search/$encodedCompany';
  //       final Uri fallbackUri = Uri.parse(fallbackUrl);
  //       if (await canLaunchUrl(fallbackUri)) {
  //         await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
  //       }
  //     }
  //   } catch (e) {
  //     print('Error opening map: $e');
  //     // You could show a snackbar or dialog here to inform the user
  //   }
  // }

  Future<void> _launchApplicationUrl() async {
    try {
      // Check if application type is email and we have scraped content
      if (_scrapedContent != null &&
          _scrapedContent!.applicationType == 'email') {
        // Navigate to job apply screen for email applications
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (final context) => JobApplyScreen(
              job: widget.job,
              scrapedContent: _scrapedContent!,
            ),
          ),
        );
        return;
      }

      // For other application types, use the original URL launching logic
      Uri toLaunch;

      // Check if there's an anchor link from scraped content
      if (_scrapedContent?.anchorLink != null &&
          _scrapedContent!.anchorLink!.isNotEmpty) {
        // Use the anchor link from the image
        toLaunch = Uri.parse(_scrapedContent!.anchorLink!);
      } else {
        // Fallback to the generated application URL
        final String applicationType =
            _scrapedContent?.applicationType ?? 'do_not_receive';
        final String applicationUrl =
            _generateApplicationUrl(applicationType: applicationType);
        toLaunch = Uri.parse(applicationUrl);
      }

      if (await canLaunchUrl(toLaunch)) {
        await launchUrl(toLaunch, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $toLaunch');
      }
    } catch (e) {
      // Handle error - you might want to show a snackbar or dialog
      print('Error launching URL: $e');
    }
  }

  Future<void> _shareJob() async {
    final Uri shareUrl = Uri(
      scheme: 'https',
      host: 'www.topjobs.lk',
      path: 'employer/JobAdvertismentServlet',
      queryParameters: {
        'ac': widget.job.applicantCode,
        'jc': widget.job.comments,
        'ec': widget.job.guid,
        'pg': 'tjappshare',
      },
    );

    // Create Google Maps URL for company location
    final String companyName = widget.job.company.trim();
    final String location = widget.job.location.trim();
    final String mapQuery = '$companyName, $location';
    final String encodedMapQuery = Uri.encodeComponent(mapQuery);
    final String mapUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedMapQuery';

    final String shareText = 'Check out this job opportunity!\n\n'
        '${widget.job.title} at ${widget.job.company}\n'
        'Location: ${widget.job.location}\n'
        'Salary: ${widget.job.salary}\n'
        'Type: ${widget.job.type}\n\n'
        '📍 Company Location: $mapUrl\n'
        '🔗 Apply here: ${shareUrl.toString()}';

    try {
      // Check if there are images available to share
      if (_scrapedContent != null && _scrapedContent!.imageUrls.isNotEmpty) {
        // Try to download image with timeout to avoid long delays
        try {
          final String imageUrl = _scrapedContent!.imageUrls.first;
          final File? imageFile = await _downloadImageWithTimeout(imageUrl);

          if (imageFile != null) {
            // Share with image and text
            await Share.shareXFiles(
              [XFile(imageFile.path)],
              text: shareText,
            );
          } else {
            // Fallback to text-only sharing if image download fails
            await Share.share(shareText);
          }
        } catch (e) {
          // If image download times out or fails, share text only
          print('Image download failed, sharing text only: $e');
          await Share.share(shareText);
        }
      } else {
        // No images available, share text only
        await Share.share(shareText);
      }
    } catch (e) {
      print('Error sharing job: $e');
    }
  }

  // Download image with timeout to prevent long delays
  Future<File?> _downloadImageWithTimeout(final String imageUrl) async {
    try {
      return await Future.any([
        _downloadImage(imageUrl),
        Future.delayed(const Duration(seconds: 5), () => null),
      ]);
    } catch (e) {
      print('Image download timeout or error: $e');
      return null;
    }
  }

  Future<File?> _downloadImage(final String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName =
            'job_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        return file;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  Widget _buildActionButtons(final BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: OutlinedButton(
              onPressed: _shareJob,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                side: BorderSide.none,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share_outlined,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Share',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF37B307),
                  Color.fromARGB(255, 55, 179, 7),
                  Color.fromARGB(255, 4, 109, 18),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF37B307).withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _launchApplicationUrl,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.rocket_launch_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _scrapedContent != null
                        ? _getApplicationTypeDisplayText(
                            _scrapedContent!.applicationType)
                        : 'Apply Now',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(final BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // child: Padding(
      //   padding: const EdgeInsets.all(16),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Row(
      //         children: [
      //           Container(
      //             padding: const EdgeInsets.all(4),
      //             decoration: BoxDecoration(
      //               color: const Color(0xFFFFA726).withOpacity(0.1),
      //               borderRadius: BorderRadius.circular(5),
      //             ),
      //             child: const Icon(
      //               Icons.star,
      //               color: Color(0xFFFFA726),
      //               size: 20,
      //             ),
      //           ),
      //           const SizedBox(width: 12),
      //           Text(
      //             'Rate this Job',
      //             style: TextStyle(
      //               fontSize: 14,
      //               fontWeight: FontWeight.bold,
      //               color: Theme.of(context).textTheme.titleMedium?.color,
      //             ),
      //           ),
      //         ],
      //       ),
      //       const SizedBox(height: 16),

      //       // Rating input
      //       JobRatingWidget(
      //         jobComments: widget.job.comments,
      //         averageRating: widget.job.averageRating,
      //         totalRatings: widget.job.totalRatings,
      //         showRatingInput: true,
      //         onRatingChanged: () {
      //           // Refresh the job data when rating changes
      //           context
      //               .read<JobProvider>()
      //               .refreshJobRating(widget.job.comments);
      //         },
      //       ),

      //       const SizedBox(height: 16),

      //       // Rating stats
      //       if (widget.job.totalRatings > 0)
      //         JobRatingStatsWidget(
      //           jobComments: widget.job.comments,
      //           averageRating: widget.job.averageRating,
      //           totalRatings: widget.job.totalRatings,
      //         ),
      //     ],
      //   ),
      // ),
    );
  }

  String _formatDate(final DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays > 0) {
      // Past dates
      return '${difference.inDays} days ago';
    } else {
      // Future dates - use absolute value
      final daysUntil = difference.inDays.abs();
      if (daysUntil == 1) {
        return 'Tomorrow';
      } else {
        return 'In $daysUntil days';
      }
    }
  }
}
