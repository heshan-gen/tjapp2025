# Push Notifications Setup Guide

This guide will help you set up push notifications for your Flutter job app with RSS feed monitoring.

## Features Added

✅ **Notification Settings Screen** - Users can subscribe to specific job categories
✅ **Background RSS Monitoring** - App checks for new jobs every 30 minutes
✅ **Push Notifications** - Users receive alerts for new jobs in subscribed categories
✅ **Notification Icon** - Added to home screen app bar with subscription count
✅ **Firebase Messaging** - Integrated for reliable push notifications
✅ **Local Notifications** - Fallback for when Firebase is unavailable

## Setup Instructions

### 1. Install Dependencies

The following dependencies have been added to `pubspec.yaml`:

```yaml
dependencies:
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^17.2.2
```

**Note:** We removed the `workmanager` dependency and implemented a simpler timer-based background service that works more reliably across different Android versions.

Run `flutter pub get` to install the new dependencies.

### 2. Android Configuration

#### Permissions Added to AndroidManifest.xml:
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.WAKE_LOCK`
- `android.permission.VIBRATE`
- `android.permission.POST_NOTIFICATIONS`

#### Firebase Messaging Service Added:
The Firebase messaging service has been configured in the Android manifest.

### 3. iOS Configuration

For iOS, you'll need to:

1. Enable Push Notifications capability in Xcode
2. Add the following to your `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 4. Firebase Console Setup

1. Go to Firebase Console
2. Select your project
3. Go to Cloud Messaging
4. Create a new notification campaign or use the API to send notifications

### 5. Testing

1. Run the app: `flutter run`
2. Go to the notification settings screen (bell icon in app bar)
3. Subscribe to one or more job categories
4. Use the "Send Test Notification" button to test notifications
5. The app will check for new jobs in real-time (every 10 seconds) in the background, even when the app is closed

## How It Works

### 1. User Subscription
- Users can subscribe to specific job categories from the notification settings screen
- Subscriptions are stored locally using SharedPreferences
- A notification icon in the app bar shows the number of subscribed categories

### 2. Background Monitoring
- The app uses WorkManager to check for new jobs in real-time (every 10 seconds) even when the app is closed
- Background tasks check RSS feeds for new jobs in subscribed categories
- Only jobs posted after the last check are considered "new"
- This approach is more reliable than WorkManager and works across all Android versions

### 3. Notification Delivery
- New jobs trigger local notifications with job title and category
- Firebase Messaging is used for reliable delivery
- Notifications work even when the app is closed

### 4. RSS Feed Parsing
- The app parses RSS feeds from topjobs.lk
- Extracts job title, description, link, and publication date
- Filters jobs based on publication date to find new ones

## File Structure

```
lib/
├── services/
│   ├── notification_service.dart          # Main notification service
│   ├── background_service.dart            # Background RSS monitoring (WorkManager-based)
│   └── simple_background_service.dart     # Simple timer-based background service
├── providers/
│   └── notification_provider.dart         # State management for notifications
├── screens/
│   └── notification_settings_screen.dart  # UI for subscription management
└── main.dart                              # Updated with notification provider
```

## Customization

### Change Check Frequency
To change how often the app checks for new jobs, modify the frequency in `simple_background_service.dart`:

```dart
static const Duration _checkInterval = Duration(minutes: 5); // Change this value
```

### Add More RSS Feeds
Add new RSS feeds to `lib/data/rss_categories.dart`:

```dart
static const List<RssCategory> categories = [
  // Add your new categories here
];
```

### Customize Notification Appearance
Modify notification appearance in `notification_service.dart`:

```dart
const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'job_alerts',
  'Job Alerts',
  channelDescription: 'Notifications for new job opportunities',
  importance: Importance.high,
  priority: Priority.high,
  icon: '@mipmap/ic_launcher', // Change icon
);
```

## Troubleshooting

### Notifications Not Working
1. Check if notifications are enabled in device settings
2. Verify Firebase configuration is correct
3. Check if the app has notification permissions
4. Test with the "Send Test Notification" button

### Background Tasks Not Running
1. Check if battery optimization is disabled for the app
2. Ensure the app is not force-closed by the user
3. Check device-specific background app restrictions
4. The timer-based approach is more reliable than WorkManager

### RSS Feed Issues
1. Verify RSS feed URLs are accessible
2. Check network connectivity
3. Review RSS feed parsing logic in `simple_background_service.dart`

## Security Considerations

- RSS feeds are checked over HTTPS
- No sensitive data is stored in notifications
- Background tasks are limited to 5-minute intervals to preserve battery
- User subscriptions are stored locally, not on external servers

## Performance Notes

- Background tasks are optimized to run only when network is available
- RSS feeds are checked sequentially to avoid overwhelming the server
- Notifications are batched to avoid spam
- The app respects device battery optimization settings
