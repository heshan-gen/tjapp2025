// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart'
    show LoadingAnimationWidget;

class ModernLoadingModal extends StatefulWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool isSmall;
  final bool showBackground;
  final String? subtitle;

  const ModernLoadingModal({
    super.key,
    this.message,
    this.size,
    this.color,
    this.isSmall = false,
    this.showBackground = true,
    this.subtitle,
  });

  @override
  State<ModernLoadingModal> createState() => _ModernLoadingModalState();
}

class _ModernLoadingModalState extends State<ModernLoadingModal>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final loadingColor =
        widget.color ?? (isDark ? Colors.white : theme.primaryColor);
    final loadingSize = widget.size ?? (widget.isSmall ? 20.0 : 60.0);

    if (widget.isSmall) {
      return _buildSmallLoader(loadingColor, loadingSize);
    }

    return _buildFullModal(context, theme, isDark, loadingColor, loadingSize);
  }

  Widget _buildSmallLoader(final Color loadingColor, final double loadingSize) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (final context, final child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: loadingSize,
            height: loadingSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  loadingColor.withOpacity(0.2),
                  loadingColor.withOpacity(0.6),
                  loadingColor,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: Center(
              child: AnimatedIcon(
                icon: AnimatedIcons.search_ellipsis,
                progress: _rotationAnimation,
                size: loadingSize * 0.4,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullModal(final BuildContext context, final ThemeData theme,
      final bool isDark, final Color loadingColor, final double loadingSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: widget.showBackground
            ? (isDark
                ? const Color.fromARGB(255, 19, 19, 19)
                : Colors.white.withOpacity(0.9))
            : Colors.transparent,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: loadingColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern loading indicator with multiple layers
                _buildModernLoader(loadingColor, loadingSize, isDark),

                const SizedBox(height: 24),

                // Message with modern typography
                if (widget.message != null) ...[
                  Text(
                    widget.message!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                ],

                // Animated progress bar
                _buildProgressBar(loadingColor, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernLoader(
      final Color loadingColor, final double loadingSize, final bool isDark) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (final context, final child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main loading indicator with custom animated job icon
              SizedBox(
                width: loadingSize,
                height: loadingSize,
                child: Center(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: LoadingAnimationWidget.fourRotatingDots(
                      size: 50,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFF0BE28)
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),

              // Inner pulsing dot
              // AnimatedBuilder(
              //   animation: _pulseController,
              //   builder: (final context, final child) {
              //     return Transform.scale(
              //       scale: 0.5 + (_pulseAnimation.value - 0.8) * 0.5,
              //       child: Container(
              //         width: 8,
              //         height: 8,
              //         decoration: BoxDecoration(
              //           color: loadingColor,
              //           shape: BoxShape.circle,
              //           boxShadow: [
              //             BoxShadow(
              //               color: loadingColor.withOpacity(0.6),
              //               blurRadius: 8,
              //               spreadRadius: 2,
              //             ),
              //           ],
              //         ),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(final Color loadingColor, final bool isDark) {
    return Container(
      width: 120,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: isDark ? Colors.grey[800] : Colors.grey[200],
      ),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (final context, final child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.3 + (_pulseAnimation.value - 0.8) * 0.4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    loadingColor.withOpacity(0.6),
                    loadingColor,
                    loadingColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Convenience widget for full-screen loading
class ModernLoadingOverlay extends StatelessWidget {
  final String? message;
  final String? subtitle;
  final Color? color;
  final bool showBackground;

  const ModernLoadingOverlay({
    super.key,
    this.message,
    this.subtitle,
    this.color,
    this.showBackground = true,
  });

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModernLoadingModal(
        message: message,
        subtitle: subtitle,
        color: color,
        showBackground: showBackground,
      ),
    );
  }
}

// Small inline loading widget
class ModernLoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;

  const ModernLoadingIndicator({
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(final BuildContext context) {
    return ModernLoadingModal(
      size: size,
      color: color,
      isSmall: true,
      showBackground: false,
    );
  }
}

// Specialized job loading modal with enhanced UX
class JobLoadingModal extends StatelessWidget {
  final String? category;
  final Color? color;
  final bool showBackground;

  const JobLoadingModal({
    super.key,
    this.category,
    this.color,
    this.showBackground = true,
  });

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ModernLoadingModal(
      message: category != null
          ? 'Fetching $category vacancies...'
          : 'Fetching the latest vacancies...',
      subtitle:
          '\nPlease wait while we fetch the latest opportunities \n\nApplication loading time depends on your Device & Network performance',
      color: color ?? (isDark ? Colors.white : theme.primaryColor),
      showBackground: showBackground,
      size: 70,
    );
  }
}

// Custom painter for animated job list downloading icon
class JobListDownloadPainter extends CustomPainter {
  final double progress;
  final Color color;

  JobListDownloadPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw job list document outline
    final documentRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.4,
        height: size.height * 0.5,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(documentRect, paint);

    // Draw job list lines
    final lineSpacing = size.height * 0.08;
    for (int i = 0; i < 3; i++) {
      final lineY = center.dy - size.height * 0.15 + (i * lineSpacing);
      final lineStart = Offset(center.dx - size.width * 0.15, lineY);
      final lineEnd = Offset(center.dx + size.width * 0.15, lineY);
      canvas.drawLine(lineStart, lineEnd, paint);
    }

    // Draw download arrow with animation
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final arrowCenter = Offset(center.dx, center.dy + size.height * 0.25);
    final arrowSize = size.width * 0.08;

    // Animate arrow movement
    final animatedY = arrowCenter.dy + (progress * 10 - 5);

    // Draw arrow pointing down
    final path = Path();
    path.moveTo(arrowCenter.dx, animatedY - arrowSize);
    path.lineTo(arrowCenter.dx - arrowSize * 0.7, animatedY);
    path.lineTo(arrowCenter.dx + arrowSize * 0.7, animatedY);
    path.close();

    canvas.drawPath(path, arrowPaint);

    // Draw animated dots around the document
    final dotPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45.0 + progress * 360.0) * (3.14159 / 180.0);
      final dotRadius = radius * 0.8;
      final dotX = center.dx + cos(angle) * dotRadius;
      final dotY = center.dy + sin(angle) * dotRadius;

      // Animate dot opacity
      final dotOpacity = (sin(progress * 2 * 3.14159 + i * 0.5) + 1) / 2;
      dotPaint.color = color.withOpacity(dotOpacity * 0.4);

      canvas.drawCircle(Offset(dotX, dotY), 2.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(final JobListDownloadPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
