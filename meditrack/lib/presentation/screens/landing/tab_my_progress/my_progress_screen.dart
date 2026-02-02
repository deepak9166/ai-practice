import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

import '../../../../core/constants/app_constants.dart';

class MyProgressScreen extends StatelessWidget {
  const MyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<GraphData> graphList = [
      GraphData(
        image: SvgImageId.blueGraph.path,
        name: 'Progress Tracking - Exercise-level',
        progressType: ProgressType.exerciseLevel,
      ),
      GraphData(
        image: SvgImageId.purpleGraph.path,
        name: 'Total Workouts Summary',
        progressType: ProgressType.totalWorkoutSummary,
      ),
      GraphData(
        image: SvgImageId.orangeGraph.path,
        name: 'Historical Workout Stats - MONTHLY SUMMARY',
        progressType: ProgressType.monthlySummary,
      ),
      GraphData(
        image: SvgImageId.greenGraph.path,
        name: 'Historical Workout Stats - WEEKLY SUMMARY',
        progressType: ProgressType.weeklySummary,
      ),
      GraphData(
        image: SvgImageId.pinkGraph.path,
        name: 'Month-level TTD Graphs',
        progressType: ProgressType.ttDGraph,
      ),
    ];
    return Scaffold(
      appBar: AppBar(elevation: 1, title: Text('My Progress')),
      body: GridView.builder(
        padding: EdgeInsets.all(20),
        itemCount: graphList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 186,
        ),
        itemBuilder: (context, index) {
          var item = graphList[index];
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              _manageNavigation(item.progressType, context);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: TextTheme.of(
                        context,
                      ).titleSmall?.copyWith(fontSize: 14),
                    ),
                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: SmartImageView(item.image, fit: BoxFit.cover),
                    ),

                    Row(
                      children: [
                        Text(
                          'View',
                          style: TextTheme.of(context).labelMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SmartImageView(
                          SvgImageId.iconNext.path,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _manageNavigation(ProgressType progressType, BuildContext context) {
    switch (progressType) {
      case ProgressType.exerciseLevel:
        AppRouter.push(context, AppConstants.routeProgressReport);
        break;
      case ProgressType.totalWorkoutSummary:
        AppRouter.push(context, AppConstants.routeTotalWorkoutSummary);
        break;
      case ProgressType.weeklySummary:
        AppRouter.push(context, AppConstants.routeWeeklySummary);
        break;
      case ProgressType.ttDGraph:
         AppRouter.push(context, AppConstants.routeMonthlyWorkoutSummary);
        break;
      case ProgressType.monthlySummary:
        AppRouter.push(context, AppConstants.routeMonthlyWorkoutSummary);
        break;
    }
  }
}

class GraphData {
  final String name;
  final String image;
  final ProgressType progressType;

  GraphData({
    required this.image,
    required this.name,
    required this.progressType,
  });
}

enum ProgressType {
  exerciseLevel,
  totalWorkoutSummary,
  monthlySummary,
  weeklySummary,
  ttDGraph,
}
