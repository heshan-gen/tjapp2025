# Notification Testing Guide

## ✅ Pre-requisites
- [ ] Device and laptop on same network (www.topjobs.lk accessible)
- [ ] Old app uninstalled
- [ ] New APK installed: `build\app\outputs\flutter-apk\app-release.apk`
- [ ] All permissions granted (Notifications, Battery optimization disabled)

## 🧪 Test Scenarios

### Test 1: App in Foreground (Open) 🟢

1. Open the app and keep it visible on screen
2. Send FCM test notification from Firebase Console:
   - Go to: https://console.firebase.google.com
   - Navigate to: Cloud Messaging → Send test message
   - Or send from backend/server
3. **Expected Result**: Notification appears in system tray
4. **Status**: ⬜ Pass / ⬜ Fail

**If it fails, check:**
- Open app logs via ADB: `adb logcat | grep -i "firebase\|notification"`
- Look for: "Local notification sent successfully"

---

### Test 2: App in Background 🟡

1. Open the app
2. Press **Home button** (don't swipe away, just minimize)
3. Send FCM test notification
4. **Expected Result**: Notification appears in system tray
5. Tap notification → App should open
6. **Status**: ⬜ Pass / ⬜ Fail

---

### Test 3: App Completely Closed 🔴 **CRITICAL TEST**

1. Open Recent Apps (square/multitasking button)
2. **Swipe away the app completely** to close it
3. Wait 5 seconds
4. Send FCM test notification
5. **Expected Result**: Notification appears in system tray even though app is closed
6. Tap notification → App should launch
7. **Status**: ⬜ Pass / ⬜ Fail

**If it fails:**
- This was the main issue we fixed
- Check Firebase initialization in background handler
- Check ADB logs: `adb logcat | grep "Handling background message"`

---

### Test 4: Background Job Checking (RSS Feed Notifications) 🔄

1. Open the app
2. Go to notification settings
3. Subscribe to at least one job category
4. Close the app completely
5. Wait 5 minutes (WorkManager runs every 5 mins)
6. **Expected Result**: If new jobs are found, notification appears
7. **Status**: ⬜ Pass / ⬜ Fail

**Note:** This requires:
- Device connected to same network as www.topjobs.lk
- Battery optimization disabled
- App has background data enabled

---

## 📊 Send Test Notification (Firebase Console)

### Method 1: Firebase Console UI
1. Go to: https://console.firebase.google.com
2. Select your project
3. Click "Cloud Messaging" in left menu
4. Click "Send your first message" or "New campaign"
5. Enter:
   - **Title**: "Test Notification"
   - **Body**: "Testing app closed state"
6. Click "Send test message"
7. Enter your FCM token (get from app)
8. Click "Test"

### Method 2: Get FCM Token from App
Add this code temporarily to see the token:

```dart
// In home screen or any screen initState
final token = await NotificationService().getFCMToken();
print('========================================');
print('FCM TOKEN: $token');
print('========================================');
```

Then check logs:
```bash
adb logcat | grep "FCM TOKEN"
```

---

## 🔍 Debugging Commands

### Check if app is running in background:
```bash
adb shell ps | grep lk.topjobs.app
```

### Monitor live logs:
```bash
adb logcat -s flutter
```

### Filter notification logs:
```bash
adb logcat | grep -i "notification\|firebase\|background message"
```

### Check Firebase initialization:
```bash
adb logcat | grep -i "firebase.initializeapp"
```

### Check WorkManager tasks:
```bash
adb logcat | grep -i "workmanager\|jobCheckTask"
```

---

## ⚠️ Common Issues

### Issue 1: No notifications when app is closed
**Cause**: Background handler not initialized properly
**Solution**: Already fixed - Firebase now initializes with proper options

### Issue 2: Battery optimization blocking background tasks
**Check**:
```
Settings → Apps → topjobs → Battery → Unrestricted
```

### Issue 3: Notifications disabled
**Check**:
```
Settings → Apps → topjobs → Notifications → Enable all
```

### Issue 4: No network access
**Check**:
```
Settings → Apps → topjobs → Data usage → Background data: ON
```

### Issue 5: Can't reach www.topjobs.lk
**Test**: Open browser on device, go to `http://www.topjobs.lk`
**Should**: See your server page

---

## ✅ Success Criteria

For the release to be working properly:

- [x] **Fixed**: Firebase initialization in background handler (Added `DefaultFirebaseOptions.currentPlatform`)
- [ ] **Test**: Notifications appear when app is open ✅
- [ ] **Test**: Notifications appear when app is in background ✅
- [ ] **Test**: Notifications appear when app is CLOSED ✅ ← **Most Important**
- [ ] **Test**: Tapping notification opens the app ✅
- [ ] **Test**: Background job checking works (if subscribed to categories) ✅

---

## 📝 Results Log

**Date**: _______________
**APK Version**: 33.3
**Build**: Release

| Test | Status | Notes |
|------|--------|-------|
| Foreground | ⬜ | |
| Background | ⬜ | |
| Closed | ⬜ | |
| Job Checking | ⬜ | |

**Overall**: ⬜ All Pass / ⬜ Some Fail

---

## 🚀 Next Steps After Testing

If all tests pass:
- ✅ Ready for production
- Upload APK to Play Store or distribute

If Test 3 (Closed) fails:
- Check ADB logs
- Verify Firebase configuration
- Share error logs for debugging

