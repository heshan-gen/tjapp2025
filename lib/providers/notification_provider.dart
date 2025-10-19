import 'package:flutter/material.dart';
import '../data/rss_categories.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<String> _subscribedCategories = [];
  bool _isLoading = false;
  String? _fcmToken;
  bool _notificationsEnabled = true;

  List<String> get subscribedCategories => _subscribedCategories;
  bool get isLoading => _isLoading;
  String? get fcmToken => _fcmToken;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize notification service
      await _notificationService.initialize();

      // Load subscribed categories
      _subscribedCategories =
          await _notificationService.getSubscribedCategories();

      // Get FCM token
      _fcmToken = await _notificationService.getFCMToken();

      // Check if notifications are enabled
      _notificationsEnabled = _subscribedCategories.isNotEmpty;

      // Start background monitoring if categories are subscribed
      if (_subscribedCategories.isNotEmpty) {
        await _notificationService.startBackgroundTask();
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCategorySubscription(final String categoryId) async {
    if (_subscribedCategories.contains(categoryId)) {
      await unsubscribeFromCategory(categoryId);
    } else {
      await subscribeToCategory(categoryId);
    }
  }

  Future<void> subscribeToCategory(final String categoryId) async {
    try {
      await _notificationService.subscribeToCategory(categoryId);
      _subscribedCategories.add(categoryId);
      _notificationsEnabled = true;
      notifyListeners();
    } catch (e) {
      print('Error subscribing to category: $e');
    }
  }

  Future<void> unsubscribeFromCategory(final String categoryId) async {
    try {
      await _notificationService.unsubscribeFromCategory(categoryId);
      _subscribedCategories.remove(categoryId);
      _notificationsEnabled = _subscribedCategories.isNotEmpty;
      notifyListeners();
    } catch (e) {
      print('Error unsubscribing from category: $e');
    }
  }

  Future<void> subscribeToAllCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      for (final category in RssCategories.categories) {
        if (!_subscribedCategories.contains(category.catid)) {
          await _notificationService.subscribeToCategory(category.catid);
        }
      }
      _subscribedCategories =
          RssCategories.categories.map((final c) => c.catid).toList();
      _notificationsEnabled = true;
    } catch (e) {
      print('Error subscribing to all categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unsubscribeFromAllCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      for (final categoryId in _subscribedCategories) {
        await _notificationService.unsubscribeFromCategory(categoryId);
      }
      _subscribedCategories.clear();
      _notificationsEnabled = false;
    } catch (e) {
      print('Error unsubscribing from all categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isSubscribed(final String categoryId) {
    return _subscribedCategories.contains(categoryId);
  }

  int get subscribedCount => _subscribedCategories.length;

  List<RssCategory> get subscribedCategoryDetails {
    return RssCategories.categories
        .where(
            (final category) => _subscribedCategories.contains(category.catid))
        .toList();
  }

  Future<void> refreshFCMToken() async {
    try {
      _fcmToken = await _notificationService.getFCMToken();
      notifyListeners();
    } catch (e) {
      print('Error refreshing FCM token: $e');
    }
  }

  Future<void> testNotification() async {
    try {
      await _notificationService.sendTestNotification();
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }

  // Method to test notifications directly
  Future<void> testNotificationDirect() async {
    try {
      await _notificationService.sendTestNotification();
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }
}
