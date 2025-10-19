// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';
import '../data/rss_categories.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      context.read<NotificationProvider>().initialize();
    });
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.cog),
            onPressed: () =>
                Navigator.pushNamed(context, '/background-settings'),
            tooltip: 'Background Settings',
            iconSize: 18,
          ),
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
      body: Consumer<NotificationProvider>(
        builder: (final context, final notificationProvider, final child) {
          if (notificationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(notificationProvider),
                const SizedBox(height: 24),
                _buildQuickActionsSection(notificationProvider),
                const SizedBox(height: 24),
                _buildCategoriesSection(notificationProvider),
                const SizedBox(height: 24),
                _buildInfoSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(final NotificationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.grey.withOpacity(0.15),
                  Colors.grey.withOpacity(0.08),
                ]
              : [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.grey.withOpacity(0.3)
              : Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: Theme.of(context).textTheme.titleLarge?.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Job Alert Notifications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Get notified when new jobs are posted in your subscribed categories. We check for new jobs in real-time (every 10 seconds) even when the app is closed.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color:
                    provider.notificationsEnabled ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                provider.notificationsEnabled
                    ? '${provider.subscribedCount} categories subscribed'
                    : 'No categories subscribed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: provider.notificationsEnabled
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(final NotificationProvider provider) {
    final allSubscribed =
        provider.subscribedCount == RssCategories.categories.length;
    final hasSubscriptions = provider.subscribedCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        _buildMasterSwitch(provider, allSubscribed, hasSubscriptions),
      ],
    );
  }

  Widget _buildMasterSwitch(
    final NotificationProvider provider,
    final bool allSubscribed,
    final bool hasSubscriptions,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: allSubscribed
              ? Colors.green.withOpacity(0.3)
              : hasSubscriptions
                  ? Colors.orange.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: allSubscribed
                  ? Colors.green
                  : hasSubscriptions
                      ? Colors.orange
                      : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              allSubscribed
                  ? FontAwesomeIcons.bell
                  : hasSubscriptions
                      ? FontAwesomeIcons.bellSlash
                      : FontAwesomeIcons.bellSlash,
              color: allSubscribed || hasSubscriptions
                  ? Colors.white
                  : Colors.grey,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allSubscribed
                      ? 'All Categories Subscribed'
                      : hasSubscriptions
                          ? 'Partial Subscriptions'
                          : 'No Subscriptions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  allSubscribed
                      ? 'You\'re receiving notifications for all job categories'
                      : hasSubscriptions
                          ? 'Subscribed to ${provider.subscribedCount} of ${RssCategories.categories.length} categories'
                          : 'Subscribe to categories below to get job notifications',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Switch(
                value: allSubscribed,
                onChanged: (final value) {
                  if (value) {
                    _showSubscribeAllDialog(provider);
                  } else {
                    _showUnsubscribeAllDialog(provider);
                  }
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
                trackOutlineColor:
                    MaterialStateProperty.all(Colors.grey.withOpacity(0.3)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(final NotificationProvider provider) {
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
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            Text(
              '${provider.subscribedCount}/${RssCategories.categories.length}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...RssCategories.categories
            .map((final category) => _buildCategoryTile(category, provider)),
      ],
    );
  }

  Widget _buildCategoryTile(
      final RssCategory category, final NotificationProvider provider) {
    final isSubscribed = provider.isSubscribed(category.catid);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSubscribed
              ? Colors.green
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSubscribed
                ? Colors.green
                : Theme.of(context).colorScheme.outline.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(category.icon),
            color: isSubscribed ? Colors.white : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          category.englisht,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Text(
          category.minititle,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        trailing: Switch(
          value: isSubscribed,
          onChanged: (final value) {
            provider.toggleCategorySubscription(category.catid);
          },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.3),
          trackOutlineColor:
              MaterialStateProperty.all(Colors.grey.withOpacity(0.3)),
        ),
        onTap: () {
          provider.toggleCategorySubscription(category.catid);
        },
      ),
    );
  }

  Widget _buildInfoSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final infoColor = Theme.of(context).colorScheme.primary;
    final backgroundColor =
        isDark ? infoColor.withOpacity(0.15) : infoColor.withOpacity(0.1);
    final borderColor =
        isDark ? infoColor.withOpacity(1) : infoColor.withOpacity(0.3);
    final titleColor =
        isDark ? infoColor.withOpacity(1) : infoColor.withOpacity(0.8);
    final textColor =
        isDark ? infoColor.withOpacity(1) : infoColor.withOpacity(0.7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: infoColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'How it works',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• We check for new jobs in real-time (every 10 seconds) even when app is closed\n'
            '• You\'ll receive notifications only for subscribed categories\n'
            '• Notifications work even when the app is closed\n'
            '• You can change your preferences anytime',
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(final String iconName) {
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

  void _showSubscribeAllDialog(final NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Subscribe to All Categories',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will subscribe you to notifications for all job categories. You can unsubscribe from specific categories later.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please note: Subscribing to all categories is not recommended. topjobs posts numerous jobs daily, which may result in an overwhelming number of notifications. We recommend subscribing to only 1-2 categories that match your interests.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.subscribeToAllCategories();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Subscribe All',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnsubscribeAllDialog(final NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Unsubscribe from All Categories',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will stop all job notifications. You can subscribe to specific categories later.',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.unsubscribeFromAllCategories();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 165, 15, 4),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Unsubscribe All',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
