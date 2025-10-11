// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class BottomNavigationWidget extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  void _onTabTapped(final int index) {
    if (index != widget.currentIndex) {
      widget.onTap(index);
    }
  }

  @override
  Widget build(final BuildContext context) {
    return ConvexAppBar(
      initialActiveIndex: widget.currentIndex,
      onTap: _onTabTapped,
      style: TabStyle.reactCircle,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      activeColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Theme.of(context).primaryColor,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      curve: Curves.easeInOut,
      height: 60,
      items: const [
        TabItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          title: 'Home',
        ),
        TabItem(
          icon: Icons.work_outline,
          activeIcon: Icons.work,
          title: 'All Jobs',
        ),
        TabItem(
          icon: Icons.favorite_border,
          activeIcon: Icons.favorite,
          title: 'Favorites',
        ),
        TabItem(
          icon: Icons.phone_forwarded_sharp,
          activeIcon: Icons.phone_forwarded_outlined,
          title: 'Contact',
        ),
      ],
    );
  }
}
