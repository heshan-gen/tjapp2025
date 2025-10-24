// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class LoadingBarWidget extends StatefulWidget {
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final Duration animationDuration;
  final String? loadingText;

  const LoadingBarWidget({
    super.key,
    this.width,
    this.height = 4.0,
    this.backgroundColor,
    this.progressColor,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.loadingText,
  });

  @override
  State<LoadingBarWidget> createState() => _LoadingBarWidgetState();
}

class _LoadingBarWidgetState extends State<LoadingBarWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors based on theme
    final backgroundColor = widget.backgroundColor ??
        (isDark ? Colors.grey[800] : Colors.grey[300]);
    final progressColor = widget.progressColor ??
        (isDark ? const Color(0xFFF0BE28) : theme.primaryColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.loadingText != null) ...[
          Text(
            widget.loadingText!,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: widget.width ?? MediaQuery.of(context).size.width * 0.6,
          height: widget.height,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (final context, final child) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                ),
                child: Stack(
                  children: [
                    // Background
                    Container(
                      width: double.infinity,
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    ),
                    // Animated progress bar
                    Container(
                      width: (widget.width ??
                              MediaQuery.of(context).size.width * 0.6) *
                          (0.3 + 0.4 * _animation.value),
                      height: widget.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor.withOpacity(0.3),
                            progressColor,
                            progressColor.withOpacity(0.3),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: progressColor.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Alternative loading bar with dots animation
class LoadingDotsWidget extends StatefulWidget {
  final Color? dotColor;
  final double dotSize;
  final Duration animationDuration;
  final String? loadingText;

  const LoadingDotsWidget({
    super.key,
    this.dotColor,
    this.dotSize = 8.0,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.loadingText,
  });

  @override
  State<LoadingDotsWidget> createState() => _LoadingDotsWidgetState();
}

class _LoadingDotsWidgetState extends State<LoadingDotsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animations = List.generate(3, (final index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.2,
          (index * 0.2) + 0.6,
          curve: Curves.easeInOut,
        ),
      ));
    });

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dotColor = widget.dotColor ??
        (isDark ? const Color(0xFFF0BE28) : theme.primaryColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.loadingText != null) ...[
          Text(
            widget.loadingText!,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (final index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (final context, final child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: dotColor
                          .withOpacity(0.3 + 0.7 * _animations[index].value),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: dotColor
                              .withOpacity(0.3 * _animations[index].value),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
