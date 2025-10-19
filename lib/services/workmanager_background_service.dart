// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/rss_categories.dart';
import '../providers/job_provider.dart';
import 'background_job_service.dart';

class WorkManagerBackgroundService {
  static const String _taskName = 'jobCheckTask';
  static const String _lastCheckKey = 'last_rss_check';
  static const String _subscribedCategoriesKey = 'subscribed_categories';
  static const String _knownJobIdsKey = 'known_job_ids';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> startBackgroundTask() async {
    // Cancel any existing task first
    await Workmanager().cancelByUniqueName(_taskName);

    // Register a one-time task for immediate execution
    await Workmanager().registerOneOffTask(
      '${_taskName}_immediate',
      '${_taskName}_immediate',
      initialDelay: const Duration(seconds: 5), // Start after 5 seconds
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    // Register periodic task for ongoing checks
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 5), // Check every 5 minutes
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      initialDelay: const Duration(minutes: 1), // Start periodic after 1 minute
    );
    print(
        'Background task registered with WorkManager - immediate check in 5 seconds, then every 5 minutes');
  }

  static Future<void> stopBackgroundTask() async {
    await Workmanager().cancelByUniqueName(_taskName);
    await Workmanager().cancelByUniqueName('${_taskName}_immediate');
    print('Background tasks cancelled');
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

      // Only check if it's been at least 1 minute since last check
      if (lastCheck != null && now.difference(lastCheck).inMinutes < 1) {
        print('Too soon since last check, skipping');
        return;
      }

      print(
          'Checking for new jobs in ${subscribedCategories.length} categories...');

      // Fetch current jobs from RSS feeds
      final currentJobs = await BackgroundJobService.fetchJobsFromCategories(
          subscribedCategories);
      final currentJobIds =
          currentJobs.map((final job) => job.comments).toList();
      final knownJobIds = await _getKnownJobIds();

      // Find new job IDs
      final newJobIds = currentJobIds
          .where((final jobId) => !knownJobIds.contains(jobId))
          .toList();

      if (newJobIds.isNotEmpty) {
        print('Found ${newJobIds.length} new jobs by jobId comparison');

        // Get the actual job objects for new jobs
        final newJobs = currentJobs
            .where((final job) => newJobIds.contains(job.comments))
            .toList();

        // Show notifications for new jobs
        for (final job in newJobs) {
          await _showLocalNotification(
            'New Job Available',
            job.title,
            {
              'jobId': job.comments,
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

      // Initialize local notifications with proper settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
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

      // Create notification channel for Android with high importance
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'job_alerts',
        'Job Alerts',
        description: 'Notifications for new job opportunities',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
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
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        showWhen: true,
        autoCancel: true,
        ongoing: false,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.message,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
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

// This function must be a top-level function for WorkManager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((final task, final inputData) async {
    print('WorkManager task executed: $task');

    if (task == 'jobCheckTask' || task == 'jobCheckTask_immediate') {
      await WorkManagerBackgroundService.checkForNewJobs();
    }

    return Future.value(true);
  });
}
