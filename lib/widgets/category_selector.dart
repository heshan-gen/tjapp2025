import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/rss_categories.dart';
import '../screens/category_job_screen.dart';
import '../providers/job_provider.dart';
import '../services/color_service.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({
    super.key,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector>
    with TickerProviderStateMixin {
  // Use the centralized color service
  final ColorService _colorService = ColorService();

  // Auto scroll controllers
  late ScrollController _scrollController;
  late AnimationController _animationController;

  // Auto scroll variables
  bool _isAutoScrolling = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Start auto scroll after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (!mounted || _isAutoScrolling) return;

    _isAutoScrolling = true;
    _autoScroll();
  }

  void _autoScroll() {
    if (!mounted || !_isAutoScrolling) return;

    // Calculate next position
    const itemWidth = 132.0; // Approximate width of each category item
    final nextPosition = _currentIndex * itemWidth;

    // Animate to next position
    _animationController.reset();
    _animationController.forward().then((final _) {
      if (mounted && _isAutoScrolling) {
        _scrollController
            .animateTo(
          nextPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        )
            .then((final _) {
          if (mounted && _isAutoScrolling) {
            _currentIndex =
                (_currentIndex + 1) % RssCategories.categories.length;
            // Wait before next scroll
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && _isAutoScrolling) {
                _autoScroll();
              }
            });
          }
        });
      }
    });
  }

  void _stopAutoScroll() {
    _isAutoScrolling = false;
    _animationController.stop();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Job Categories',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            // const SizedBox(width: 8),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFF892621),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Text(
            //     '${RssCategories.categories.length}',
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontSize: 12,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: Consumer<JobProvider>(
            builder: (final context, final jobProvider, final child) {
              return GestureDetector(
                onPanStart: (final _) => _stopAutoScroll(),
                onTapDown: (final _) => _stopAutoScroll(),
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: RssCategories.categories.length,
                  itemBuilder: (final context, final index) {
                    final category = RssCategories.categories[index];
                    final jobCount =
                        jobProvider.getJobCountByCategory(category.feedUrl);

                    // Get the color for this category (cached and consistent)
                    final categoryColor = _colorService
                        .getCategoryColor(category.icon, index: index);

                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () {
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
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 120),
                          child: IntrinsicWidth(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    categoryColor,
                                    Theme.of(context).colorScheme.surface,
                                    Theme.of(context).colorScheme.surface,
                                    Theme.of(context).colorScheme.surface
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(2), // Border width
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      categoryColor,
                                      Theme.of(context).colorScheme.tertiary,
                                      Theme.of(context).colorScheme.tertiary,
                                      Theme.of(context).colorScheme.tertiary,
                                      Theme.of(context).colorScheme.tertiary,
                                      Theme.of(context).colorScheme.tertiary
                                    ],
                                    begin: Alignment.bottomRight,
                                    end: Alignment.topLeft,
                                  ),
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(
                                      7), // Slightly smaller radius
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getIconData(category.icon),
                                      color: categoryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      category.minititle,
                                      style: TextStyle(
                                        color: categoryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      category.englisht,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                        fontSize: 9,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: categoryColor
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$jobCount jobs',
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
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
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
}
