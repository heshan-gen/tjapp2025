import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/rss_categories.dart';
import '../providers/job_provider.dart';

class SimpleBackgroundService {
  static Timer? _timer;
  static const String _lastCheckKey = 'last_rss_check';
  static const String _subscribedCategoriesKey = 'subscribed_categories';
  static const String _knownJobIdsKey = 'known_job_ids';
  static const Duration _checkInterval = Duration(seconds: 10);

  static Future<void> startMonitoring() async {
    // Stop any existing timer
    stopMonitoring();

    // Start the timer
    _timer = Timer.periodic(_checkInterval, (final timer) async {
      await checkForNewJobs();
    });

    print('Background monitoring started - checking every 10 seconds');
  }

  static void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    print('Background monitoring stopped');
  }

  static Future<void> checkForNewJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscribedCategories =
          prefs.getStringList(_subscribedCategoriesKey) ?? [];

      if (subscribedCategories.isEmpty) {
        print('No categories subscribed, skipping check');
        return;
      }

      final lastCheck = await _getLastCheckTime();
      final now = DateTime.now();

      // Only check if it's been at least 10 seconds since last check
      if (lastCheck != null && now.difference(lastCheck).inSeconds < 10) {
        print('Too soon since last check, skipping');
        return;
      }

      print(
          'Checking for new jobs in ${subscribedCategories.length} categories...');

      // Get current job IDs from JobProvider
      final currentJobIds = await _getCurrentJobIds();
      final knownJobIds = await _getKnownJobIds();

      // Find new job IDs
      final newJobIds = currentJobIds
          .where((final jobId) => !knownJobIds.contains(jobId))
          .toList();

      if (newJobIds.isNotEmpty) {
        print('Found ${newJobIds.length} new jobs by jobId comparison');

        // Get the actual job objects for new jobs
        final newJobs = await _getJobsByIds(newJobIds, subscribedCategories);

        // Show notifications for new jobs
        for (final job in newJobs) {
          await _showLocalNotification(
            'New Job Available',
            job.title,
            {
              'jobId': job.jobId,
              'category': _getCategoryNameForJob(job, subscribedCategories),
              'url': job.id,
            },
          );
        }

        // Update known job IDs
        await _updateKnownJobIds(currentJobIds);
      } else {
        print('No new jobs found');
      }

      await _setLastCheckTime(now);
      print('Background check completed');
    } catch (e) {
      print('Background service error: $e');
    }
  }

  static Future<DateTime?> _getLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastCheckKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  static Future<void> _setLastCheckTime(final DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCheckKey, time.millisecondsSinceEpoch);
  }

  // Get current job IDs from JobProvider
  static Future<List<String>> _getCurrentJobIds() async {
    try {
      // Create a temporary JobProvider instance to load jobs
      final jobProvider = JobProvider();
      await jobProvider.loadJobs();

      // Extract jobIds from all jobs (using comments as unique identifier)
      return jobProvider.jobs
          .where((final job) => job.comments.isNotEmpty)
          .map((final job) => job.comments)
          .toList();
    } catch (e) {
      print('Error getting current job IDs: $e');
      return [];
    }
  }

  // Get known job IDs from storage
  static Future<Set<String>> _getKnownJobIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jobIdsList = prefs.getStringList(_knownJobIdsKey) ?? [];
    return jobIdsList.toSet();
  }

  // Update known job IDs in storage
  static Future<void> _updateKnownJobIds(
      final List<String> currentJobIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_knownJobIdsKey, currentJobIds);
  }

  // Get job objects by their IDs
  static Future<List<Job>> _getJobsByIds(final List<String> jobIds,
      final List<String> subscribedCategories) async {
    try {
      final jobProvider = JobProvider();
      await jobProvider.loadJobs();

      // Filter jobs by comments (unique identifier) and subscribed categories
      return jobProvider.jobs.where((final job) {
        return jobIds.contains(job.comments) &&
            _isJobInSubscribedCategories(job, subscribedCategories);
      }).toList();
    } catch (e) {
      print('Error getting jobs by IDs: $e');
      return [];
    }
  }

  // Check if job belongs to subscribed categories
  static bool _isJobInSubscribedCategories(
      final Job job, final List<String> subscribedCategories) {
    // Check if job's feed URL matches any subscribed category
    for (final categoryId in subscribedCategories) {
      final category = RssCategories.getCategoryById(categoryId);
      if (category != null && job.feedUrl == category.feedUrl) {
        return true;
      }
    }
    return false;
  }

  // Get category name for a job
  static String _getCategoryNameForJob(
      final Job job, final List<String> subscribedCategories) {
    for (final categoryId in subscribedCategories) {
      final category = RssCategories.getCategoryById(categoryId);
      if (category != null && job.feedUrl == category.feedUrl) {
        return category.minititle;
      }
    }
    return 'Job';
  }

  static Future<void> _showLocalNotification(final String title,
      final String body, final Map<String, dynamic> data) async {
    try {
      final FlutterLocalNotificationsPlugin localNotifications =
          FlutterLocalNotificationsPlugin();

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('ic_launcher_foreground');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await localNotifications.initialize(settings);

      // Create notification channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'job_alerts',
        'Job Alerts',
        description: 'Notifications for new job opportunities',
        importance: Importance.high,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'job_alerts',
        'Job Alerts',
        channelDescription: 'Notifications for new job opportunities',
        importance: Importance.high,
        priority: Priority.high,
        // No custom icon - Android will use default notification icon
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: jsonEncode(data),
      );

      print('Notification sent: $title');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
