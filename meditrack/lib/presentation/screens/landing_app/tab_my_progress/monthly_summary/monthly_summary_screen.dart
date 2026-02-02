import 'package:flutter/material.dart';

import '../../../../../log/app_logs.dart';
import '../../../../common_model/dropdown_value_model.dart';
import '../../../../common_widgets/custom_input_dropdown.dart';
import '../../../../common_widgets/graphs/bar_chart_graph.dart';
import '../../../../common_widgets/spacing_widgets.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(title: Text('Monthly Summary')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TabBar(
                padding: EdgeInsets.all(5),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.label,
                splashBorderRadius: BorderRadius.circular(6),
                indicatorPadding: EdgeInsets.all(0),
                labelPadding: EdgeInsets.symmetric(horizontal: 5),
                automaticIndicatorColorAdjustment: true,
                physics: NeverScrollableScrollPhysics(),
                indicatorWeight: 0,

                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: primaryColor),
                ),
                labelStyle: TextTheme.of(context).titleSmall?.copyWith(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                unselectedLabelStyle: TextStyle(color: Colors.black),
                onTap: (value) {
                  appLog('tap on tab value $value');
                },
                tabs: [
                  tabButton('3M'),
                  tabButton('6M'),
                  tabButton('1Y'),
                  tabButton('2Y'),
                  tabButton('TTD'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _WorkoutGraphViewWTD(),
                  _WorkoutGraphViewWTD(),
                  _WorkoutGraphViewWTD(),
                  _WorkoutGraphViewWTD(),
                  Center(child: Text('Coming soon')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabButton(String name) {
    return Container(
      width: 80,
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Center(child: Text(name)),
    );
  }
}

class _WorkoutGraphViewWTD extends StatelessWidget {
  const _WorkoutGraphViewWTD({super.key});

  @override
  Widget build(BuildContext context) {
    List<DropdownValueModel> dropdownList = [
      DropdownValueModel(title: 'Total Workouts Logged', value: '1'),
      DropdownValueModel(title: 'Workout Type Breakdown', value: '2'),
      DropdownValueModel(title: 'Average Training Volume', value: '3'),
      DropdownValueModel(title: 'Muscle Group Activity Days', value: '4'),
      DropdownValueModel(title: 'Exercises Per Muscle Group', value: '5'),
      DropdownValueModel(title: 'Total Reps Per Muscle Group', value: '6'),
      DropdownValueModel(title: 'Average Workout Duration by Type', value: '7'),
      DropdownValueModel(
        title: 'Average Cardio Distance per Session',
        value: '8',
      ),
      DropdownValueModel(title: 'Weekly Workout Frequency by Type', value: '9'),
      DropdownValueModel(
        title: 'Training Volume per Muscle Group',
        value: '10',
      ),
      DropdownValueModel(
        title: 'Average Reps per Strength Session',
        value: '11',
      ),
    ];

    final List<WorkoutData> chartData = [
      WorkoutData('Sept 2025', 300),
      WorkoutData('Oct 2025', 150),
      WorkoutData('Nov 2025', 450),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          VerticalSpacing.mediumExtra,
          CustomDropdownInput(
            items: dropdownList,

            tooltip: ' in development', // TODO:
            onChanged: (value) {},
            value: null,
          ),
          VerticalSpacing.medium,
          Expanded(
            child: ListView(
              children: [
                WorkoutBarChart(
                  yAxisLabelRoted: 270,
                  color: Theme.of(context).primaryColor,
                  title: 'Frequency of Workouts',
                  subTitle: '16 Sep 2025 - 15 Oct 2025',
                  onPressed: () {},
                  data: chartData,
                ),
                VerticalSpacing.mediumExtra,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
