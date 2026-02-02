import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/screens/profile_qna/profile_qna_data.dart';
import 'package:meditrack/presentation/screens/profile_qna/profile_qna_model.dart';
import 'package:easy_localization/easy_localization.dart';

class FitnessGoalScreen extends StatelessWidget {
  const FitnessGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: CustomAppBar(title: 'My Fitness Goals'.tr()),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          itemCount: profileQnaList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final goal = profileQnaList[index];
            return _goalItem(goal, context);
          },
        ),
      ),
    );
  }

  Widget _goalItem(ProfileQnaModel goal, BuildContext context) {
    String valueText = _getValueText(goal);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GOAL # ${goal.step}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.descriptionTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            goal.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.titleTextColor),
          ),
          if (goal.description != null) ...[
            const SizedBox(height: 4),
            Text(
              goal.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.descriptionTextColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    valueText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Text(
                  'ANSWER',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.descriptionTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getValueText(ProfileQnaModel goal) {
    switch (goal.type) {
      case QnaType.singleChoice:
        dynamic value = goal.value;
        if (value == null && goal.options != null && goal.options!.isNotEmpty) {
          value = goal.options!.first.value; // Set first option as default
        }
        final selectedOption = goal.options?.firstWhere(
          (option) => option.value == value,
          orElse: () =>
              QnaOptionModel(id: '', title: value.toString(), value: value),
        );
        return selectedOption?.title ?? value.toString();

      case QnaType.input:
        if (goal.value == null) {
          // Set some defaults based on unit
          switch (goal.unit) {
            case 'kg':
              return '70kg';
            case '%':
              return '15%';
            case 'cm':
              return '80cm';
            default:
              return 'Not set';
          }
        }
        return '${goal.value}${goal.unit ?? ''}';

      case QnaType.percentage:
        if (goal.options != null) {
          List<String> percentages = [];
          for (var option in goal.options!) {
            if (option.value != null && option.value > 0) {
              percentages.add('${option.title}: ${option.value}%');
            }
          }
          if (percentages.isNotEmpty) {
            return percentages.join(', ');
          }
          // Set default percentages if none set
          return 'Gain More Muscle Mass & Strength: 25%, Maintain Current Muscle Mass & Strength: 25%, Improve Cardiovascular Endurance: 25%, Lose Fat & Get in Better Shape Overall: 25%';
        }
        return goal.value.toString();

      default:
        return goal.value?.toString() ?? 'Not set';
    }
  }
}
