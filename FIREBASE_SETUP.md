# Firebase Setup for View Count Feature

This document explains how to set up Firebase for the view count feature in your Flutter app.

## Prerequisites

1. A Google account
2. Flutter development environment set up
3. Android Studio or VS Code with Flutter extensions

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name (e.g., "topjobs-view-count")
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Android App to Firebase

1. In your Firebase project, click "Add app" and select Android
2. Enter your Android package name (check `android/app/build.gradle` for `applicationId`)
3. Enter an app nickname (optional)
4. Click "Register app"
5. Download the `google-services.json` file
6. Place the `google-services.json` file in `android/app/` directory

## Step 3: Add iOS App to Firebase (if needed)

1. In your Firebase project, click "Add app" and select iOS
2. Enter your iOS bundle ID (check `ios/Runner/Info.plist` for `CFBundleIdentifier`)
3. Enter an app nickname (optional)
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place the `GoogleService-Info.plist` file in `ios/Runner/` directory

## Step 4: Enable Firestore Database

1. In your Firebase project, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database
5. Click "Done"

## Step 5: Configure Firestore Security Rules

1. Go to "Firestore Database" > "Rules"
2. Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to job_views collection
    match /job_views/{document} {
      allow read, write: if true; // For development only
    }
  }
}
```

**Note**: For production, implement proper authentication and security rules.

## Step 6: Update Firebase Configuration

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase for your Flutter project:
   ```bash
   flutterfire configure
   ```

3. This will automatically update your `lib/firebase_options.dart` file with the correct configuration.

## Step 7: Install Dependencies

Run the following command to install the required dependencies:

```bash
flutter pub get
```

## Step 8: Test the Implementation

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Navigate to the job list screen
3. Tap on any job to increment its view count
4. The view count should be displayed in the job card and updated in Firestore

## Firestore Data Structure

The view count data is stored in Firestore with the following structure:

**Collection**: `job_views`
**Document ID**: `{job.comments}` (unique job identifier)
**Document Fields**:
- `jobComments`: String (job identifier)
- `viewCount`: Number (current view count)
- `firstViewed`: Timestamp (when first viewed)
- `lastViewed`: Timestamp (when last viewed)

## Troubleshooting

1. **Firebase not initialized**: Make sure you've added the `google-services.json` file to `android/app/` and run `flutter clean && flutter pub get`

2. **Permission denied**: Check your Firestore security rules and make sure they allow read/write access

3. **Build errors**: Make sure all dependencies are properly installed with `flutter pub get`

4. **View counts not updating**: Check the console for error messages and ensure your internet connection is working

## Production Considerations

1. **Security Rules**: Implement proper authentication and security rules for production
2. **Rate Limiting**: Consider implementing rate limiting to prevent abuse
3. **Data Cleanup**: Implement periodic cleanup of old view count data
4. **Analytics**: Consider adding analytics to track view count patterns

## Support

If you encounter any issues, check the [Firebase Documentation](https://firebase.google.com/docs) or [FlutterFire Documentation](https://firebase.flutter.dev/).
