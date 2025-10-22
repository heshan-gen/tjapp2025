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
    print('🚀 WorkManagerBackgroundService.initialize() called');
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: true, // Enable debug mode to see logs
      );
      print('✅ WorkManager initialized successfully');
    } catch (e) {
      print('❌ WorkManager initialization failed: $e');
      rethrow;
    }
  }

  static Future<void> startBackgroundTask() async {
    print('🔄 Starting background task registration...');
    try {
      // Cancel any existing task first
      await Workmanager().cancelByUniqueName(_taskName);
      await Workmanager().cancelByUniqueName('${_taskName}_immediate');
      print('✅ Cancelled existing tasks');

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
      print('✅ Registered immediate one-off task (5 seconds delay)');

      // Register periodic task for ongoing checks
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency:
            const Duration(minutes: 15), // Use Android minimum: 15 minutes
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        initialDelay:
            const Duration(minutes: 1), // Start periodic after 1 minute
      );
      print(
          '✅ Registered periodic task (every 15 minutes, starts in 1 minute)');
      print('📝 Background task registration completed successfully');
    } catch (e) {
      print('❌ Failed to register background tasks: $e');
      rethrow;
    }
  }

  static Future<void> stopBackgroundTask() async {
    await Workmanager().cancelByUniqueName(_taskName);
    await Workmanager().cancelByUniqueName('${_taskName}_immediate');
    print('Background tasks cancelled');
  }

  static Future<void> checkForNewJobs() async {
    print('🔍 ===== CHECKING FOR NEW JOBS ===== 🔍');
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscribedCategories =
          prefs.getStringList(_subscribedCategoriesKey) ?? [];

      print('📱 Subscribed categories: ${subscribedCategories.length}');
      print('📝 Categories: $subscribedCategories');

      if (subscribedCategories.isEmpty) {
        print('⚠️ No categories subscribed, skipping check');
        return;
      }

      final lastCheck = await _getLastCheckTime();
      final now = DateTime.now();

      if (lastCheck != null) {
        final timeSinceLastCheck = now.difference(lastCheck);
        print(
            '⏱️ Time since last check: ${timeSinceLastCheck.inSeconds} seconds');
      } else {
        print('ℹ️ This is the first check');
      }

      // Only check if it's been at least 1 minute since last check
      if (lastCheck != null && now.difference(lastCheck).inMinutes < 1) {
        print('⏸️ Too soon since last check, skipping');
        return;
      }

      print(
          '🌐 Fetching jobs from ${subscribedCategories.length} categories...');

      // Fetch current jobs from RSS feeds
      final currentJobs = await BackgroundJobService.fetchJobsFromCategories(
          subscribedCategories);
      final currentJobIds =
          currentJobs.map((final job) => job.comments).toList();
      final knownJobIds = await _getKnownJobIds();

      print('📊 Current jobs: ${currentJobIds.length}');
      print('📚 Known jobs: ${knownJobIds.length}');

      // Find new job IDs
      final newJobIds = currentJobIds
          .where((final jobId) => !knownJobIds.contains(jobId))
          .toList();

      if (newJobIds.isNotEmpty) {
        print('🎉 Found ${newJobIds.length} new jobs - sending notifications');
        print('📂 Subscribed categories: $subscribedCategories');

        // Get the actual job objects for new jobs
        final newJobs = currentJobs
            .where((final job) => newJobIds.contains(job.comments))
            .toList();

        // Track jobs per category
        final Map<String, int> jobsPerCategory = {};

        // Show notifications for new jobs
        for (final job in newJobs) {
          final categoryName =
              _getCategoryNameForJob(job, subscribedCategories);

          // Count jobs per category
          jobsPerCategory[categoryName] =
              (jobsPerCategory[categoryName] ?? 0) + 1;

          print('📬 Sending notification for: ${job.title}');
          print('   Category: $categoryName');

          await _showLocalNotification(
            'New Job Available',
            job.title,
            {
              'jobId': job.comments,
              'category': categoryName,
              'url': job.id,
            },
          );
        }

        // Print summary of jobs per category
        print('📊 ===== JOB CATEGORY SUMMARY ===== 📊');
        jobsPerCategory.forEach((final category, final count) {
          print('   $category: $count job(s)');
        });
        print('📊 ================================= 📊');

        // Update known job IDs
        await _updateKnownJobIds(currentJobIds);
        print('✅ Updated known job IDs');
      } else {
        print('ℹ️ No new jobs found');
      }

      await _setLastCheckTime(now);
      print('✅ Background check completed at ${now.toString()}');
      print('🏁 ===== CHECK FINISHED ===== 🏁');
    } catch (e, stackTrace) {
      print('❌ Background service error: $e');
      print('Stack trace: $stackTrace');
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
    print('📲 ===== SHOWING NOTIFICATION ===== 📲');
    print('📋 Title: $title');
    print('📄 Body: $body');
    print('📦 Data: $data');

    try {
      final FlutterLocalNotificationsPlugin localNotifications =
          FlutterLocalNotificationsPlugin();
      print('✅ Created FlutterLocalNotificationsPlugin instance');

      // Initialize local notifications with proper settings
      // Using ic_launcher_foreground from drawable folders
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

      print('🔧 Initializing notification plugin...');
      final initialized = await localNotifications.initialize(settings);
      print('✅ Plugin initialized: $initialized');

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
        print('🔧 Creating notification channel...');
        await androidImplementation.createNotificationChannel(channel);
        print('✅ Notification channel created: job_alerts');
      } else {
        print('⚠️ Android implementation is null!');
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'job_alerts',
        'Job Alerts',
        channelDescription: 'Notifications for new job opportunities',
        importance: Importance.max,
        priority: Priority.max,
        // No custom icon - Android will use default notification icon
        enableVibration: true,
        playSound: true,
        showWhen: true,
        autoCancel: true,
        ongoing: false,
        visibility: NotificationVisibility.public,
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

      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);
      print('🔔 Showing notification with ID: $notificationId');

      await localNotifications.show(
        notificationId,
        title,
        body,
        details,
        payload: jsonEncode(data),
      );

      print('✅ ✅ ✅ Notification.show() completed successfully! ✅ ✅ ✅');
      print('📲 Notification should now be visible on device!');
      print('📲 ===== NOTIFICATION PROCESS COMPLETE ===== 📲');
    } catch (e, stackTrace) {
      print('❌ ❌ ❌ ERROR SHOWING NOTIFICATION ❌ ❌ ❌');
      print('❌ Error: $e');
      print('❌ Stack trace: $stackTrace');
      print('📲 ===== NOTIFICATION FAILED ===== 📲');
    }
  }
}

// This function must be a top-level function for WorkManager
@pragma('vm:entry-point')
void callbackDispatcher() {
  print('🎯 ===== CALLBACK DISPATCHER CALLED ===== 🎯');
  Workmanager().executeTask((final task, final inputData) async {
    print('⏰ WorkManager task started at: ${DateTime.now()}');
    print('📋 Task name: $task');
    print('📦 Input data: $inputData');

    try {
      if (task == 'jobCheckTask' || task == 'jobCheckTask_immediate') {
        print('✅ Task matches our job check tasks, executing...');
        await WorkManagerBackgroundService.checkForNewJobs();
        print('✅ Job check completed successfully');
        return Future.value(true);
      } else {
        print('⚠️ Unknown task: $task');
        return Future.value(false);
      }
    } catch (e, stackTrace) {
      print('❌ Task execution failed: $e');
      print('Stack trace: $stackTrace');
      return Future.value(false);
    }
  });
}
