// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/job_card_widget.dart';
// import '../widgets/job_rating_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedCards = {};

  @override
  void initState() {
    super.initState();
    // Load jobs to ensure favorites are available
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (mounted) {
        context.read<JobProvider>().loadJobs();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
              final favoriteJobs = jobProvider.getFavoriteJobs();
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${favoriteJobs.length} favorites',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (final context, final jobProvider, final child) {
          final favoriteJobs = jobProvider.getFavoriteJobs().map((final job) {
            final viewCount = jobProvider.getViewCount(job.comments);
            final ratingStats = jobProvider.getJobRatingStats(job.comments);
            final averageRating = ratingStats['averageRating'] as double;
            final totalRatings = ratingStats['totalRatings'] as int;

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
              averageRating: averageRating,
              totalRatings: totalRatings,
            );
          }).toList();

          if (favoriteJobs.isEmpty) {
            return GestureDetector(
              onTap: () {
                // Prevent any tap gestures from interfering
              },
              onPanStart: (final details) {
                // Prevent swipe gestures from closing the app
              },
              onPanUpdate: (final details) {
                // Prevent swipe gestures from closing the app
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.heart_broken_sharp,
                      size: 80,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFF0BE28)
                          : Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Favorite Jobs Yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start building your dream career! 💼\nFind and save your favorite jobs',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // const SizedBox(height: 32),
                    // ElevatedButton.icon(
                    //   onPressed: () {
                    //     Navigator.pushNamedAndRemoveUntil(
                    //       context,
                    //       '/home',
                    //       (final route) => false,
                    //     );
                    //   },
                    //   icon: const Icon(Icons.home, size: 20),
                    //   label: const Text('Go to Home'),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Theme.of(context).primaryColor,
                    //     foregroundColor: Colors.white,
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 24,
                    //       vertical: 12,
                    //     ),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              _buildSearchBar(),
              // Favorite jobs list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: favoriteJobs.length,
                  itemBuilder: (final context, final index) {
                    final job = favoriteJobs[index];
                    return JobCardWidget(
                      job: job,
                      isExpanded: _expandedCards.contains(job.comments),
                      onToggleExpanded: () {
                        if (mounted) {
                          setState(() {
                            if (_expandedCards.contains(job.comments)) {
                              _expandedCards.remove(job.comments);
                            } else {
                              _expandedCards.add(job.comments);
                            }
                          });
                        }
                      },
                      sourceContext: 'favorites',
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Search favorite jobs...',
            hintStyle: const TextStyle(fontSize: 12),
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.onBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (final value) {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
