import 'package:flutter/material.dart';

extension OrientationExtensions on BuildContext {
  /// Checks if the current orientation is portrait.
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;

  /// Checks if the current orientation is landscape.
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  /// Gets the current orientation (portrait or landscape).
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Convenience: True if portrait, false if landscape.
  bool get isVertical => isPortrait;
}