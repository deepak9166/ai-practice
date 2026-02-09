import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MuscleData {
  final String muscle;
  final double days;

  MuscleData(this.muscle, this.days);
}

class DayWorkout {
  final String bodyType; // Upper body / Lower body
  final double value; // height of segment
  final String label; // Mar 11, Mar 18, etc

  DayWorkout(this.bodyType, this.value, this.label);
}

class StackedChartGraph extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color color;
  final List<MuscleData> data;
  final Function()? onPressed;
  final int? yAxisLabelRoted;

  const StackedChartGraph({
    super.key,
    required this.color,
    required this.title,
    required this.subTitle,
    required this.data,
    this.onPressed,
    this.yAxisLabelRoted = 0,
  });

  @override
  Widget build(BuildContext context) {
    final mar11 = [
      DayWorkout('Upper body', 8, 'Mar 11'),
      DayWorkout('Lower body', 8, 'Mar 11'),
    ];

    final mar18 = [
      DayWorkout('Upper body', 6, 'Mar 18'),
      DayWorkout('Lower body', 6, 'Mar 18'),
    ];

    final mar25 = [
      DayWorkout('Upper body', 8, 'Mar 25'),
      DayWorkout('Lower body', 8, 'Mar 25'),
    ];

    final apr01 = [
      DayWorkout('Upper body', 10, 'Apr 01'),
      DayWorkout('Lower body', 10, 'Apr 01'),
    ];

    final apr08 = [
      DayWorkout('Upper body', 12, 'Apr 08'),
      DayWorkout('Lower body', 12, 'Apr 08'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontSize: 18),
                ),
                Text(subTitle, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// Chart
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,

            legend: Legend(
              isVisible: true,
              toggleSeriesVisibility: false,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
              legendItemBuilder: (legendText, series, point, seriesIndex) {
                return Wrap(
                  runSpacing: 15,
                  spacing: 10,
                  children: [
                    for (var item in mar11)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(item.bodyType.toUpperCase()),
                        ],
                      ),
                  ],
                );
              },
            ),

            /// X Axis
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              labelRotation: yAxisLabelRoted ?? 0,
              axisLine: AxisLine(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              majorTickLines: const MajorTickLines(size: 0),
              title: AxisTitle(
                text: 'TOTAL NO. OF DAYS',
                textStyle: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontSize: 8, letterSpacing: 3),
              ),
            ),

            /// Y Axis
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 50,
              interval: 10,
              axisLine: AxisLine(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              majorGridLines: const MajorGridLines(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              title: AxisTitle(
                text: 'STRENGTH MMG',
                textStyle: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontSize: 8, letterSpacing: 3),
              ),
            ),

            tooltipBehavior: TooltipBehavior(enable: true),

            /// SERIES
            series: <CartesianSeries>[
              /// Actual stacked data
              _stackedSeries(mar11, const Color(0xFFFF6F61), showLedgned: true),
              _stackedSeries(mar18, const Color(0xFFFF8A80)),
              _stackedSeries(mar25, const Color(0xFFFFAB91)),
              _stackedSeries(apr01, const Color(0xFFFFCCBC)),
              _stackedSeries(apr08, const Color(0xFFFFE0D6)),
            ],
          ),
        ),
      ],
    );
  }

  /// Stacked Series Builder
  StackedColumnSeries<DayWorkout, String> _stackedSeries(
    List<DayWorkout> data,
    Color color, {
    bool showLedgned = false,
  }) {
    return StackedColumnSeries<DayWorkout, String>(
      dataSource: data,
      xValueMapper: (d, _) => d.bodyType,
      yValueMapper: (d, _) => d.value,
      color: color,

      /// ❌ Hide from legend
      isVisibleInLegend: showLedgned,

      dataLabelSettings: const DataLabelSettings(
        isVisible: true,
        textStyle: TextStyle(color: Colors.black, fontSize: 10),
      ),
      dataLabelMapper: (d, _) => d.label,
    );
  }
}
