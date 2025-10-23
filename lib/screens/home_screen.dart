// ignore_for_file: deprecated_member_use, duplicate_ignore, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/banner_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/language_selector_widget.dart';
// import '../providers/notification_provider.dart';
import '../widgets/category_selector.dart';
import '../widgets/banner_slider.dart';
import '../widgets/theme_selection_dialog.dart';
// import '../widgets/job_card_widget.dart';
// import '../widgets/job_rating_widget.dart';
// import 'job_list_screen.dart';
// import 'notification_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  //final Set<String> _expandedCards = <String>{};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (mounted) {
        // _loadJobsAndRefreshCount(); // RSS call commented out
        context.read<BannerProvider>().loadBanners();
        _checkAndShowThemeDialog();
        _startRefreshTimer();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _startRefreshTimer();
    } else if (state == AppLifecycleState.paused) {
      // Stop timer when app goes to background to save battery
      _refreshTimer?.cancel();
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (final timer) {
      if (mounted) {
        // Timer kept for potential future use
      } else {
        timer.cancel();
      }
    });
  }

  // Future<void> _loadJobsAndRefreshCount() async {
  //   // Load jobs
  //   await context.read<JobProvider>().loadJobs();
  // }

  void _checkAndShowThemeDialog() {
    final themeProvider = context.read<ThemeProvider>();
    if (themeProvider.isFirstVisit) {
      // Add a small delay to ensure the UI is fully loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showThemeSelectionDialog();
        }
      });
    }
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (final context) => const ThemeSelectionDialog(),
    ).then((final _) {
      // Mark first visit as completed when dialog is closed
      context.read<ThemeProvider>().markFirstVisitCompleted();
    });
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'topjobs.lk',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          // Consumer<NotificationProvider>(
          //   builder: (final context, final notificationProvider, final child) {
          //     return Stack(
          //       children: [
          //         IconButton(
          //           icon: Icon(
          //             notificationProvider.notificationsEnabled
          //                 ? Icons.notifications_active
          //                 : Icons.notifications_off,
          //           ),
          //           tooltip: 'Notification Settings',
          //           onPressed: () async {
          //             await Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (final context) =>
          //                     const NotificationSettingsScreen(),
          //               ),
          //             );
          //           },
          //         ),
          //       ],
          //     );
          //   },
          // ),
          const LanguageSelectorWidget(),
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
      // Removed loading check to prevent showing loading when navigating from category screens
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 10),
            const CategorySelector(),
            const SizedBox(height: 24),
            // _buildSearchBarWithExpandButton(),
            // // const SizedBox(height: 24),
            // // _buildHotJobs(jobProvider),
            // const SizedBox(height: 0),
            // _buildRecentJobs(jobProvider),
          ],
        ),
      ),
      // OLD CODE - Commented out to prevent loading indicator on home screen
      // body: Consumer<JobProvider>(
      //   builder: (final context, final jobProvider, final child) {
      //     if (jobProvider.isLoading) {
      //       return Center(
      //         child: JobLoadingModal(
      //           color: Theme.of(context).brightness == Brightness.dark
      //               ? Colors.white
      //               : Theme.of(context).primaryColor,
      //         ),
      //       );
      //     }
      //
      //     return SingleChildScrollView(
      //       padding: const EdgeInsets.all(16),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           _buildWelcomeSection(),
      //           const SizedBox(height: 10),
      //           const CategorySelector(),
      //           const SizedBox(height: 24),
      //           // _buildSearchBarWithExpandButton(),
      //           // // const SizedBox(height: 24),
      //           // // _buildHotJobs(jobProvider),
      //           // const SizedBox(height: 0),
      //           // _buildRecentJobs(jobProvider),
      //         ],
      //       ),
      //     );
      //   },
      // ),
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
          //jobCount: jobProvider.jobs.length,
        );
      },
    );
  }

  // Widget _buildSearchBarWithExpandButton() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Search Recent Jobs',
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.bold,
  //           color: Theme.of(context).textTheme.titleMedium?.color,
  //         ),
  //       ),
  //       const SizedBox(height: 5),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: SizedBox(
  //               height: 48,
  //               child: TextField(
  //                 decoration: InputDecoration(
  //                   hintText: 'Job title, company, or skills...',
  //                   hintStyle: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w500,
  //                     color: Theme.of(context).hintColor,
  //                   ),
  //                   prefixIcon: const Icon(Icons.search),
  //                   prefixStyle: const TextStyle(
  //                     fontSize: 10,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                   enabledBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(5),
  //                     borderSide: BorderSide(
  //                         color: Theme.of(context).colorScheme.outline),
  //                   ),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(5),
  //                     borderSide: BorderSide(
  //                         color: Theme.of(context).colorScheme.outline),
  //                   ),
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(5),
  //                     borderSide: BorderSide(
  //                         color: Theme.of(context).colorScheme.outline),
  //                   ),
  //                   filled: true,
  //                   fillColor: Theme.of(context).colorScheme.onBackground,
  //                   contentPadding: const EdgeInsets.symmetric(
  //                     horizontal: 16,
  //                     vertical: 12,
  //                   ),
  //                 ),
  //                 onChanged: (final value) {
  //                   if (mounted) {
  //                     context.read<JobProvider>().searchJobs(value);
  //                   }
  //                 },
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           Container(
  //             height: 48,
  //             width: 48,
  //             decoration: BoxDecoration(
  //               color: const Color.fromARGB(255, 255, 192, 20),
  //               borderRadius: BorderRadius.circular(5),
  //             ),
  //             child: IconButton(
  //               icon: const Icon(Icons.expand_rounded,
  //                   size: 20, color: Colors.black),
  //               onPressed: () {
  //                 // Toggle all cards expansion
  //                 if (mounted) {
  //                   setState(() {
  //                     if (_expandedCards.length ==
  //                         context
  //                             .read<JobProvider>()
  //                             .jobsWithViewCounts
  //                             .length) {
  //                       _expandedCards.clear();
  //                     } else {
  //                       _expandedCards.addAll(
  //                         context
  //                             .read<JobProvider>()
  //                             .jobsWithViewCounts
  //                             .map((final job) => job.comments),
  //                       );
  //                     }
  //                   });
  //                 }
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildHotJobs(final JobProvider jobProvider) {
  //   // Filter jobs with DEFZZZ guid only
  //   final hotJobs = jobProvider.jobsWithViewCounts
  //       .where((final job) => job.guid.contains('DEFZZZ'))
  //       .take(100)
  //       .toList();

  //   if (hotJobs.isEmpty) return const SizedBox.shrink();

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Text(
  //             'Hot Jobs',
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.bold,
  //               color: Theme.of(context).textTheme.titleMedium?.color,
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFF892621),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Text(
  //               'Top ${hotJobs.length}',
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 10,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 12),
  //       SizedBox(
  //         height: _expandedCards.isNotEmpty
  //             ? (hotJobs.any((final job) => job.totalRatings > 0) ? 140 : 140)
  //             : 95, // Dynamic height based on expansion state and rating availability
  //         child: ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           itemCount: hotJobs.length,
  //           itemBuilder: (final context, final index) {
  //             final job = hotJobs[index];
  //             return _buildJobCard(job, isHot: true, isFirstHotJob: index == 0);
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildRecentJobs(final JobProvider jobProvider) {
  //   // Group jobs by their source feed and get top 10 from each category
  //   final Map<String, List<Job>> jobsByCategory = {};

  //   for (final job in jobProvider.jobsWithViewCounts) {
  //     // Extract category from feed URL
  //     final String category = _getCategoryFromFeedUrl(job.feedUrl);

  //     if (!jobsByCategory.containsKey(category)) {
  //       jobsByCategory[category] = [];
  //     }
  //     jobsByCategory[category]!.add(job);
  //   }

  //   // Get top 10 jobs from each category
  //   final List<Job> recentJobs = [];
  //   for (final category in jobsByCategory.keys) {
  //     final categoryJobs = jobsByCategory[category]!;
  //     categoryJobs.sort((final a, final b) =>
  //         b.postedDate.compareTo(a.postedDate)); // Sort by date descending
  //     recentJobs.addAll(categoryJobs.take(10)); // Take 10 from each category
  //   }

  //   // Sort all recent jobs by date
  //   recentJobs.sort((final a, final b) => b.postedDate.compareTo(a.postedDate));

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Row(
  //             children: [
  //               Text(
  //                 'Recent Jobs',
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.bold,
  //                   color: Theme.of(context).textTheme.titleMedium?.color,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (final context) => const JobListScreen(),
  //                 ),
  //               );
  //             },
  //             style: TextButton.styleFrom(
  //               foregroundColor: const Color(0xFFF0BE28),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //             ),
  //             child: Text('View All',
  //                 style: TextStyle(
  //                     fontSize: 12,
  //                     color: Theme.of(context).textTheme.labelLarge?.color,
  //                     fontWeight: FontWeight.w500)),
  //           ),
  //         ],
  //       ),
  //       ListView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         itemCount: recentJobs.length,
  //         itemBuilder: (final context, final index) {
  //           final job = recentJobs[index];
  //           return JobCardWidget(
  //             job: job,
  //             isExpanded: _expandedCards.contains(job.comments),
  //             onToggleExpanded: () {
  //               if (mounted) {
  //                 setState(() {
  //                   if (_expandedCards.contains(job.comments)) {
  //                     _expandedCards.remove(job.comments);
  //                   } else {
  //                     _expandedCards.add(job.comments);
  //                   }
  //                 });
  //               }
  //             },
  //             sourceContext: 'home',
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

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

  // String _getCategoryFromFeedUrl(final String feedUrl) {
  //   if (feedUrl.isEmpty) {
  //     return 'General';
  //   }

  //   if (feedUrl.contains('it_sware_db_qa_web_graphics_gis')) {
  //     return 'IT & Software';
  //   } else if (feedUrl.contains('it_hware_networks_systems')) {
  //     return 'IT Hardware & Networks';
  //   } else if (feedUrl.contains('accounting_auditing_finance')) {
  //     return 'Accounting & Finance';
  //   } else if (feedUrl.contains('banking_insurance')) {
  //     return 'Banking & Insurance';
  //   } else if (feedUrl.contains('sales_marketing_merchandising')) {
  //     return 'Sales & Marketing';
  //   } else if (feedUrl.contains('hr_training')) {
  //     return 'Human Resources';
  //   } else if (feedUrl.contains('corporate_management_analysts')) {
  //     return 'Corporate Management';
  //   } else if (feedUrl.contains('office_admin_secretary_receptionist')) {
  //     return 'Office Administration';
  //   } else if (feedUrl.contains('civil_eng_interior_design_architecture')) {
  //     return 'Civil Engineering & Architecture';
  //   } else if (feedUrl.contains('it_telecoms')) {
  //     return 'IT & Telecommunications';
  //   } else if (feedUrl.contains('customer_relations_public_relations')) {
  //     return 'Customer Relations';
  //   } else if (feedUrl.contains('logistics_warehouse_transport')) {
  //     return 'Logistics & Transport';
  //   } else if (feedUrl.contains('eng_mech_auto_elec')) {
  //     return 'Engineering';
  //   } else if (feedUrl.contains('manufacturing_operations')) {
  //     return 'Manufacturing';
  //   } else if (feedUrl.contains('media_advert_communication')) {
  //     return 'Media & Communication';
  //   } else if (feedUrl.contains('HOTELS_RESTAURANTS_HOSPITALITY')) {
  //     return 'Hospitality';
  //   } else if (feedUrl.contains('TRAVEL_TOURISM')) {
  //     return 'Travel & Tourism';
  //   } else if (feedUrl.contains('sports_fitness_recreation')) {
  //     return 'Sports & Fitness';
  //   } else if (feedUrl.contains('hospital_nursing_healthcare')) {
  //     return 'Healthcare';
  //   } else if (feedUrl.contains('legal_law')) {
  //     return 'Legal';
  //   } else if (feedUrl.contains('supervision_quality_control')) {
  //     return 'Quality Control';
  //   } else if (feedUrl.contains('apparel_clothing')) {
  //     return 'Apparel & Clothing';
  //   } else if (feedUrl.contains('ticketing_airline_marine')) {
  //     return 'Aviation & Marine';
  //   } else if (feedUrl.contains('EDUCATION')) {
  //     return 'Education';
  //   } else if (feedUrl.contains('rnd_science_research')) {
  //     return 'Research & Development';
  //   } else if (feedUrl.contains('agriculture_dairy_environment')) {
  //     return 'Agriculture & Environment';
  //   } else if (feedUrl.contains('security')) {
  //     return 'Security';
  //   } else if (feedUrl.contains('fashion_design_beauty')) {
  //     return 'Fashion & Beauty';
  //   } else if (feedUrl.contains('international_development')) {
  //     return 'International Development';
  //   } else if (feedUrl.contains('kpo_bpo')) {
  //     return 'KPO & BPO';
  //   } else if (feedUrl.contains('imports_exports')) {
  //     return 'Import & Export';
  //   } else {
  //     return 'General';
  //   }
  // }
}
