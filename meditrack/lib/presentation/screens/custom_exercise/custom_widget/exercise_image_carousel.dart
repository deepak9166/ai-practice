
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ExerciseImageCarousel extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseImageCarousel({super.key, required this.exercise});

  @override
  State<ExerciseImageCarousel> createState() => _ExerciseImageCarouselState();
}

class _ExerciseImageCarouselState extends State<ExerciseImageCarousel> {
  final PageController _pageController = PageController();
  Timer? _timer;

  List<String> get images =>
      (widget.exercise['images'] as List?)?.cast<String>() ?? [];

  @override
  void initState() {
    super.initState();
    if (images.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final int nextPage =
            (_pageController.page!.round() + 1) % images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(color: AppTheme.dividerColor),
                child: SmartImageView(images[index], fit: BoxFit.cover),
              );
            },
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: images.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white38,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 4,
                ),
              ),
            ),
          ),
        Positioned(
          top: 20,
          right: 20,
          child: SmartImageView(SvgImageId.favorite.path),
        ),
      ],
    );
  }
}