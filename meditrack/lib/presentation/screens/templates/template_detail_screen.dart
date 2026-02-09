import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/custom_template_popup_menu.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_set.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/templates/common_widget/exercise_detail_item.dart';
import 'package:meditrack/presentation/screens/templates/common_widget/exercise_info_card.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';

import '../../../core/constants/language_keys.dart';
import '../../common_widgets/custom_popup_dialog.dart';

/// Template Detail Screen
///
/// Screen for displaying details of a selected workout template.
class TemplateDetailScreen extends ConsumerStatefulWidget {
  const TemplateDetailScreen({super.key});

  @override
  ConsumerState<TemplateDetailScreen> createState() =>
      _TemplateDetailScreenState();
}

class _TemplateDetailScreenState
    extends BaseConsumerState<TemplateDetailScreen, TemplatesViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Template Detail',
        actions: [
          CustomTemplatePopupMenu(
            options: const [
              {'value': 'edit_save', 'text': 'Edit & Save'},
              {
                'value': 'edit_new_template',
                'text': 'Edit & save a new template',
              },
              {'value': 'add_workout_session', 'text': 'Add Workout Session'},
              {'value': 'share_template', 'text': 'Share Template'},
              {'value': 'delete_template', 'text': 'Delete Template'},
            ],
            onSelected: (value) {
              // Handle menu item selection
              switch (value) {
                case 'edit_save':
                  appLog('Edit & Save selected');
                  context.push(AppConstants.routeEditTemplate);
                  break;
                case 'edit_new_template':
                  appLog('Edit & save a new template selected');
                  context.push(AppConstants.routeEditTemplate);
                  break;
                case 'add_workout_session':
                  appLog('Add Workout Session selected');
                  break;
                case 'share_template':
                  appLog('Share Template selected');
                  context.push(AppConstants.routeShareTemplates);
                  break;
                case 'delete_template':
                  appLog('Delete Template selected');
                  _deleteConfirm();
                  break;
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<Exercise>>(
          valueListenable: viewModel.listExercises,
          builder: (context, exercises, child) {
            return ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                const ExerciseInfoCard(
                  title: 'Arm circles',
                  strengthBadge: 'Strength',
                  mmg: 'Middle Back, Core',
                  msg: 'Middle Chest, Lower Chest',
                  templateType: 'Bodyweight-only / Calisthenics',
                ),
                const SizedBox(height: 16.0),
                ...exercises.asMap().entries.map(
                  (entry) => ExerciseDetailItem(
                    exercise: entry.value,
                    index: entry.key,
                    viewModel: viewModel,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  _deleteConfirm() async {
    await CustomPopupDialog.show(
      context: context,
      content: 'Are you sure you want ton\ndelete this template?',

      actions: [
        DialogAction(
          text: LanguageKeys.cancel.tr(),
          onPressed: () {
            // Handle cancel
          },
        ),
        DialogAction(
          text: "Yes. Delete",
          onPressed: () async {
            // Handle Delete
          },
          isDestructive: false,
          isPrimary: true,
        ),
      ],
    );
  }

  @override
  TemplatesViewModel createViewModel() {
    return ref.read(templatesViewModelProvider);
  }

  @override
  String screenName() {
    return "Template Detail Screen";
  }
}
