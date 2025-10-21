import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'simple_background_service.dart';
import 'workmanager_background_service.dart';

// Top-level background message handler (must be outside class and be public)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    final RemoteMessage message) async {
  // Initialize Firebase with proper options for release builds
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Handling background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');

  // Show notification even when app is closed
  await _showBackgroundNotification(
    message.notification?.title ?? 'New Job Alert',
    message.notification?.body ?? 'Check out the latest job opportunities!',
    message.data,
  );
}

// Helper function to show notifications in background
Future<void> _showBackgroundNotification(
  final String title,
  final String body,
  final Map<String, dynamic> data,
) async {
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize local notifications for background
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('ic_launcher_foreground');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await localNotifications.initialize(settings);

  // Create notification channel for Android if needed
  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'job_alerts',
      'Job Alerts',
      description: 'Notifications for new job opportunities',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
    }
  }

  // Show the notification
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'job_alerts',
    'Job Alerts',
    channelDescription: 'Notifications for new job opportunities',
    importance: Importance.high,
    priority: Priority.high,
    // No custom icon - Android will use default notification icon
    enableVibration: true,
    playSound: true,
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

  print('Background notification shown: $title');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static const String _subscribedCategoriesKey = 'subscribed_categories';

  Future<void> initialize() async {
    // Initialize local notifications
    await _initializeLocalNotifications();

    // Initialize Firebase messaging
    await _initializeFirebaseMessaging();

    // Initialize WorkManager for background tasks
    await WorkManagerBackgroundService.initialize();

    // Request notification permissions
    await _requestPermissions();
  }

  Future<void> _initializeLocalNotifications() async {
    try {
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

      final bool? initialized = await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized ?? false) {
        print('Local notifications initialized successfully');

        // Create notification channel for Android
        if (Platform.isAndroid) {
          await _createNotificationChannel();
        }
      } else {
        print('Failed to initialize local notifications');
      }
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'job_alerts',
      'Job Alerts',
      description: 'Notifications for new job opportunities',
      importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
      print('Notification channel created successfully');
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Background messages are handled by the top-level handler registered in main.dart

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _onNotificationTapped(
      final NotificationResponse response) async {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      // Navigate to job details or home screen
      // This will be handled by the main app
    }
  }

  Future<void> _handleForegroundMessage(final RemoteMessage message) async {
    await _showLocalNotification(
      message.notification?.title ?? 'New Job Alert',
      message.notification?.body ?? 'Check out the latest job opportunities!',
      message.data,
    );
  }

  Future<void> _handleNotificationTap(final RemoteMessage message) async {
    // Handle notification tap when app is in background
    // This will be handled by the main app
  }

  Future<void> _showLocalNotification(final String title, final String body,
      final Map<String, dynamic> data) async {
    try {
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

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: jsonEncode(data),
      );

      print('Local notification sent successfully: $title');
    } catch (e) {
      print('Error showing local notification: $e');
      // Try to reinitialize the plugin
      await _initializeLocalNotifications();
    }
  }

  Future<void> subscribeToCategory(final String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final subscribed = await getSubscribedCategories();
    subscribed.add(categoryId);
    await prefs.setStringList(_subscribedCategoriesKey, subscribed);

    // Start background task if not already running
    await startBackgroundTask();
  }

  Future<void> unsubscribeFromCategory(final String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final subscribed = await getSubscribedCategories();
    subscribed.remove(categoryId);
    await prefs.setStringList(_subscribedCategoriesKey, subscribed);

    // Stop background task if no categories subscribed
    if (subscribed.isEmpty) {
      await stopBackgroundTask();
    }
  }

  Future<List<String>> getSubscribedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_subscribedCategoriesKey) ?? [];
  }

  Future<void> startBackgroundTask() async {
    // Use WorkManager for true background execution
    await WorkManagerBackgroundService.startBackgroundTask();

    // Also start the simple service for when app is active
    await SimpleBackgroundService.startMonitoring();
  }

  Future<void> stopBackgroundTask() async {
    // Stop both services
    await WorkManagerBackgroundService.stopBackgroundTask();
    SimpleBackgroundService.stopMonitoring();
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> checkForNewJobs() async {
    await SimpleBackgroundService.checkForNewJobs();
  }

  Future<void> updateNewJobsCount(final int count) async {
    // This method can be called to update the new jobs count
    // The actual implementation will be handled by the provider
    print('New jobs count updated: $count');
  }

  Future<void> sendTestNotification() async {
    try {
      // Ensure local notifications are initialized
      await _initializeLocalNotifications();

      await _showLocalNotification(
        'Test Notification',
        'This is a test notification from topjobs app',
        {'test': 'true'},
      );
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }
}
