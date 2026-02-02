import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/screens/custom_exercise/view_model/custom_exercise_view_model.dart';

class EquipmentPopupContent extends StatelessWidget {
  final CustomExerciseViewModel viewModel;

  const EquipmentPopupContent({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 167,
      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: viewModel.equipments,
        builder: (context, equipments, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(equipments.length, (index) {
              final item = equipments[index];
              return InkWell(
                onTap: () => viewModel.toggleSelection(index),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name'],
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.titleTextColor,
                                ),
                          ),
                          _CustomCheckbox(isChecked: item['selected']),
                        ],
                      ),
                    ),
                    if (index != equipments.length - 1) Divider(height: 1),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _CustomCheckbox extends StatelessWidget {
  final bool isChecked;

  const _CustomCheckbox({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isChecked ? AppTheme.primaryThemeColor : Colors.grey,
          width: 2,
        ),
        color: isChecked ? AppTheme.primaryThemeColor : Colors.transparent,
      ),
      child: isChecked
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
