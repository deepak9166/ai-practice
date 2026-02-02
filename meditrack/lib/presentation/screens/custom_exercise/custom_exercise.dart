import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/constants/app_enums.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/custom_template_popup_menu.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/custom_exercise/custom_widget/custom_exercise_card_widget.dart';
import 'package:meditrack/presentation/screens/custom_exercise/view_model/custom_exercise_view_model.dart';

class CustomExercise extends ConsumerStatefulWidget {
  const CustomExercise({super.key});

  @override
  ConsumerState<CustomExercise> createState() => _CustomExerciseState();
}

class _CustomExerciseState
    extends BaseConsumerState<CustomExercise, CustomExerciseViewModel> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(customExerciseViewModel);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Custom Exercise',
        defaultActionTitle: '+EXERCISE',
        onDefaultActionPressed: () {
          appLog('on CustomExercise exercise tapped');
          AppRouter.push(context, AppConstants.routeAddCustomExercise);
        },
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.exercises.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = viewModel.exercises[index];

            return CustomExerciseCardWidget(
              title: item['title']!,
              status: item['status']!,
              mmgVersion: item['mmgVersion']!,
              muscles: item['muscles']!,
              description: item['description']!,
              buttonIcon: SvgImageId.moreDots.path,

              onSeeDetail: () {
                appLog('See detail: ${item['title']}');
                viewModel.viewType = ExerciseDetailLayout.simple;
                AppRouter.push(
                  context,
                  AppConstants.routeExerciseDetail,
                  extra: index,
                );
              },

              onTopBtnTapped: (offset) {
                CustomTemplatePopupMenu.show(
                  context,
                  options: const [
                    {'value': 'delete_workout', 'text': 'Delete Workout'},
                  ],
                  position: offset,
                  onSelected: (value) {
                    if (value == 'delete_workout') {
                      viewModel.deleteExercise(item);
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  CustomExerciseViewModel createViewModel() {
    return ref.read(customExerciseViewModel);
  }

  @override
  String screenName() {
    return "Custom Exercise Screen";
  }
}
