# How to Debug Your Release APK

## The Problem
Your notifications work in debug mode (`flutter run`) but NOT in the installed release APK.

## What I Changed

### 1. **Added Extensive Logging** 🔍
- WorkManager initialization logs with emojis
- Background task execution logs
- Job checking detailed logs
- Error logs with stack traces

### 2. **Enhanced ProGuard Rules** 🛡️
- More aggressive keep rules for WorkManager
- Protected callback dispatcher
- Protected all Flutter background isolates

### 3. **Fixed WorkManager Interval** ⏰
- Changed from 5 minutes to **15 minutes** (Android minimum)
- Immediate check still runs after 5 seconds

## How to Monitor Release APK Logs

### **Option 1: Use the Debug Script (Windows)**
```bash
debug_release_apk.bat
```

### **Option 2: Use the Debug Script (Mac/Linux)**
```bash
chmod +x debug_release_apk.sh
./debug_release_apk.sh
```

### **Option 3: Manual ADB Command**
```bash
adb logcat -v time flutter:V WorkManager:V WM-*:V *:E
```

## Step-by-Step Testing Process

### Step 1: Clean Build
```bash
flutter clean
flutter pub get
```

### Step 2: Build Release APK
```bash
flutter build apk --release
```

### Step 3: Install on Device
```bash
# Uninstall old version first (IMPORTANT!)
adb uninstall lk.topjobs.app

# Install new APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Step 4: Start Monitoring Logs
**Before opening the app**, start the log monitor:
```bash
debug_release_apk.bat   # Windows
# OR
./debug_release_apk.sh  # Mac/Linux
```

### Step 5: Open App and Watch Logs

You should see these logs when the app starts:
```
🚀 ===== APP STARTING ===== 🚀
📱 Initializing Firebase...
✅ Firebase initialized
📬 Registering Firebase background message handler...
✅ Background message handler registered
🔔 Initializing notification service...
🚀 WorkManagerBackgroundService.initialize() called
✅ WorkManager initialized successfully
✅ Notification service initialized
⚙️ Initializing WorkManager...
✅ WorkManager initialized
🎯 Starting background task...
🔄 Starting background task registration...
✅ Cancelled existing tasks
✅ Registered immediate one-off task (5 seconds delay)
✅ Registered periodic task (every 15 minutes, starts in 1 minute)
📝 Background task registration completed successfully
✅ Background task started
🏁 ===== APP INITIALIZATION COMPLETE ===== 🏁
```

### Step 6: Subscribe to Job Categories

In the app:
1. Go to notification settings
2. Subscribe to at least one job category
3. Watch the logs for confirmation

### Step 7: Wait for Background Task (5 seconds)

After subscribing, within 5 seconds you should see:
```
🎯 ===== CALLBACK DISPATCHER CALLED ===== 🎯
⏰ WorkManager task started at: [timestamp]
📋 Task name: jobCheckTask_immediate
✅ Task matches our job check tasks, executing...
🔍 ===== CHECKING FOR NEW JOBS ===== 🔍
📱 Subscribed categories: 1
📝 Categories: [category_id]
🌐 Fetching jobs from 1 categories...
📊 Current jobs: X
📚 Known jobs: 0
🎉 Found X new jobs!
📬 Sending notification for: [job title]
✅ Updated known job IDs
✅ Background check completed
🏁 ===== CHECK FINISHED ===== 🏁
```

### Step 8: Test When App is Closed

1. **Close the app** (swipe away from recent apps)
2. **Keep the log monitor running**
3. Wait 15 minutes
4. You should see the background task execute again

### Step 9: Test After Device Reboot

1. Reboot your device
2. **Don't open the app**
3. Start log monitor
4. Wait 15 minutes
5. Check if background task runs

## What to Look For in Logs

### ✅ **Good Signs:**
```
✅ WorkManager initialized successfully
✅ Registered immediate one-off task
✅ Registered periodic task
🎯 ===== CALLBACK DISPATCHER CALLED ===== 🎯
🎉 Found X new jobs!
📬 Sending notification for: [job]
```

### ❌ **Bad Signs:**
```
❌ WorkManager initialization failed
❌ Failed to register background tasks
❌ Task execution failed
⚠️ Unknown task
❌ Background service error
```

## Common Issues and Solutions

### Issue 1: No Callback Dispatcher Logs
**Problem:** WorkManager not calling the callback  
**Solution:**
- Check if ProGuard rules are applied correctly
- Rebuild with `flutter clean` first
- Check battery optimization is disabled

### Issue 2: "No categories subscribed"
**Problem:** Subscriptions not saved  
**Solution:**
- Subscribe to categories in the app
- Check SharedPreferences permissions

### Issue 3: "Too soon since last check"
**Problem:** Rate limiting working correctly  
**Solution:** This is normal, wait for the next interval

### Issue 4: No notifications shown
**Problem:** Notifications might be disabled  
**Solution:**
- Check Settings → Apps → topjobs → Notifications
- Ensure "Job Alerts" channel is enabled
- Check battery optimization is disabled

### Issue 5: Background task stops after app is closed
**Problem:** Battery optimization killing the app  
**Solution:**
1. Go to Settings → Apps → topjobs
2. Battery → Unrestricted
3. Or disable battery optimization when prompted

## LogCat Filters Explained

| Filter | What it Shows |
|--------|---------------|
| `flutter:V` | All Flutter/Dart logs (includes our print statements) |
| `WorkManager:V` | WorkManager library logs |
| `WM-WorkerWrapper:V` | Worker execution logs |
| `WM-SystemJobService:V` | System job scheduling logs |
| `WM-SystemAlarmDispatcher:V` | Alarm dispatcher logs |
| `*:E` | All error logs from all apps |

## Quick Debug Commands

### Check if APK is installed:
```bash
adb shell pm list packages | grep topjobs
```

### Check app permissions:
```bash
adb shell dumpsys package lk.topjobs.app | grep permission
```

### Check WorkManager tasks:
```bash
adb shell dumpsys jobscheduler | grep topjobs
```

### Force WorkManager to run immediately:
```bash
adb shell cmd jobscheduler run -f lk.topjobs.app
```

### Clear app data (resets subscriptions):
```bash
adb shell pm clear lk.topjobs.app
```

### View notification settings:
```bash
adb shell dumpsys notification | grep topjobs
```

## Expected Behavior

### First Launch:
1. App initializes all services ✅
2. WorkManager registers tasks ✅
3. User subscribes to categories ✅
4. First check runs after 5 seconds ✅
5. Shows notifications for all jobs (they're all "new") ✅

### After First Check:
1. Periodic task runs every 15 minutes ✅
2. Only shows notifications for NEW jobs ✅
3. Continues even when app is closed ✅

### After Reboot:
1. Android reschedules WorkManager tasks ✅
2. Tasks resume after 15 minutes ✅
3. No need to open app ✅

## Build Information

- **Release APK Path:** `build/app/outputs/flutter-apk/app-release.apk`
- **Package Name:** `lk.topjobs.app`
- **Min SDK:** 21 (Android 5.0)
- **Target SDK:** 33 (Android 13)

## Next Steps After Successful Testing

1. ✅ Verify notifications work in release APK
2. ✅ Test background execution when app is closed
3. ✅ Test after device reboot
4. Upload to Google Play Console:
   ```bash
   flutter build appbundle --release
   ```
5. App bundle will be at: `build/app/outputs/bundle/release/app-release.aab`

---

**Remember:** Release builds behave differently than debug builds. Always test release APKs before publishing!

