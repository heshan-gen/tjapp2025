@echo off
REM Script to monitor release APK logs
echo ========================================
echo   RELEASE APK DEBUG MONITOR
echo ========================================
echo.
echo This will show live logs from your release APK
echo Press Ctrl+C to stop monitoring
echo.
echo ========================================
echo.

REM Clear logcat buffer for cleaner output
adb logcat -c

REM Monitor logs with filters for our app
adb logcat -v time ^
  flutter:V ^
  WorkManager:V ^
  WM-WorkerWrapper:V ^
  WM-SystemJobService:V ^
  WM-SystemAlarmDispatcher:V ^
  NotificationService:V ^
  FirebaseMessaging:V ^
  *:E

pause

