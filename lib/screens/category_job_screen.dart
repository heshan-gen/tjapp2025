// ignore_for_file: deprecated_member_use, use_is_even_rather_than_modulo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/modern_loading_modal.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../data/rss_categories.dart';
import '../services/color_service.dart';
import '../widgets/job_card_widget.dart';
import '../widgets/language_selector_widget.dart';
// import '../widgets/job_rating_widget.dart';

class CategoryJobScreen extends StatefulWidget {
  final RssCategory category;
  final Color categoryColor;

  const CategoryJobScreen({
    super.key,
    required this.category,
    required this.categoryColor,
  });

  @override
  State<CategoryJobScreen> createState() => _CategoryJobScreenState();
}

class _CategoryJobScreenState extends State<CategoryJobScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedCards = <String>{};
  final ColorService _colorService = ColorService();
  bool _allCardsExpanded = true; // Default to expanded mode

  @override
  void initState() {
    super.initState();
    // Load jobs from the specific category feed
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (mounted) {
        context
            .read<JobProvider>()
            .loadJobsFromCategory(widget.category.feedUrl);
      }
    });

    // Listen to JobProvider changes to expand cards when jobs are loaded
    context.read<JobProvider>().addListener(_onJobProviderChanged);
  }

  void _onJobProviderChanged() {
    if (!mounted) return;

    final jobProvider = context.read<JobProvider>();
    // Expand all cards when jobs are loaded and not loading
    if (!jobProvider.isLoading && jobProvider.categoryJobs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        if (mounted && _expandedCards.isEmpty) {
          _expandAllCards();
        }
      });
    }
  }

  void _expandAllCards() {
    if (mounted) {
      final jobProvider = context.read<JobProvider>();
      setState(() {
        _expandedCards.clear();
        _expandedCards.addAll(
          jobProvider.categoryJobs.map((final job) => job.comments),
        );
        _allCardsExpanded = true;
      });
    }
  }

  void _collapseAllCards() {
    if (mounted) {
      setState(() {
        _expandedCards.clear();
        _allCardsExpanded = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    context.read<JobProvider>().removeListener(_onJobProviderChanged);
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Consumer<JobProvider>(
          builder: (final context, final jobProvider, final child) {
            return Row(
              children: [
                Text(
                  widget.category.minititle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${jobProvider.categoryJobsWithViewCounts.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          const LanguageSelectorWidget(iconColor: Colors.white),
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
          if (jobProvider.isLoading) {
            return Center(
              child: JobLoadingModal(
                category: widget.category.englisht,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).primaryColor,
              ),
            );
          }

          final categoryJobs = jobProvider.categoryJobsWithViewCounts;

          if (categoryJobs.isEmpty) {
            // Check if there are any active filters
            final hasActiveFilters = jobProvider.searchQuery.isNotEmpty ||
                jobProvider.selectedLocation.isNotEmpty ||
                jobProvider.selectedExperience.isNotEmpty ||
                jobProvider.selectedType.isNotEmpty;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconData(widget.category.icon),
                    size: 64,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      hasActiveFilters
                          ? 'No jobs found with current filters'
                          : 'No jobs found in ${widget.category.englisht}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasActiveFilters
                        ? 'Try adjusting your filters to see more results'
                        : 'Jobs from this category will appear here when available',
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
              // Category header
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       colors: [
              //         widget.categoryColor,
              //         widget.categoryColor.withOpacity(0.8),
              //       ],
              //       begin: Alignment.topCenter,
              //       end: Alignment.bottomCenter,
              //     ),
              //   ),
              //   child: Row(
              //     children: [
              //       // Icon on the left
              //       Icon(
              //         _getIconData(widget.category.icon),
              //         size: 48,
              //         color: Colors.white,
              //       ),
              //       const SizedBox(width: 16),
              //       // Title and job count on the right
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               widget.category.englisht,
              //               style: const TextStyle(
              //                 color: Colors.white,
              //                 fontSize: 14,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //             const SizedBox(height: 4),
              //             Container(
              //               padding: const EdgeInsets.symmetric(
              //                 horizontal: 12,
              //                 vertical: 6,
              //               ),
              //               decoration: BoxDecoration(
              //                 color: Colors.white.withOpacity(0.2),
              //                 borderRadius: BorderRadius.circular(16),
              //               ),
              //               child: Text(
              //                 '${categoryJobs.length} jobs available',
              //                 style: const TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 10,
              //                   fontWeight: FontWeight.bold,
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 16),
              // Category selection button
              _buildCategorySelectionButton(),
              // Search bar with expand button
              _buildSearchBarWithExpandButton(),

              // Job list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: categoryJobs.length,
                  itemBuilder: (final context, final index) {
                    final job = categoryJobs[index];
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
                            // Update the global expansion state
                            _allCardsExpanded = _expandedCards.length ==
                                context.read<JobProvider>().categoryJobs.length;
                          });
                        }
                      },
                      sourceContext: 'category',
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<JobProvider>(
        builder: (final context, final jobProvider, final child) {
          // Check if there are any active filters
          final hasActiveFilters = jobProvider.searchQuery.isNotEmpty ||
              jobProvider.selectedLocation.isNotEmpty ||
              jobProvider.selectedExperience.isNotEmpty ||
              jobProvider.selectedType.isNotEmpty;

          if (!hasActiveFilters) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: () {
              jobProvider.clearFilters();
            },
            backgroundColor: widget.categoryColor,
            foregroundColor: Colors.white,
            tooltip: 'Clear Filters',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.clear_all),
          );
        },
      ),
    );
  }

  Widget _buildSearchBarWithExpandButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText:
                      'Search jobs in ${widget.category.englisht} by title, company, location, or skills...',
                  hintStyle: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  prefixIcon: Icon(Icons.search,
                      size: 20,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            if (mounted) {
                              context.read<JobProvider>().searchJobs('');
                            }
                          },
                        )
                      : null,
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFC22820),
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.filter_list, size: 20, color: Colors.white),
              onPressed: _showFilterBottomSheet,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: widget.categoryColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon: Icon(
                  _allCardsExpanded ? Icons.unfold_less : Icons.unfold_more,
                  size: 20,
                  color: Colors.white),
              onPressed: () {
                // Toggle all cards expansion
                if (_allCardsExpanded) {
                  _collapseAllCards();
                } else {
                  _expandAllCards();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (final context) => const FilterBottomSheet(),
    );
  }

  Widget _buildCategorySelectionButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: _showCategoryBottomSheet,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.categoryColor,
                widget.categoryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.categoryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  _getIconData(widget.category.icon),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : widget.categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Switch Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.white,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    // RichText(
                    //   text: TextSpan(
                    //     text: 'Currently viewing: ',
                    //     style: TextStyle(
                    //       fontSize: 12,
                    //       color: Theme.of(context).brightness == Brightness.dark
                    //           ? Colors.white.withOpacity(0.7)
                    //           : Colors.white.withOpacity(0.7),
                    //     ),
                    //     children: [
                    //       TextSpan(
                    //         text: widget.category.minititle,
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: Theme.of(context).brightness ==
                    //                   Brightness.dark
                    //               ? Colors.white
                    //               : Colors.white,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 6),
                    // Consumer<JobProvider>(
                    //   builder: (final context, final jobProvider, final child) {
                    //     final categoryJobs =
                    //         jobProvider.categoryJobsWithViewCounts;
                    //     return Container(
                    //       padding: const EdgeInsets.fromLTRB(
                    //         12,
                    //         4,
                    //         12,
                    //         6,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: Colors.white.withOpacity(0.1),
                    //         borderRadius: BorderRadius.circular(16),
                    //       ),
                    //       child: Text(
                    //         '${categoryJobs.length} jobs available',
                    //         style: const TextStyle(
                    //           fontSize: 10,
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (final context) => CategorySwitchBottomSheet(
        currentCategory: widget.category,
        onCategorySelected: (final RssCategory selectedCategory) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (final context) => CategoryJobScreen(
                category: selectedCategory,
                categoryColor:
                    _colorService.getCategoryColor(selectedCategory.icon),
              ),
            ),
          );
        },
      ),
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
}

class CategorySwitchBottomSheet extends StatefulWidget {
  final RssCategory currentCategory;
  final Function(RssCategory) onCategorySelected;

  const CategorySwitchBottomSheet({
    super.key,
    required this.currentCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategorySwitchBottomSheet> createState() =>
      _CategorySwitchBottomSheetState();
}

class _CategorySwitchBottomSheetState extends State<CategorySwitchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ColorService _colorService = ColorService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    final filteredCategories = RssCategories.categories.where((final category) {
      if (_searchQuery.isEmpty) return true;
      final localizedTitle =
          category.getLocalizedTitle(languageProvider.currentLanguage);
      return category.minititle
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          localizedTitle.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).textTheme.bodySmall?.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.1)
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.category_outlined,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Switch Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          Consumer<LanguageProvider>(
                            builder: (final context, final languageProvider,
                                final child) {
                              return RichText(
                                text: TextSpan(
                                  text: 'Currently viewing: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: widget.currentCategory
                                          .getLocalizedTitle(
                                              languageProvider.currentLanguage),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _colorService.getCategoryColor(
                                            widget.currentCategory.icon),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Search bar
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search,
                          color: Theme.of(context).textTheme.bodySmall?.color),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color),
                              onPressed: () {
                                _searchController.clear();
                                if (mounted) {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                }
                              },
                            )
                          : null,
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
                        setState(() {
                          _searchQuery = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Categories grid
          Expanded(
            child: Consumer2<JobProvider, LanguageProvider>(
              builder: (final context, final jobProvider,
                  final languageProvider, final child) {
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (final context, final index) {
                    final category = filteredCategories[index];
                    final jobCount =
                        jobProvider.getJobCountByCategory(category.feedUrl);
                    final categoryColor =
                        _colorService.getCategoryColor(category.icon);
                    final isCurrentCategory =
                        category.catid == widget.currentCategory.catid;

                    return InkWell(
                      onTap: () {
                        if (!isCurrentCategory) {
                          widget.onCategorySelected(category);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCurrentCategory
                                ? [
                                    categoryColor.withOpacity(0.3),
                                    categoryColor.withOpacity(0.2),
                                  ]
                                : [
                                    categoryColor.withOpacity(0.1),
                                    categoryColor.withOpacity(0.05),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrentCategory
                                ? categoryColor
                                : categoryColor.withOpacity(0.2),
                            width: isCurrentCategory ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _getIconData(category.icon),
                                  color: categoryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.minititle,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                category.getLocalizedTitle(
                                    languageProvider.currentLanguage),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  isCurrentCategory
                                      ? 'Current'
                                      : '$jobCount jobs',
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _selectedLocation = '';
  String _selectedExperience = '';

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Jobs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<JobProvider>(
            builder: (final context, final jobProvider, final child) {
              final uniqueLocations =
                  jobProvider.getUniqueLocationsFromCategoryJobs();
              return Container(
                width: double.infinity,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(6),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLocation.isEmpty ? null : _selectedLocation,
                    hint: const Text(
                      'Select Location',
                      style: TextStyle(fontSize: 12),
                    ),
                    isExpanded: true,
                    style: const TextStyle(fontSize: 12),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text(
                          'All Locations',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ...uniqueLocations
                          .map((final location) => DropdownMenuItem<String>(
                                value: location,
                                child: Text(
                                  location,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color),
                                ),
                              )),
                    ],
                    onChanged: (final String? value) {
                      if (mounted) {
                        setState(() {
                          _selectedLocation = value ?? '';
                        });
                      }
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Experience Level',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedExperience.isEmpty,
                labelStyle: const TextStyle(fontSize: 12),
                onSelected: (final selected) {
                  if (mounted) {
                    setState(() {
                      _selectedExperience = selected ? '' : _selectedExperience;
                    });
                  }
                },
              ),
              FilterChip(
                label: const Text('Entry'),
                selected: _selectedExperience == 'Entry',
                labelStyle: const TextStyle(fontSize: 12),
                onSelected: (final selected) {
                  if (mounted) {
                    setState(() {
                      _selectedExperience = selected ? 'Entry' : '';
                    });
                  }
                },
              ),
              FilterChip(
                label: const Text('Mid'),
                selected: _selectedExperience == 'Mid',
                labelStyle: const TextStyle(fontSize: 12),
                onSelected: (final selected) {
                  if (mounted) {
                    setState(() {
                      _selectedExperience = selected ? 'Mid' : '';
                    });
                  }
                },
              ),
              FilterChip(
                label: const Text('Senior'),
                selected: _selectedExperience == 'Senior',
                labelStyle: const TextStyle(fontSize: 12),
                onSelected: (final selected) {
                  if (mounted) {
                    setState(() {
                      _selectedExperience = selected ? 'Senior' : '';
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (mounted) {
                      context.read<JobProvider>().clearFilters();
                      setState(() {
                        _selectedLocation = '';
                        _selectedExperience = '';
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<JobProvider>()
                        .filterByLocation(_selectedLocation);
                    context
                        .read<JobProvider>()
                        .filterByExperience(_selectedExperience);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
