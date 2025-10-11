// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import 'job_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();

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
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pushNamedAndRemoveUntil(
        //     context,
        //     '/home',
        //     (final route) => false,
        //   ),
        // ),
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
          final favoriteJobs = jobProvider.getFavoriteJobs();

          if (favoriteJobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Theme.of(context).textTheme.bodySmall?.color,
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
                    'Swipe right on any job to add it to your favorites',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: favoriteJobs.length,
                  itemBuilder: (final context, final index) {
                    final job = favoriteJobs[index];
                    return _buildJobCard(job);
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

  Widget _buildJobCard(final Job job) {
    // Filter jobs based on search query
    final searchQuery = _searchController.text.toLowerCase();
    final matchesSearch = searchQuery.isEmpty ||
        job.title.toLowerCase().contains(searchQuery) ||
        job.company.toLowerCase().contains(searchQuery) ||
        job.location.toLowerCase().contains(searchQuery);

    if (!matchesSearch) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(job.comments),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (final context) {
                context.read<JobProvider>().removeFromFavorites(job.comments);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Removed from favorites'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.favorite,
              label: 'Remove Favorite',
              borderRadius: BorderRadius.circular(8),
            ),
          ],
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
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
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.fitWidth,
                                  errorBuilder: (final context, final error,
                                      final stackTrace) {
                                    return Icon(
                                      Icons.work,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.work,
                                color: Theme.of(context).primaryColor,
                                size: 24,
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              job.company,
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
                      const SizedBox(width: 15),
                      // Favorite indicator (always red since these are favorites)
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
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Location and description in the same row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          job.location,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (job.description.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Transform.translate(
                          offset: const Offset(0, 2),
                          child: Icon(
                            Icons.arrow_circle_right,
                            size: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.description,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Closes and Full time in the same row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0BE28).withOpacity(0.2),
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
                      if (job.isRemote) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
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
                      const SizedBox(width: 16),
                      if (job.closingDate != null) ...[
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: _getClosingDateColor(job.closingDate!),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatClosingDate(job.closingDate!),
                          style: TextStyle(
                            color: _getClosingDateColor(job.closingDate!),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
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
      return 'Closes in ${difference.inDays} days';
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
