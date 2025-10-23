// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
// import 'screens/job_list_screen.dart';
// import 'screens/applied_jobs_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/contact_us_screen.dart';
import 'providers/job_provider.dart';
import 'providers/banner_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
// import 'providers/notification_provider.dart';
// import 'services/notification_service.dart';
// import 'services/workmanager_background_service.dart';
// import 'services/battery_optimization_service.dart';
// import 'screens/background_notification_settings_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_navigation_widget.dart';

void main() async {
  print('🚀 ===== APP STARTING ===== 🚀');
  WidgetsFlutterBinding.ensureInitialized();

  print('📱 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase initialized');

  // // Register background message handler BEFORE initializing notification service
  // // This is critical for handling notifications when app is closed
  // print('📬 Registering Firebase background message handler...');
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // print('✅ Background message handler registered');

  // // Initialize notification service for background notifications
  // print('🔔 Initializing notification service...');
  // await NotificationService().initialize();
  // print('✅ Notification service initialized');

  // // Initialize WorkManager for background job checking
  // print('⚙️ Initializing WorkManager...');
  // await WorkManagerBackgroundService.initialize();
  // print('✅ WorkManager initialized');

  // print('🎯 Starting background task...');
  // await WorkManagerBackgroundService.startBackgroundTask();
  // print('✅ Background task started');

  // // Request battery optimization permissions
  // print('🔋 Requesting battery optimization permissions...');
  // await BatteryOptimizationService.requestAllPermissions();
  // print('✅ Battery permissions requested');

  print('🏁 ===== APP INITIALIZATION COMPLETE ===== 🏁');
  runApp(const TopJobsApp());
}

class TopJobsApp extends StatelessWidget {
  const TopJobsApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (final _) {
            final jobProvider = JobProvider();
            // Initialize favorites from device storage
            // Note: This is async but we can't await here, so favorites will be loaded
            // when loadJobs() is called in the screens
            jobProvider.initializeFavorites();
            return jobProvider;
          },
        ),
        ChangeNotifierProvider(create: (final _) => BannerProvider()),
        ChangeNotifierProvider(create: (final _) => ThemeProvider()),
        ChangeNotifierProvider(create: (final _) => LanguageProvider()),
        // ChangeNotifierProvider(
        //   create: (final _) {
        //     final notificationProvider = NotificationProvider();
        //     // Initialize notification provider
        //     notificationProvider.initialize();
        //     return notificationProvider;
        //   },
        // ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (final context, final themeProvider, final child) {
          return MaterialApp(
            title: 'topjobs',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigationScreen(),
            routes: {
              '/home': (final context) => const HomeScreen(),
              // '/jobs': (final context) => const JobListScreen(),
              // '/applied': (final context) => const AppliedJobsScreen(),
              '/favorites': (final context) => const FavoritesScreen(),
              '/contact': (final context) => const ContactUsScreen(),
              // '/background-settings': (final context) =>
              //     const BackgroundNotificationSettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    // const JobListScreen(),
    // const AppliedJobsScreen(),
    const FavoritesScreen(),
    const ContactUsScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onTabTapped(final int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1),
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
