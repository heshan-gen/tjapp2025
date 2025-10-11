// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/job_list_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/contact_us_screen.dart';
import 'providers/job_provider.dart';
import 'providers/banner_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_navigation_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
            jobProvider.initializeFavorites();
            return jobProvider;
          },
        ),
        ChangeNotifierProvider(create: (final _) => BannerProvider()),
        ChangeNotifierProvider(create: (final _) => ThemeProvider()),
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
              '/jobs': (final context) => const JobListScreen(),
              '/favorites': (final context) => const FavoritesScreen(),
              '/contact': (final context) => const ContactUsScreen(),
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
    const JobListScreen(),
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
