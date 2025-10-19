// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/battery_optimization_service.dart';
import '../providers/theme_provider.dart';

class BackgroundNotificationSettingsScreen extends StatefulWidget {
  const BackgroundNotificationSettingsScreen({super.key});

  @override
  State<BackgroundNotificationSettingsScreen> createState() =>
      _BackgroundNotificationSettingsScreenState();
}

class _BackgroundNotificationSettingsScreenState
    extends State<BackgroundNotificationSettingsScreen> {
  Map<String, bool> _notificationStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  Future<void> _loadNotificationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await BatteryOptimizationService.getNotificationStatus();
      setState(() {
        _notificationStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading notification status: $e');
    }
  }

  Future<void> _requestAllPermissions() async {
    try {
      await BatteryOptimizationService.requestAllPermissions();
      await _loadNotificationStatus();
      _showSuccessSnackBar('Permissions requested successfully');
    } catch (e) {
      _showErrorSnackBar('Error requesting permissions: $e');
    }
  }

  Future<void> _openBatteryOptimizationSettings() async {
    try {
      await BatteryOptimizationService.openBatteryOptimizationSettings();
      // Show a message to guide the user
      _showSuccessSnackBar(
          'Opening battery settings... If it doesn\'t open, please go to Settings > Apps > topjobs > Battery');
    } catch (e) {
      _showErrorSnackBar('Error opening battery settings: $e');
      // Provide manual instructions as fallback
      _showManualInstructions();
    }
  }

  void _showManualInstructions() {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Manual Setup Required'),
          content: const Text(
            'Please follow these steps manually:\n\n'
            '1. Go to Settings\n'
            '2. Find "Apps" or "Application Manager"\n'
            '3. Find "topjobs" in the list\n'
            '4. Tap on "Battery" or "Battery optimization"\n'
            '5. Select "Don\'t optimize" or "Allow background activity"\n\n'
            'This will ensure the app can send notifications in the background.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAutoStartSettings() async {
    try {
      await BatteryOptimizationService.openAutoStartSettings();
    } catch (e) {
      _showErrorSnackBar('Error opening auto-start settings: $e');
    }
  }

  void _showSuccessSnackBar(final String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(final String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Background Notifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<ThemeProvider>(
            builder: (final context, final themeProvider, final child) {
              return IconButton(
                icon: Icon(themeProvider.themeIcon),
                tooltip: themeProvider.themeTooltip,
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  _buildPermissionCard(),
                  const SizedBox(height: 20),
                  _buildInstructionsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              'Battery Optimization',
              _notificationStatus['batteryOptimizationDisabled'] ?? false,
              'Disabled (Required for background notifications)',
            ),
            _buildStatusItem(
              'Auto-Start',
              _notificationStatus['autoStartEnabled'] ?? false,
              'Enabled (Required for app restart)',
            ),
            _buildStatusItem(
              'Notifications',
              _notificationStatus['notificationsEnabled'] ?? false,
              'Enabled (Required for job alerts)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
      final String title, final bool isEnabled, final String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Setup',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _requestAllPermissions,
                icon: const Icon(Icons.security),
                label: const Text('Request All Permissions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.green.withOpacity(0.8)
                          : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openBatteryOptimizationSettings,
                icon: Theme.of(context).brightness == Brightness.dark
                    ? const Icon(
                        Icons.battery_charging_full,
                        color: Colors.white,
                      )
                    : const Icon(Icons.battery_charging_full),
                label: Text(
                  'Open Battery Settings',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color.fromARGB(255, 161, 13, 3),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openAutoStartSettings,
                icon: Theme.of(context).brightness == Brightness.dark
                    ? const Icon(
                        Icons.restart_alt,
                        color: Colors.white,
                      )
                    : const Icon(Icons.restart_alt),
                label: Text(
                  'Open Auto-Start Settings',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color.fromARGB(255, 161, 13, 3),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Setup Instructions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              '1',
              'Battery Optimization',
              'Go to Settings > Apps > topjobs > Battery > Don\'t optimize',
            ),
            _buildInstructionStep(
              '2',
              'Auto-Start (Device Specific)',
              'Enable auto-start for topjobs in your device\'s app management settings',
            ),
            _buildInstructionStep(
              '3',
              'Notifications',
              'Ensure notifications are enabled for topjobs in app settings',
            ),
            _buildInstructionStep(
              '4',
              'Test',
              'Close the app completely and wait 5 minutes to test background notifications',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
      final String number, final String title, final String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
