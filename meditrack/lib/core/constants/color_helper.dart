import 'dart:math';
import 'package:flutter/material.dart';

class RandromColor {
  static final Random _random = Random();

  static Color randomAvatarColor() {
    return Colors.primaries[
      _random.nextInt(Colors.primaries.length)
    ].shade100;
  }
}
