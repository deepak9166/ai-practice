import 'package:flutter/material.dart';

import '../../../../common_widgets/graphs/bar_chart_graph.dart';

class CombinationsScreen extends StatelessWidget {
  const CombinationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<WorkoutData> chartData = [
      WorkoutData('Mon', 300),
      WorkoutData('Tue', 135),
      WorkoutData('Wed', 350),
      WorkoutData('Thu', 55),
      WorkoutData('Fri', 175),
      WorkoutData('Sat', 370),
      WorkoutData('Sun', 120),
    ];

    final List<WorkoutData> chartDataLineGraph = [
      WorkoutData('Mon', 350),
      WorkoutData('Tue', 145),
      WorkoutData('Wed', 490),
      WorkoutData('Thu', 65),
      WorkoutData('Fri', 215),
      WorkoutData('Sat', 490),
      WorkoutData('Sun', 140),
    ];

    return Scaffold(
      appBar: AppBar(elevation: 0, title: Text('Combinations')),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          WorkoutBarChart(
            color: Color(0xff1072BD),
            title: 'Other workout',
            subTitle: '16 Sep 2025 - 22 Sep 2025',
            data: chartData,
            dataLineGraph: chartDataLineGraph,
          ),
        ],
      ),
    );
  }
}
