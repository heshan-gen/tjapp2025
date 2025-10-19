import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

class BatteryOptimizationService {
  static Future<bool> isBatteryOptimizationDisabled() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      // For Android 6.0+ (API 23+), check if battery optimization is disabled
      if (androidInfo.version.sdkInt >= 23) {
        return await Permission.ignoreBatteryOptimizations.isGranted;
      }
      return true; // For older Android versions, assume it's not restricted
    } catch (e) {
      print('Error checking battery optimization: $e');
      return false;
    }
  }

  static Future<bool> requestBatteryOptimizationDisable() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      // For Android 6.0+ (API 23+), request to disable battery optimization
      if (androidInfo.version.sdkInt >= 23) {
        final status = await Permission.ignoreBatteryOptimizations.request();
        return status.isGranted;
      }
      return true; // For older Android versions, no need to request
    } catch (e) {
      print('Error requesting battery optimization disable: $e');
      return false;
    }
  }

  static Future<void> openBatteryOptimizationSettings() async {
    try {
      // Try multiple battery optimization intents
      final List<AndroidIntent> intents = [
        // Primary intent for battery optimization
        const AndroidIntent(
          action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
          data: 'package:topjobs',
        ),
        // Alternative battery optimization intent
        const AndroidIntent(
          action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
        ),
        // App-specific battery settings
        const AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:topjobs',
        ),
        // General battery settings
        const AndroidIntent(
          action: 'android.settings.BATTERY_SAVER_SETTINGS',
        ),
        // General settings as last resort
        const AndroidIntent(
          action: 'android.settings.SETTINGS',
        ),
      ];

      bool launched = false;
      String lastError = '';

      for (final intent in intents) {
        try {
          print('Attempting to launch intent: ${intent.action}');
          await intent.launch();
          launched = true;
          print('Successfully launched: ${intent.action}');
          break;
        } catch (e) {
          lastError = e.toString();
          print('Failed to launch battery intent: ${intent.action} - $e');
          continue;
        }
      }

      if (!launched) {
        print('All battery intents failed. Last error: $lastError');
        throw Exception(
            'Unable to open battery settings. Last error: $lastError');
      }
    } catch (e) {
      print('Error opening battery optimization settings: $e');
      rethrow; // Re-throw to let the UI handle the error
    }
  }

  static Future<bool> isAutoStartEnabled() async {
    try {
      // This is device-specific and may not work on all devices
      // Some manufacturers have their own auto-start management
      return true; // Assume enabled for now
    } catch (e) {
      print('Error checking auto-start: $e');
      return false;
    }
  }

  static Future<void> openAutoStartSettings() async {
    try {
      // Try to open auto-start settings (varies by manufacturer)
      final List<AndroidIntent> intents = [
        // Xiaomi MIUI
        const AndroidIntent(
          action: 'miui.intent.action.APP_PERM',
          data: 'package:topjobs',
        ),
        // Xiaomi Auto-start
        const AndroidIntent(
          action: 'miui.intent.action.OP_AUTO_START',
          data: 'package:topjobs',
        ),
        // Huawei EMUI
        const AndroidIntent(
          action: 'com.huawei.systemmanager.startupmgr.StartupMgrActivity',
        ),
        // Samsung
        const AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:topjobs',
        ),
        // OnePlus
        const AndroidIntent(
          action:
              'com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity',
        ),
        // Vivo
        const AndroidIntent(
          action: 'com.iqoo.secure.MainActivity',
        ),
        // Oppo
        const AndroidIntent(
          action:
              'com.coloros.safecenter.permission.startup.StartupAppListActivity',
        ),
        // General Android
        const AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:topjobs',
        ),
      ];

      bool launched = false;
      for (final intent in intents) {
        try {
          await intent.launch();
          launched = true;
          break;
        } catch (e) {
          print('Failed to launch intent: ${intent.action} - $e');
          continue;
        }
      }

      if (!launched) {
        print('All auto-start intents failed, opening general app settings');
        // Final fallback to general app settings
        const AndroidIntent fallbackIntent = AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:topjobs',
        );
        await fallbackIntent.launch();
      }
    } catch (e) {
      print('Error opening auto-start settings: $e');
    }
  }

  static Future<Map<String, bool>> getNotificationStatus() async {
    try {
      final Map<String, bool> status = {
        'batteryOptimizationDisabled': await isBatteryOptimizationDisabled(),
        'autoStartEnabled': await isAutoStartEnabled(),
        'notificationsEnabled': await Permission.notification.isGranted,
      };
      return status;
    } catch (e) {
      print('Error getting notification status: $e');
      return {
        'batteryOptimizationDisabled': false,
        'autoStartEnabled': false,
        'notificationsEnabled': false,
      };
    }
  }

  static Future<void> requestAllPermissions() async {
    try {
      // Request notification permission
      await Permission.notification.request();

      // Request battery optimization disable
      await requestBatteryOptimizationDisable();

      // Request other necessary permissions
      await Permission.ignoreBatteryOptimizations.request();
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }
}
