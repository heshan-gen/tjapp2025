# Release Build Notification Fix

## Problem
Notifications worked in **debug mode** (`flutter run`) but **NOT in release APK builds**.

## Root Cause
**Code Obfuscation/Minification** - Release builds use ProGuard/R8 to shrink and obfuscate code. This was breaking WorkManager callbacks because:
1. The callback dispatcher function gets renamed during obfuscation
2. WorkManager can't find the renamed callback function
3. Background tasks fail silently

## Solution Applied

### 1. Created ProGuard Rules File
**File:** `android/app/proguard-rules.pro`

This file contains "keep" rules that tell ProGuard/R8 to NOT obfuscate:
- WorkManager classes and callbacks
- Firebase Messaging classes
- Flutter engine and entry points
- Notification classes
- Kotlin classes
- Classes with `@pragma` annotations

### 2. Updated build.gradle
**File:** `android/app/build.gradle`

Added the following to the release build configuration:
```gradle
minifyEnabled true
shrinkResources true
proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
```

This enables code optimization while protecting critical classes.

## How to Build Release APK

### Clean and Rebuild
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Or build app bundle (for Play Store)
flutter build appbundle --release
```

### Install and Test
```bash
# Install the APK on your device
flutter install

# Or manually install
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Testing Checklist

After installing the release APK:

1. ✅ **Grant Permissions**
   - Open the app
   - Go to notification settings
   - Enable notifications for categories
   - Grant battery optimization exemption

2. ✅ **Test Notifications**
   - Subscribe to a job category
   - Wait 5 seconds for immediate check
   - Verify notification appears

3. ✅ **Test Background Execution**
   - Close the app completely (swipe away from recents)
   - Wait 15 minutes (WorkManager minimum interval)
   - Check if notifications still work

4. ✅ **Test After Reboot**
   - Reboot the device
   - Don't open the app
   - Wait 15 minutes
   - Verify notifications still work

## Why This Works

### Debug Build (flutter run)
- No code obfuscation
- All class names remain unchanged
- WorkManager finds callbacks easily

### Release Build (Before Fix)
- Code gets obfuscated
- Callback dispatcher renamed → WorkManager can't find it
- Background tasks fail

### Release Build (After Fix)
- Code gets obfuscated for optimization
- Critical classes protected by ProGuard rules
- WorkManager callbacks preserved and functional

## Important Notes

1. **WorkManager Minimum Interval**
   - Current setting: 5 minutes (line 47 in workmanager_background_service.dart)
   - **Android enforces 15-minute minimum** for periodic tasks
   - Immediate task runs after 5 seconds on first start

2. **Battery Optimization**
   - Users MUST disable battery optimization for the app
   - Otherwise, Android may kill background tasks
   - The app requests this permission automatically

3. **SimpleBackgroundService**
   - Checks every 10 seconds when app is running
   - Does NOT work when app is killed
   - Good for real-time updates when app is active

4. **WorkManager**
   - Checks every 15 minutes minimum (Android limitation)
   - Works even when app is completely closed
   - Best for battery-efficient background monitoring

## File Changes Made

1. ✅ Created `android/app/proguard-rules.pro` - ProGuard keep rules
2. ✅ Modified `android/app/build.gradle` - Added ProGuard configuration

## Build Outputs

After running `flutter build apk --release`, you'll find:
- **APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **Size:** Should be smaller due to code shrinking (~20-40% reduction)

## Troubleshooting

### If notifications still don't work:

1. **Check Logcat**
   ```bash
   adb logcat | grep -i "workmanager\|notification\|firebase"
   ```

2. **Verify ProGuard didn't break anything**
   ```bash
   # Check for ProGuard warnings during build
   flutter build apk --release -v
   ```

3. **Check Battery Settings**
   - Go to device Settings → Apps → topjobs
   - Battery → Unrestricted

4. **Check Notification Permissions**
   - Settings → Apps → topjobs → Notifications
   - Ensure "Job Alerts" channel is enabled

5. **Force Stop and Restart**
   - Force stop the app
   - Clear cache (don't clear data - it'll remove subscriptions)
   - Restart the app

## Next Steps

After successful testing, you can:
1. Upload to Google Play Console (use `flutter build appbundle --release`)
2. Distribute via other channels
3. Monitor crash reports for any ProGuard-related issues

---

**Fixed Date:** 2025-10-20
**Issue:** Release build notifications not working
**Resolution:** Added ProGuard keep rules for WorkManager and background services

