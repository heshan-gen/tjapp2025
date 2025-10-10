import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/banner.dart' as banner_model;

class BannerSlider extends StatefulWidget {
  final List<banner_model.Banner> banners;
  final double height;
  final double borderRadius;
  final int? jobCount;

  const BannerSlider({
    super.key,
    required this.banners,
    this.height = 170.0,
    this.borderRadius = 10.0,
    this.jobCount,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.banners.length > 1) {
      _startAutoSlide();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (final timer) {
      if (mounted && widget.banners.length > 1) {
        _currentIndex = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(final int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _onBannerTap(final banner_model.Banner banner) async {
    if (banner.link.isNotEmpty) {
      try {
        print('Attempting to launch URL: ${banner.link}');
        final Uri url = Uri.parse(banner.link);

        if (await canLaunchUrl(url)) {
          print('URL can be launched, launching...');
          final bool launched = await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );

          if (launched) {
            print('URL launched successfully');
          } else {
            print('Failed to launch URL');
          }
        } else {
          print('Cannot launch URL: ${banner.link}');
        }
      } catch (e) {
        print('Error launching URL: $e');
      }
    } else {
      print('Banner link is empty');
    }
  }

  @override
  Widget build(final BuildContext context) {
    // Always show welcome banner, even when no banners are available
    final List<Widget> bannerItems = [];

    // Add welcome banner as first item
    bannerItems.add(_buildWelcomeBanner(context));

    // Add regular banners if available
    for (final banner in widget.banners) {
      bannerItems.add(_buildRegularBanner(banner));
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: bannerItems.length,
            itemBuilder: (final context, final index) {
              return bannerItems[index];
            },
          ),
        ),
        if (bannerItems.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              bannerItems.length,
              (final index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWelcomeBanner(final BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            // ignore: deprecated_member_use
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to topjobs!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find your dream job today',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          if (widget.jobCount != null && widget.jobCount! > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFFF0BE28).withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${widget.jobCount} jobs available',
                style: const TextStyle(
                  color: Color(0xFF892621),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegularBanner(final banner_model.Banner banner) {
    return GestureDetector(
      onTap: () => _onBannerTap(banner),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image.network(
            banner.image,
            fit: BoxFit.fitWidth,
            width: double.infinity,
            errorBuilder: (final context, final error, final stackTrace) {
              return Container(
                color: Colors.white,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
