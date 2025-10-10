// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

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

class _BottomNavigationWidgetState extends State<BottomNavigationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(final int index) {
    if (index != widget.currentIndex) {
      widget.onTap(index);
      _animationController.forward().then((final _) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (final context, final child) {
                  return Transform.scale(
                    scale:
                        widget.currentIndex == 0 ? _scaleAnimation.value : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.currentIndex == 0
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.currentIndex == 0
                            ? Icons.home
                            : Icons.home_outlined,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (final context, final child) {
                  return Transform.scale(
                    scale:
                        widget.currentIndex == 1 ? _scaleAnimation.value : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.currentIndex == 1
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.currentIndex == 1
                            ? Icons.work
                            : Icons.work_outline,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              label: 'All Jobs',
            ),
            BottomNavigationBarItem(
              icon: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (final context, final child) {
                  return Transform.scale(
                    scale:
                        widget.currentIndex == 2 ? _scaleAnimation.value : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.currentIndex == 2
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.currentIndex == 2
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }
}
