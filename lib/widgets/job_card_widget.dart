// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/job_provider.dart';
import '../services/applied_jobs_service.dart';
import '../services/web_scraping_service.dart';
// COMMENTED OUT: No longer navigating to job detail screen
// import '../screens/job_detail_screen.dart';

class JobCardWidget extends StatefulWidget {
  final Job job;
  final bool isHot;
  final bool isFirstHotJob;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final String sourceContext;

  const JobCardWidget({
    super.key,
    required this.job,
    this.isHot = false,
    this.isFirstHotJob = false,
    this.isExpanded = false,
    required this.onToggleExpanded,
    this.sourceContext = 'home',
  });

  @override
  State<JobCardWidget> createState() => _JobCardWidgetState();
}

class _JobCardWidgetState extends State<JobCardWidget>
    with TickerProviderStateMixin {
  bool _isJobApplied = false;
  bool _isLoadingAppliedStatus = true;
  late AnimationController _drawerController;
  late AnimationController _wowEffectController;
  late Animation<double> _drawerAnimation;
  late Animation<double> _wowScaleAnimation;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _checkIfJobApplied();
    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _wowEffectController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _drawerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeInOut,
    ));
    _wowScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _wowEffectController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _wowEffectController.dispose();
    super.dispose();
  }

  Future<void> _checkIfJobApplied() async {
    try {
      final isApplied =
          await AppliedJobsService.isJobApplied(widget.job.comments);
      if (mounted) {
        setState(() {
          _isJobApplied = isApplied;
          _isLoadingAppliedStatus = false;
        });
      }
    } catch (e) {
      print('Error checking if job is applied: $e');
      if (mounted) {
        setState(() {
          _isLoadingAppliedStatus = false;
        });
      }
    }
  }

  Future<void> _launchJobInBrowser() async {
    try {
      // Generate the job URL
      final Uri jobUrl = Uri(
        scheme: 'https',
        host: 'www.topjobs.lk',
        path: 'employer/JobAdvertismentServlet',
        queryParameters: {
          'ac': widget.job.applicantCode,
          'jc': widget.job.comments,
          'ec': widget.job.guid,
          'pg': 'tjappave', // Default application type
        },
      );

      print('Attempting to launch URL: $jobUrl');
      print('Widget mounted status: $mounted');

      // Check if widget is still mounted before accessing context
      if (!mounted) {
        print('Widget is no longer mounted, skipping URL launch');
        return;
      }

      // Increment view count when job is opened (only if mounted)
      try {
        context.read<JobProvider>().incrementViewCount(widget.job.comments);
      } catch (e) {
        print('Error incrementing view count: $e');
        // Continue with URL launch even if view count fails
      }

      // Try multiple launch modes for better compatibility
      bool launched = false;
      final List<LaunchMode> launchModes = [
        LaunchMode.externalApplication,
        LaunchMode.externalNonBrowserApplication,
        LaunchMode.platformDefault,
      ];

      for (LaunchMode mode in launchModes) {
        try {
          if (await canLaunchUrl(jobUrl)) {
            print(
                'URL can be launched with mode: $mode, attempting to launch...');
            // Add timeout to prevent hanging
            launched = await Future.any([
              launchUrl(jobUrl, mode: mode),
              Future.delayed(const Duration(seconds: 10), () => false),
            ]);

            if (launched) {
              print('URL launched successfully with mode: $mode');
              break;
            } else {
              print('URL launch returned false with mode: $mode');
            }
          } else {
            print('Cannot launch URL with mode: $mode');
          }
        } catch (e) {
          print('Error launching URL with mode $mode: $e');
          continue;
        }
      }

      if (!launched) {
        throw Exception('Failed to launch URL with any mode: $jobUrl');
      }
    } catch (e) {
      print('Error launching job URL: $e');
      // Show error message to user only if widget is still mounted
      if (mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open job: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        } catch (contextError) {
          print('Error showing snackbar: $contextError');
        }
      }
    }
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      if (_isDrawerOpen) {
        _drawerController.forward();
      } else {
        _drawerController.reverse();
      }
    });
  }

  void _handleFavoriteAction() {
    final jobProvider = context.read<JobProvider>();
    final isFavorite = jobProvider.isJobFavorite(widget.job.comments);

    // Haptic feedback - heavy impact for all actions
    HapticFeedback.heavyImpact();

    // Trigger wow effect animation
    _wowEffectController.forward().then((final _) {
      _wowEffectController.reverse();
    });

    // Toggle favorite after a short delay for better UX
    Future.delayed(const Duration(milliseconds: 100), () {
      jobProvider.toggleFavorite(widget.job.comments);

      // Show enhanced snackbar with emoji
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(
                isFavorite
                    ? '💔 Removed from favorites'
                    : '❤️ Added to favorites',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: isFavorite
              ? const Color.fromARGB(255, 252, 144, 12)
              : const Color.fromARGB(255, 5, 177, 56),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        ),
      );

      // Close drawer after animation
      Future.delayed(const Duration(milliseconds: 500), () {
        _toggleDrawer();
      });
    });
  }

  Future<void> _handleShareJob() async {
    // Haptic feedback for share action
    HapticFeedback.heavyImpact();

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
      // Try to get job images/artwork for sharing
      final scrapedContent = await WebScrapingService.fetchJobDescription(
        'https://www.topjobs.lk/employer/JobAdvertismentServlet?ac=${widget.job.applicantCode}&jc=${widget.job.comments}&ec=${widget.job.guid}',
      );

      // Check if there are images available to share
      if (scrapedContent != null && scrapedContent.imageUrls.isNotEmpty) {
        try {
          final String imageUrl = scrapedContent.imageUrls.first;
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
      // Fallback to text-only sharing
      await Share.share(shareText);
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
            'job_artwork_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        return file;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  List<Widget> _buildStackChildren() {
    final children = <Widget>[
      Card(
        elevation: 2,
        color:
            widget.isFirstHotJob ? const Color.fromARGB(255, 138, 14, 5) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            // COMMENTED OUT: Navigation to job detail screen
            // // Increment view count when job is tapped
            // context.read<JobProvider>().incrementViewCount(widget.job.comments);

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (final context) => JobDetailScreen(
            //       job: widget.job,
            //       sourceContext: widget.sourceContext,
            //     ),
            //   ),
            // ).then((final _) {
            //   // Refresh applied status when returning from job detail
            //   _checkIfJobApplied();
            // });

            // NEW: Launch job directly in browser
            _launchJobInBrowser();
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
                                  borderRadius: BorderRadius.circular(8),
                                  color: widget.isFirstHotJob
                                      ? Colors.white
                                      : Theme.of(context).cardColor,
                                  border: Border.all(
                                    color: widget.isFirstHotJob
                                        ? Colors.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: widget.job.publisher.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          'https://www.topjobs.lk/logo/${widget.job.publisher}',
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
                                      widget.job.title
                                          .trim()
                                          .replaceAll(RegExp(r'\s+'), ' ')
                                          .replaceAll('?', '-'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: widget.isFirstHotJob
                                            ? Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.color,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      widget.job.company
                                          .trim()
                                          .replaceAll(RegExp(r'\s+'), ' '),
                                      style: TextStyle(
                                        color: widget.isFirstHotJob
                                            ? Colors.white.withOpacity(0.9)
                                            : Theme.of(context)
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
                          if (widget.isExpanded) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: widget.isFirstHotJob
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.job.location,
                                    style: TextStyle(
                                      color: widget.isFirstHotJob
                                          ? Colors.white
                                          : Theme.of(context)
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
                                  color: widget.isFirstHotJob
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.job.description,
                                    style: TextStyle(
                                      color: widget.isFirstHotJob
                                          ? Colors.white
                                          : Theme.of(context)
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
                                    color: widget.isFirstHotJob
                                        ? Colors.white.withOpacity(0.2)
                                        : const Color(0xFFF0BE28)
                                            .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.job.type,
                                    style: TextStyle(
                                      color: widget.isFirstHotJob
                                          ? Colors.white
                                          : const Color(0xFFF0BE28),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Remote indicator
                                if (widget.job.isRemote) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.isFirstHotJob
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Remote',
                                      style: TextStyle(
                                        color: widget.isFirstHotJob
                                            ? Colors.white
                                            : Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                // Closing Date
                                if (widget.job.closingDate != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: widget.isFirstHotJob
                                        ? Colors.white
                                        : _getClosingDateColor(
                                            widget.job.closingDate!),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatClosingDate(widget.job.closingDate!),
                                    style: TextStyle(
                                      color: widget.isFirstHotJob
                                          ? Colors.white
                                          : _getClosingDateColor(
                                              widget.job.closingDate!),
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
                          onTap: widget.onToggleExpanded,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: widget.isFirstHotJob
                                  ? Colors.white
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
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
                                jobProvider.isJobFavorite(widget.job.comments);
                            return GestureDetector(
                              onTap: () {
                                jobProvider.toggleFavorite(widget.job.comments);
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
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? Colors.green
                                      : widget.isFirstHotJob
                                          ? Colors.white
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
    ];

    // Add applied indicator if needed
    if (_isLoadingAppliedStatus) {
      children.add(
        const Positioned(
          top: 0,
          right: 0,
          child: SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    } else if (_isJobApplied) {
      children.add(
        const Positioned(
          top: 0,
          right: 0,
          child: Icon(
            Icons.check_circle_sharp,
            size: 16,
            color: Color.fromARGB(255, 38, 206, 47),
          ),
        ),
      );
    }

    return children;
  }

  @override
  Widget build(final BuildContext context) {
    return Container(
      width: widget.isHot ? 320 : double.infinity,
      margin: EdgeInsets.only(
        right: widget.isHot ? 5 : 0,
        bottom: 5,
      ),
      child: GestureDetector(
        onPanUpdate: (final details) {
          // Handle right-to-left swipe to open drawer
          if (details.delta.dx < -5 && !_isDrawerOpen) {
            _toggleDrawer();
          }
        },
        onPanEnd: (final details) {
          // Handle left-to-right swipe to close drawer
          if (details.velocity.pixelsPerSecond.dx > 100 && _isDrawerOpen) {
            _toggleDrawer();
          }
        },
        child: Stack(
          children: [
            // Right drawer background (both buttons)
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (final context, final child) {
                return Positioned(
                  right: 3,
                  top: 3,
                  bottom: 3,
                  child: Transform.translate(
                    offset: Offset(150 * (1 - _drawerAnimation.value), 0),
                    child: Opacity(
                      opacity: _drawerAnimation.value,
                      child: Consumer<JobProvider>(
                        builder:
                            (final context, final jobProvider, final child) {
                          final isFavorite =
                              jobProvider.isJobFavorite(widget.job.comments);
                          return Container(
                            width: 150,
                            decoration: BoxDecoration(
                              color: isFavorite ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isFavorite ? Colors.red : Colors.green)
                                          .withOpacity(0.7),
                                  blurRadius: 4,
                                  offset: const Offset(-2, 0),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Share Action
                                GestureDetector(
                                  onTap: () {
                                    _handleShareJob();
                                    _toggleDrawer();
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.share,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                // Favorite Action with Smooth Effect
                                AnimatedBuilder(
                                  animation: _wowEffectController,
                                  builder: (final context, final child) {
                                    return Transform.scale(
                                      scale: _wowScaleAnimation.value,
                                      child: GestureDetector(
                                        onTap: _handleFavoriteAction,
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                            boxShadow:
                                                _wowEffectController.isAnimating
                                                    ? [
                                                        BoxShadow(
                                                          color: Colors.white
                                                              .withOpacity(0.4),
                                                          blurRadius: 8,
                                                          spreadRadius: 1,
                                                        ),
                                                      ]
                                                    : [],
                                          ),
                                          child: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                _wowEffectController.isAnimating
                                                    ? Colors.red
                                                    : Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            // Main card content (on top of drawer)
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (final context, final child) {
                return Transform.translate(
                  offset: Offset(-160 * _drawerAnimation.value, 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                    ),
                    child: child!,
                  ),
                );
              },
              child: Stack(
                children: _buildStackChildren(),
              ),
            ),
          ],
        ),
      ),
    );
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
}
