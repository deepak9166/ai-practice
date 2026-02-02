import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoughnutSeriesChart extends StatelessWidget {
  const DoughnutSeriesChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ExerciseData> chartData = [
      ExerciseData('Upper Chest', 120),
      ExerciseData('Middle Chest', 877),
      ExerciseData('Lowest Chest', 47),
      ExerciseData('Front Deltoids', 52),
      ExerciseData('Triceps', 65),
      ExerciseData('Lats', 87),
    ];

    List<Color> customColors = [
      Color(0xff996FD6),
      Color(0xffFF9F4C),
      Color(0xff88C0FF),
      Color(0xffEB678A),
      Color(0xffBDEA82),
      Color(0xff69F9EE),
    ];

    return SizedBox(
      height: 145,
      child: SfCircularChart(
        margin: EdgeInsets.all(0),
      
         
        onDataLabelRender: (dataLabelArgs) {
          print('object ${dataLabelArgs.color}');
        },
        palette: customColors,
        legend: Legend(
          isVisible: true,
          position: LegendPosition.right,
          itemPadding: 7,
      
          legendItemBuilder:
              (
                String legendText,
                ChartSeries<dynamic, dynamic>? series,
                ChartPoint<dynamic> point,
                int index,
              ) {
                // Get the original data from dataSource using index
                final ExerciseData dataPoint =
                    (series as DoughnutSeries).dataSource![index];
      
                // Get the color of this segment (Syncfusion assigns it automatically)
                final Color segmentColor = customColors[index];
      
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: segmentColor,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dataPoint.category,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dataPoint.amount.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                );
              },
        ), // Optional: shows category labels
        tooltipBehavior: TooltipBehavior(
        
          enable: true,
        ), // Optional: hover/tap info
      
        series: <CircularSeries>[
          DoughnutSeries<ExerciseData, String>(
          
            dataSource: chartData,
            xValueMapper: (ExerciseData data, _) => data.category,
            yValueMapper: (ExerciseData data, _) => data.amount,
            radius: '100%', // Outer radius
            innerRadius:
                '50%', // Adjust this for doughnut thickness (e.g., '50%' for thicker ring)
            explode:
                true, // Explodes all segments slightly (or use explodeIndex for specific one)
            legendIconType: LegendIconType.rectangle,
      
            dataLabelSettings: const DataLabelSettings(
              isVisible: false, // Optional: shows values on segments
              labelPosition: ChartDataLabelPosition.inside,
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseData {
  ExerciseData(this.category, this.amount);
  final String category;
  final double amount;
}
