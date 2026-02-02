import 'package:flutter/material.dart';

class SelectedChipWidget extends StatelessWidget {
  final String title;
  VoidCallback? onRemove;

  SelectedChipWidget({super.key, required this.title, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
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

          // Close icon
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 16, color: Colors.black54),
            ),
        ],
      ),
    );
  }
}
