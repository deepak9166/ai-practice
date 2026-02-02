import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

class NoExercisesWidget extends StatelessWidget {
  final VoidCallback onAdd;

  const NoExercisesWidget({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 184,
            height: 151,
            child: SmartImageView(SvgImageId.noExercise.path),
          ),
          const SizedBox(height: 12),
          Text(
            'No Exercise Added',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Text(
              "Start today's fitness journey - add your first Exercise",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF101218),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontFamily: 'RedHatDisplay',
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            child: const Text('ADD EXERCISE'),
          ),
        ],
      ),
    );
  }
}
