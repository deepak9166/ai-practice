import 'package:flutter/material.dart';

/// Loading Indicator Widget
///
/// A reusable loading indicator with customizable size and color.
/// Can be used as a standalone widget or overlay.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

/// Full Screen Loading Overlay
///
/// A full-screen loading overlay that can be shown during async operations.
class FullScreenLoading extends StatelessWidget {
  const FullScreenLoading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
