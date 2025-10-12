// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/rating_service.dart';
import '../providers/job_provider.dart';

class JobRatingWidget extends StatefulWidget {
  final String jobComments;
  final double? averageRating;
  final int? totalRatings;
  final bool showRatingInput;
  final VoidCallback? onRatingChanged;
  final bool isFirstHotJob;

  const JobRatingWidget({
    super.key,
    required this.jobComments,
    this.averageRating,
    this.totalRatings,
    this.showRatingInput = false,
    this.onRatingChanged,
    this.isFirstHotJob = false,
  });

  @override
  State<JobRatingWidget> createState() => _JobRatingWidgetState();
}

class _JobRatingWidgetState extends State<JobRatingWidget> {
  int? _userRating;
  bool _isLoading = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('user_id') ??
          'anonymous_${DateTime.now().millisecondsSinceEpoch}';

      // If no user ID exists, create one
      if (!prefs.containsKey('user_id')) {
        await prefs.setString('user_id', _userId!);
      }

      // Load user's existing rating
      if (widget.showRatingInput) {
        _loadUserRating();
      }
    } catch (e) {
      print('Error getting user ID: $e');
      _userId = 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _loadUserRating() async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final rating =
          await RatingService.getUserRating(widget.jobComments, _userId!);
      if (mounted) {
        setState(() {
          _userRating = rating;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitRating(final int rating) async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      if (_userRating == null) {
        // Submit new rating
        success = await RatingService.submitRating(
          jobComments: widget.jobComments,
          rating: rating,
          userId: _userId!,
        );
      } else {
        // Update existing rating
        success = await RatingService.updateRating(
          jobComments: widget.jobComments,
          rating: rating,
          userId: _userId!,
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (success) {
            _userRating = rating;
            widget.onRatingChanged?.call();
            // Force refresh all rating data to ensure consistency
            _refreshAllRatingData();
          }
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _userRating == null ? 'Rating submitted!' : 'Rating updated!',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit rating. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeRating() async {
    if (_userId == null || _userRating == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await RatingService.deleteRating(widget.jobComments, _userId!);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (success) {
            _userRating = null;
            widget.onRatingChanged?.call();
            // Force refresh all rating data to ensure consistency
            _refreshAllRatingData();
          }
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rating removed!'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Refresh all rating data to ensure consistency across devices
  Future<void> _refreshAllRatingData() async {
    try {
      // Get the provider to refresh all rating data
      final jobProvider = context.read<JobProvider>();

      // First refresh the specific job rating
      await jobProvider.refreshJobRating(widget.jobComments);

      // Then refresh all ratings to ensure consistency across all screens
      await jobProvider.refreshAllRatings();
    } catch (e) {
      print('Error refreshing all rating data: $e');
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (_isLoading && widget.showRatingInput) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Star rating display
        _buildStarRating(),

        // Rating count
        if (widget.totalRatings != null && widget.totalRatings! > 0) ...[
          const SizedBox(width: 4),
          Text(
            '(${widget.totalRatings})',
            style: TextStyle(
              fontSize: 12,
              color: widget.isFirstHotJob
                  ? Colors.white
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],

        // Rating input (if enabled)
        if (widget.showRatingInput) ...[
          const SizedBox(width: 8),
          _buildRatingInput(),
        ],
      ],
    );
  }

  Widget _buildStarRating() {
    final averageRating = widget.averageRating ?? 0.0;
    final totalRatings = widget.totalRatings ?? 0;

    if (totalRatings == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (final index) {
          return Icon(
            Icons.star_border,
            size: 16,
            color: Colors.grey[400],
          );
        }),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (final index) {
        final starRating = index + 1;
        if (starRating <= averageRating.floor()) {
          // Full star
          return const Icon(
            Icons.star,
            size: 16,
            color: Colors.amber,
          );
        } else if (starRating - 1 < averageRating &&
            averageRating < starRating) {
          // Half star
          return const Icon(
            Icons.star_half,
            size: 16,
            color: Colors.amber,
          );
        } else {
          // Empty star
          return Icon(
            Icons.star_border,
            size: 16,
            color: Colors.grey[400],
          );
        }
      }),
    );
  }

  Widget _buildRatingInput() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Star input buttons
        ...List.generate(5, (final index) {
          final starRating = index + 1;
          final isSelected = _userRating == starRating;
          final isFilled = _userRating != null && starRating <= _userRating!;

          return GestureDetector(
            onTap: () => _submitRating(starRating),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                isFilled ? Icons.star : Icons.star_border,
                size: 20,
                color: isSelected ? Colors.amber : Colors.grey[400],
              ),
            ),
          );
        }),

        // Remove rating button (if user has rated)
        if (_userRating != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _removeRating,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.clear,
                size: 16,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class JobRatingStatsWidget extends StatelessWidget {
  final String jobComments;
  final double? averageRating;
  final int? totalRatings;
  final Map<int, int>? ratingDistribution;

  const JobRatingStatsWidget({
    super.key,
    required this.jobComments,
    this.averageRating,
    this.totalRatings,
    this.ratingDistribution,
  });

  @override
  Widget build(final BuildContext context) {
    if (totalRatings == null || totalRatings == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromARGB(255, 209, 209, 209),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Job Rating',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Average rating
          Row(
            children: [
              Text(
                averageRating!.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
              ),
              const SizedBox(width: 8),
              JobRatingWidget(
                jobComments: jobComments,
                averageRating: averageRating,
                totalRatings: totalRatings,
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'Based on $totalRatings rating${totalRatings == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),

          // Rating distribution (if available)
          if (ratingDistribution != null) ...[
            const SizedBox(height: 16),
            ...ratingDistribution!.entries.map((final entry) {
              final rating = entry.key;
              final count = entry.value;
              final percentage =
                  totalRatings! > 0 ? (count / totalRatings!) * 100 : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      '$rating',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber.withOpacity(0.7)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$count',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
