// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/rss_categories.dart';
import '../screens/category_job_screen.dart';
import '../providers/job_provider.dart';
import '../services/color_service.dart';

// Sort options
enum CategorySortOption {
  alphabetical,
  jobCount,
  mostVisited,
  flagged,
}

class CategorySelector extends StatefulWidget {
  const CategorySelector({
    super.key,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  // Use the centralized color service
  final ColorService _colorService = ColorService();

  // State to track whether to show all categories or just 6
  bool _showAllCategories = false;

  CategorySortOption _currentSortOption = CategorySortOption.alphabetical;

  // SharedPreferences key for storing most visited categories
  static const String _mostVisitedKey = 'most_visited_categories';

  // Store most visited categories data
  List<String> _mostVisitedCategories = [];

  // Store flagged/favorite categories
  List<String> _flaggedCategories = [];

  // SharedPreferences key for storing flagged categories
  static const String _flaggedKey = 'flagged_categories';

  @override
  void initState() {
    super.initState();
    _loadMostVisitedCategories();
    _loadFlaggedCategories();
  }

  /// Load most visited categories from SharedPreferences
  Future<void> _loadMostVisitedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? mostVisited = prefs.getStringList(_mostVisitedKey);
      if (mostVisited != null) {
        setState(() {
          _mostVisitedCategories = mostVisited;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Load flagged categories from SharedPreferences
  Future<void> _loadFlaggedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? flagged = prefs.getStringList(_flaggedKey);
      if (flagged != null) {
        setState(() {
          _flaggedCategories = flagged;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Job Categories',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            _buildSortButton(context),
          ],
        ),
        const SizedBox(height: 15),
        Consumer<JobProvider>(
          builder: (final context, final jobProvider, final child) {
            // Create a list of categories with their job counts
            final categoriesWithJobCounts =
                RssCategories.categories.map((final category) {
              final jobCount =
                  jobProvider.getJobCountByCategory(category.feedUrl);
              return MapEntry(category, jobCount);
            }).toList();

            // Sort based on current sort option
            _sortCategories(categoriesWithJobCounts);

            // Limit to 6 categories initially, or show all if _showAllCategories is true
            final categoriesToShow = _showAllCategories
                ? categoriesWithJobCounts
                : categoriesWithJobCounts.take(6).toList();

            return Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: categoriesToShow.length,
                  itemBuilder: (final context, final index) {
                    final categoryEntry = categoriesToShow[index];
                    final category = categoryEntry.key;
                    final jobCount = categoryEntry.value;

                    // Get the color for this category (cached and consistent)
                    final categoryColor = _colorService
                        .getCategoryColor(category.icon, index: index);

                    return GestureDetector(
                      onTap: () {
                        // Track category visit
                        _trackCategoryVisit(category.feedUrl);

                        // Navigate to category job screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (final context) => CategoryJobScreen(
                              category: category,
                              categoryColor: categoryColor,
                            ),
                          ),
                        );
                      },
                      onLongPress: () {
                        _toggleCategoryFlag(category.feedUrl);
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(2), // Border width
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                categoryColor,
                                categoryColor.withOpacity(0.6),
                                categoryColor.withOpacity(0.3),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(
                                7), // Slightly smaller radius
                          ),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Icon(
                                        _getIconData(category.icon),
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        height: 40, // Fixed height for 2 lines
                                        child: Center(
                                          child: Text(
                                            category.minititle,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              height: 1.1, // Line height
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          category.englisht,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black54,
                                                offset: Offset(0, 1),
                                                blurRadius: 1,
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black.withOpacity(0.8)
                                          : categoryColor.withOpacity(1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '$jobCount jobs',
                                      style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? categoryColor
                                            : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                              // Star indicator positioned at top-right of tile
                              if (_flaggedCategories.contains(category.feedUrl))
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    padding: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 41, 212, 6),
                                      borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(7),
                                          bottomRight: Radius.zero,
                                          topLeft: Radius.zero,
                                          bottomLeft: Radius.circular(7)),
                                      border: Border.all(
                                        color: Colors.white70,
                                        width: 2,
                                      ),
                                      // boxShadow: [
                                      //   BoxShadow(
                                      //     color: Colors.black.withOpacity(0.3),
                                      //     blurRadius: 4,
                                      //     offset: const Offset(0, 2),
                                      //   ),
                                      // ],
                                    ),
                                    child: const Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 14,
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
                // Show "More Categories" button only if there are more than 6 categories
                if (categoriesWithJobCounts.length > 6) ...[
                  const SizedBox(height: 20),
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              Theme.of(context).brightness == Brightness.dark
                                  ? [
                                      Colors.grey[600]!,
                                      Colors.grey[500]!,
                                    ]
                                  : [
                                      Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.8),
                                      Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.6),
                                    ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.withOpacity(0.3)
                                    : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _showAllCategories = !_showAllCategories;
                            });
                            // Auto scroll to top when "Show Less" is clicked
                            if (!_showAllCategories) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((final _) {
                                Scrollable.ensureVisible(
                                  context,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(
                              8,
                              8,
                              10,
                              8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showAllCategories
                                      ? Icons.arrow_circle_up_sharp
                                      : Icons.arrow_circle_down_sharp,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _showAllCategories
                                      ? 'Show Less'
                                      : 'More Categories',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  IconData _getIconData(final String iconName) {
    switch (iconName) {
      case 'design-services':
        return Icons.design_services;
      case 'lan':
        return Icons.lan;
      case 'attach-money':
        return Icons.attach_money;
      case 'home-work':
        return Icons.home_work;
      case 'people-alt':
        return Icons.people_alt;
      case 'diversity-3':
        return Icons.diversity_3;
      case 'settings-accessibility':
        return Icons.settings_accessibility;
      case 'shield':
        return Icons.shield;
      case 'roofing':
        return Icons.roofing;
      case 'router':
        return Icons.router;
      case 'connect-without-contact':
        return Icons.connect_without_contact;
      case 'directions-bus':
        return Icons.directions_bus;
      case 'car-repair':
        return Icons.car_repair;
      case 'handyman':
        return Icons.handyman;
      case 'linked-camera':
        return Icons.linked_camera;
      case 'liquor':
        return Icons.liquor;
      case 'luggage':
        return Icons.luggage;
      case 'directions-bike':
        return Icons.directions_bike;
      case 'local-hospital':
        return Icons.local_hospital;
      case 'local-police':
        return Icons.local_police;
      case 'checklist':
        return Icons.checklist;
      case 'dry-cleaning':
        return Icons.dry_cleaning;
      case 'airplanemode-active':
        return Icons.airplanemode_active;
      case 'menu-book':
        return Icons.menu_book;
      case 'science':
        return Icons.science;
      case 'forest':
        return Icons.forest;
      case 'palette':
        return Icons.palette;
      case 'supervised-user-circle':
        return Icons.supervised_user_circle;
      case 'import-export':
        return Icons.import_export;
      default:
        return Icons.work;
    }
  }

  /// Sort categories based on current sort option
  void _sortCategories(
      final List<MapEntry<RssCategory, int>> categoriesWithJobCounts) {
    switch (_currentSortOption) {
      case CategorySortOption.alphabetical:
        categoriesWithJobCounts.sort((final a, final b) => a.key.minititle
            .toLowerCase()
            .compareTo(b.key.minititle.toLowerCase()));
        break;
      case CategorySortOption.jobCount:
        categoriesWithJobCounts
            .sort((final a, final b) => b.value.compareTo(a.value));
        break;
      case CategorySortOption.mostVisited:
        _sortByMostVisited(categoriesWithJobCounts);
        break;
      case CategorySortOption.flagged:
        _sortByFlagged(categoriesWithJobCounts);
        break;
    }
  }

  /// Sort categories by most visited (stored in SharedPreferences)
  void _sortByMostVisited(
      final List<MapEntry<RssCategory, int>> categoriesWithJobCounts) {
    if (_mostVisitedCategories.isNotEmpty) {
      // Create a map for quick lookup
      final Map<String, int> visitOrder = {};
      for (int i = 0; i < _mostVisitedCategories.length; i++) {
        visitOrder[_mostVisitedCategories[i]] = i;
      }

      // Sort by visit order (lower index = more visited)
      categoriesWithJobCounts.sort((final a, final b) {
        final aOrder = visitOrder[a.key.feedUrl] ?? 999999;
        final bOrder = visitOrder[b.key.feedUrl] ?? 999999;
        return aOrder.compareTo(bOrder);
      });
    } else {
      // If no visit history, fall back to job count sorting
      categoriesWithJobCounts
          .sort((final a, final b) => b.value.compareTo(a.value));
    }
  }

  /// Sort categories by flagged status (flagged categories first)
  void _sortByFlagged(
      final List<MapEntry<RssCategory, int>> categoriesWithJobCounts) {
    categoriesWithJobCounts.sort((final a, final b) {
      final aIsFlagged = _flaggedCategories.contains(a.key.feedUrl);
      final bIsFlagged = _flaggedCategories.contains(b.key.feedUrl);

      // Flagged categories come first
      if (aIsFlagged && !bIsFlagged) return -1;
      if (!aIsFlagged && bIsFlagged) return 1;

      // If both are flagged or both are not flagged, sort by job count
      return b.value.compareTo(a.value);
    });
  }

  /// Build the sort button widget
  Widget _buildSortButton(final BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Get the current sort option text
    String getSortOptionText() {
      switch (_currentSortOption) {
        case CategorySortOption.alphabetical:
          return 'Sorted By: Alphabetical';
        case CategorySortOption.jobCount:
          return 'Sorted By: Most Jobs';
        case CategorySortOption.mostVisited:
          return 'Sorted By: Most Visited';
        case CategorySortOption.flagged:
          return 'Sorted By: Flagged';
      }
    }

    return PopupMenuButton<CategorySortOption>(
      tooltip: 'Sort Categories',
      onSelected: (final CategorySortOption option) {
        setState(() {
          _currentSortOption = option;
        });
      },
      itemBuilder: (final BuildContext context) => [
        PopupMenuItem<CategorySortOption>(
          value: CategorySortOption.alphabetical,
          child: Row(
            children: [
              Icon(
                Icons.sort_by_alpha,
                size: 16,
                color: _currentSortOption == CategorySortOption.alphabetical
                    ? (isDarkMode
                        ? Colors.white
                        : Theme.of(context).primaryColor)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Alphabetical',
                style: TextStyle(
                  color: _currentSortOption == CategorySortOption.alphabetical
                      ? (isDarkMode
                          ? Colors.white
                          : Theme.of(context).primaryColor)
                      : null,
                  fontWeight:
                      _currentSortOption == CategorySortOption.alphabetical
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<CategorySortOption>(
          value: CategorySortOption.jobCount,
          child: Row(
            children: [
              Icon(
                Icons.work,
                size: 16,
                color: _currentSortOption == CategorySortOption.jobCount
                    ? (isDarkMode
                        ? Colors.white
                        : Theme.of(context).primaryColor)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Most Jobs',
                style: TextStyle(
                  color: _currentSortOption == CategorySortOption.jobCount
                      ? (isDarkMode
                          ? Colors.white
                          : Theme.of(context).primaryColor)
                      : null,
                  fontWeight: _currentSortOption == CategorySortOption.jobCount
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<CategorySortOption>(
          value: CategorySortOption.mostVisited,
          child: Row(
            children: [
              Icon(
                Icons.visibility,
                size: 16,
                color: _currentSortOption == CategorySortOption.mostVisited
                    ? (isDarkMode
                        ? Colors.white
                        : Theme.of(context).primaryColor)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Most Visited',
                style: TextStyle(
                  color: _currentSortOption == CategorySortOption.mostVisited
                      ? (isDarkMode
                          ? Colors.white
                          : Theme.of(context).primaryColor)
                      : null,
                  fontWeight:
                      _currentSortOption == CategorySortOption.mostVisited
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<CategorySortOption>(
          value: CategorySortOption.flagged,
          child: Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: _currentSortOption == CategorySortOption.flagged
                    ? (isDarkMode
                        ? Colors.white
                        : Theme.of(context).primaryColor)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Flagged',
                style: TextStyle(
                  color: _currentSortOption == CategorySortOption.flagged
                      ? (isDarkMode
                          ? Colors.white
                          : Theme.of(context).primaryColor)
                      : null,
                  fontWeight: _currentSortOption == CategorySortOption.flagged
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getSortOptionText(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? Colors.white
                  : Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.sort,
            size: 20,
            color: isDarkMode
                ? Colors.white
                : Theme.of(context).textTheme.titleMedium?.color,
          ),
        ],
      ),
    );
  }

  /// Track category visit (call this when a category is tapped)
  void _trackCategoryVisit(final String feedUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> mostVisited = prefs.getStringList(_mostVisitedKey) ?? [];

      // Remove if already exists to avoid duplicates
      mostVisited.remove(feedUrl);

      // Add to beginning of list
      mostVisited.insert(0, feedUrl);

      // Keep only last 20 visits
      if (mostVisited.length > 20) {
        mostVisited = mostVisited.take(20).toList();
      }

      await prefs.setStringList(_mostVisitedKey, mostVisited);

      // Update local state
      setState(() {
        _mostVisitedCategories = mostVisited;
      });
    } catch (e) {
      // Silently fail
    }
  }

  /// Toggle category flag (call this when a category is long pressed)
  void _toggleCategoryFlag(final String feedUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> flagged = prefs.getStringList(_flaggedKey) ?? [];

      if (flagged.contains(feedUrl)) {
        // Remove flag
        flagged.remove(feedUrl);
      } else {
        // Add flag
        flagged.add(feedUrl);
      }

      await prefs.setStringList(_flaggedKey, flagged);

      // Update local state
      setState(() {
        _flaggedCategories = flagged;
      });

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            flagged.contains(feedUrl)
                ? 'Category flagged'
                : 'Category unflagged',
          ),
          backgroundColor:
              flagged.contains(feedUrl) ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }
}
