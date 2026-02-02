import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_theme.dart';

class MuscleChipWidget extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onRemove;

  const MuscleChipWidget({
    super.key,
    required this.title,
    required this.value,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.black),
          ),
          const SizedBox(width: 6),

          // Value badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryThemeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value, style: Theme.of(context).textTheme.labelMedium),
          ),
          const SizedBox(width: 6),

          // Close icon
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
