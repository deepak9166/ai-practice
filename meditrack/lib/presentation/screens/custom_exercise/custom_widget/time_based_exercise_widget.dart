import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_theme.dart';

class TimeBasedExerciseWidget extends StatelessWidget {
  final bool isTimeBased;
  final ValueChanged<bool> onChanged;

  const TimeBasedExerciseWidget({
    super.key,
    required this.isTimeBased,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time-Based Exercise',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.descriptionTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RadioOption(
                label: 'Yes',
                value: true,
                groupValue: isTimeBased,
                onChanged: onChanged,
              ),
            ),
            Expanded(
              child: _RadioOption(
                label: 'No',
                value: false,
                groupValue: isTimeBased,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool value;
  final bool groupValue;
  final ValueChanged<bool> onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Radio<bool>(
            value: value,
            groupValue: groupValue,
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.titleTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
