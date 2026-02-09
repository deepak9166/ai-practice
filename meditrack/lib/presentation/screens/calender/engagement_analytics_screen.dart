import 'package:flutter/material.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import '../../common_widgets/graphs/pie_graph.dart';
import 'workout_summary_screen.dart';

class EngagementAnalyticsScreen extends StatelessWidget {
  const EngagementAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text(
              'MMG Muscle Group Engagement Analytics',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontSize: 18),
            ),
          ),
          analyticsGraph(),
          VerticalSpacing.mediumExtra,

          _msgGroupTable(),

          VerticalSpacing.mediumExtra,

          _mmgMusclesWorkTable(),

          VerticalSpacing.mediumExtra,

          _msgMusclesWorkTable(),

          VerticalSpacing.mediumExtra,
        ],
      ),
    );
  }

  Widget analyticsGraph() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DoughnutSeriesChart(),
    );
  }

  Widget _msgGroupTable() {
    return CustomTableComponant(
      columnFlex: [1.5, 1, 1, 1],
      heading: '',
      headerRowValue: ["Muscle Group", "Mapping", "Volume (%)"],
      rowValue: [
        ["Upper Chest", "Primary", "10%"],
        ["Middle Chest", "Secondary", "8%"],
        ["Lower Chest", "Primary", "8%"],
        ["Front Deltoid", "Primary", "8%"],
        ["Triceps", "Primary", "8%"],
        ["Lats", "Secondary", "30%"],
      ],
    );
  }

  Widget _mmgMusclesWorkTable() {
    return CustomTableComponant(
      columnFlex: [1.5, 1, 1, 1],
      heading: '',
      headerRowValue: ["MMG Muscles Worked", "Engagement"],
      rowValue: [
        ["Upper Chest", "10%"],
        ["Lower Body", "8%"],
      ],
    );
  }

  Widget _msgMusclesWorkTable() {
    return CustomTableComponant(
      columnFlex: [1.5, 1, 1, 1],
      heading: '',
      headerRowValue: ["MMG Muscles Worked", "Engagement"],
      rowValue: [
        ["Upper Chest", "0.75"],
        ["Middle Chest", "0.75"],
        ["Lower Chest", "0.75"],
        ["Front Deltoid", "0.75"],
        ["Triceps", "0.75"],
        ["Lats", "0.75"],
      ],
    );
  }
}
