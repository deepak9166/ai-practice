import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A reusable widget for displaying a slider container with title, slider, and controls
class SliderContainer extends StatelessWidget {
  final String title;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;

  const SliderContainer({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD0C9EA).withOpacity(0.2),
        border: Border.all(color: Color.fromRGBO(208, 201, 234, 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'RedHatDisplay',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  double newValue = value - 0.1;
                  if (newValue >= min) {
                    onChanged(newValue);
                  }
                },
                icon: SvgPicture.asset(
                  SvgImageId.minus.path,
                  width: 20,
                  height: 20,
                ),
              ),
              Expanded(
                child: Slider(
                  thumbColor: value == 0
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.zero,
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: value.toStringAsFixed(2),
                  onChanged: onChanged,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  double newValue = value + 0.1;
                  if (newValue <= max) {
                    onChanged(newValue);
                  }
                },
                icon: SvgPicture.asset(
                  SvgImageId.plus.path,
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              children: [
                Text(
                  min.toStringAsFixed(2),
                  style: const TextStyle(
                    fontFamily: 'RedHatDisplay',
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Spacer(),
                Text(
                  max.toStringAsFixed(2),
                  style: const TextStyle(
                    fontFamily: 'RedHatDisplay',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
