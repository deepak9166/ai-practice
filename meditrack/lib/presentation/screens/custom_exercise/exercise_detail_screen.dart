import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/core/constants/app_enums.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/common_widgets/preview_video_player.dart';
import 'package:meditrack/presentation/screens/custom_exercise/custom_widget/exercise_overview.dart';
import 'package:meditrack/presentation/screens/custom_exercise/view_model/custom_exercise_view_model.dart';

import 'custom_widget/exercise_description_webview.dart';
import 'custom_widget/exercise_image_carousel.dart';
import 'custom_widget/exercise_instruction_tab.dart';
import 'custom_widget/exercise_picture_tab_widget.dart';
import 'custom_widget/exercise_video_tab.dart';


class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({super.key});

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState
    extends BaseConsumerState<ExerciseDetailScreen, CustomExerciseViewModel>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (viewModel.viewType == ExerciseDetailLayout.tabbed &&
        _tabController == null) {
      _tabController = TabController(length: 4, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = viewModel.exercises[viewModel.selectedExerciseIndex];

    return Scaffold(
      appBar: CustomAppBar(title: 'Exercise Detail'),
      body: SafeArea(
        child: viewModel.viewType == ExerciseDetailLayout.tabbed
            ? _buildTabbedLayout(exercise, _tabController, context)
            : _buildNormalLayout(exercise, context),
      ),
    );
  }

  @override
  CustomExerciseViewModel createViewModel() {
    return ref.read(customExerciseViewModel);
  }

  @override
  String screenName() => 'Exercise Detail Screen';
}

Widget _buildNormalLayout(Map<String, dynamic> exercise, BuildContext context) {
  return ListView(
    children: [
      Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: AppTheme.dividerColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SmartImageView(PngImageId.exerciseDummy.path),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerticalSpacing(),
            ExerciseOverview(exercise: exercise),
            VerticalSpacing(),

            if (exercise['videoUrl'] != null) ...[
              Text(
                'Video Demonstration',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: AppTheme.titleTextColor,
                ),
              ),
              VerticalSpacing.small,
              PreviewVideoPlayer(videoUrl: exercise['videoUrl']),
            ],
          ],
        ),
      ),
    ],
  );
}

Widget _buildTabbedLayout(
  Map<String, dynamic> exercise,
  TabController? tabController,
  BuildContext context,
) {
  final List<String> images =
      (exercise['images'] as List?)?.cast<String>() ?? [];
  return Column(
    children: [
      ExerciseImageCarousel(exercise: exercise),

      TabBar(
        controller: tabController,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 1.0,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        tabAlignment: TabAlignment.start,
        labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.titleTextColor,
        ),
        unselectedLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.descriptionTextColor,
        ),
        tabs: [
          Tab(text: 'Overview'),
          Tab(text: 'Instructions'),
          Tab(text: 'Video Demo'),
          Tab(text: 'Pictures'),
        ],
      ),
      Expanded(
        child: TabBarView(
          controller: tabController,
          children: [
            ExerciseDescriptionWebView(
              htmlContent: exercise['htmlDescription'] ?? '',
              padding: 20.0,
            ),
            ExerciseInstructionTab(exercise: exercise),
            ExerciseVideoTab(exercise: exercise),
            ExercisePictureTabWidget(exercise: exercise),
          ],
        ),
      ),
    ],
  );
}
