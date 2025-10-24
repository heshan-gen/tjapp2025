// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../models/banner.dart' as banner_model;

class BannerSlider extends StatefulWidget {
  final List<banner_model.Banner> banners;
  final double height;
  final double borderRadius;
  // final int? jobCount;

  const BannerSlider({
    super.key,
    required this.banners,
    this.height = 170.0,
    this.borderRadius = 10.0,
    // this.jobCount,
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
          curve: Curves.bounceOut,
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
    // If no banners, return empty container with 0 height
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    // Build banner items from available banners
    final List<Widget> bannerItems = [];

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
        // if (bannerItems.length > 1) ...[
        //   const SizedBox(height: 8),
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: List.generate(
        //       bannerItems.length,
        //       (final index) => Container(
        //         margin: const EdgeInsets.symmetric(horizontal: 2),
        //         width: 5,
        //         height: 5,
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           color: _currentIndex == index
        //               ? Theme.of(context).primaryColor
        //               : Colors.grey[300],
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ],
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
          child: CachedNetworkImage(
            imageUrl: banner.image,
            fit: BoxFit.fitWidth,
            width: double.infinity,
            placeholder: (final context, final url) => Container(
              color: Colors.grey[200],
              child: Center(
                child: LoadingAnimationWidget.beat(
                  color: Colors.grey,
                  size: 30,
                ),
              ),
            ),
            errorWidget: (final context, final url, final error) {
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
