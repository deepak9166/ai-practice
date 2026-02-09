import 'package:flutter/material.dart';

/// Responsive Spacing Widgets
///
/// Utility widgets for consistent spacing throughout the application.
/// These widgets help maintain a consistent design system.

/// Vertical Spacing
class VerticalSpacing extends StatelessWidget {
  const VerticalSpacing({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: size);
  }

  /// SmallXs vertical spacing (6px)
  static const Widget smallXs = SizedBox(height: 6);

  /// Small vertical spacing (10px)
  static const Widget small = SizedBox(height: 10);

  /// Medium vertical spacing (16px)
  static const Widget medium = SizedBox(height: 16);


  /// Medium vertical spacing (26px)
  static const Widget mediumExtra = SizedBox(height: 20);

  /// Large vertical spacing (24px)
  static const Widget large = SizedBox(height: 24);

  /// Extra large vertical spacing (30px)
  static const Widget extraLarge = SizedBox(height: 30);
}

/// Horizontal Spacing
class HorizontalSpacing extends StatelessWidget {
  const HorizontalSpacing({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size);
  }

  /// SmallXs horizontal spacing (5px)
  static const Widget smallXs = SizedBox(width: 5);

  /// Small horizontal spacing (8px)
  static const Widget small = SizedBox(width: 8);

  /// Medium horizontal spacing (16px)
  static const Widget medium = SizedBox(width: 16);

  /// Large horizontal spacing (24px)
  static const Widget large = SizedBox(width: 24);

  /// Extra large horizontal spacing (32px)
  static const Widget extraLarge = SizedBox(width: 32);
}
