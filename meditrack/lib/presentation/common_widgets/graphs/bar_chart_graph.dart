import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../config/svg_config.dart';
import '../smart_image_view.dart';
import '../spacing_widgets.dart';

class WorkoutBarChart extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color color;
  final List<WorkoutData> data;
  final List<WorkoutData>? dataLineGraph;
  final Function()? onPressed;
  final int? yAxisLabelRoted;
  const WorkoutBarChart({
    super.key,
    required this.color,
    required this.title,
    required this.subTitle,
    required this.data,
    this.dataLineGraph,
    this.onPressed,
    this.yAxisLabelRoted = 0,
  });

  @override
  Widget build(BuildContext context) {
    var value = (data.length / 10);
    bool isMoreData = value > 1.0;
    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextTheme.of(
                    context,
                  ).titleSmall?.copyWith(fontSize: 18),
                ),
                Text(
                  subTitle,
                  style: TextTheme.of(context).labelSmall,
                ), //labelSmall
              ],
            ),
            Spacer(),
            if (onPressed != null)
              SizedBox(
                height: 30,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: onPressed,
                  child: Row(
                    children: [
                      SmartImageView(
                        SvgImageId.eye.path,
                        width: 14,
                        height: 14,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Combinations',
                        style: TextTheme.of(context).bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ), //bodySmall
                    ],
                  ),
                ),
              ),
          ],
        ),
        VerticalSpacing.medium,
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SfCartesianChart(
            margin: const EdgeInsets.only(
              left: 4,
              right: 4,
              bottom: 4,
              top: 20,
            ),

            /// X Axis
            primaryXAxis: CategoryAxis(
              plotOffsetStart: isMoreData ? 0 : 12,
              plotOffsetEnd: 0,
              labelRotation: yAxisLabelRoted ?? 0,
              title: AxisTitle(
                text: 'TOTAL NO. OF DAYS',
                textStyle: TextTheme.of(context).labelSmall?.copyWith(
                  fontSize: 8,
                  letterSpacing: 3,
                  color: Theme.of(context).colorScheme.onSecondaryFixedVariant,
                ),
              ),
              majorGridLines: const MajorGridLines(width: 0),

              axisLine: AxisLine(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              tickPosition: TickPosition.inside,
              majorTickLines: MajorTickLines(size: 0),
            ),

            /// Y Axis
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 500,
              interval: 100,
              axisLine: AxisLine(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),

              // placeLabelsNearAxisLine: false,
              title: AxisTitle(
                alignment: ChartAlignment.center,
                text: 'TOTAL WORKOUT LOGGED',
                textStyle: TextTheme.of(
                  context,
                ).labelSmall?.copyWith(fontSize: 8, letterSpacing: 3),
              ),
              majorGridLines: const MajorGridLines(
                width: 0,
                color: Color(0xFFEDEDED),
              ),
              majorTickLines: MajorTickLines(size: 0),
            ),

            enableMultiSelection: true,
            plotAreaBorderWidth: 0,

            /// Bar Series
            series: <CartesianSeries<WorkoutData, String>>[
              ColumnSeries<WorkoutData, String>(
                dataSource: data,
                xValueMapper: (WorkoutData data, _) => data.day,
                yValueMapper: (WorkoutData data, _) => data.total,
                width: _setWidht(value, isMoreData),
                color: color,
              ),

              /// Line (Total Cardio Workouts)
              if (dataLineGraph != null)
                LineSeries<WorkoutData, String>(
                  dataSource: dataLineGraph,
                  xValueMapper: (WorkoutData data, _) => data.day,
                  yValueMapper: (WorkoutData data, _) => data.total,
                  color: color.withValues(alpha: 0.6),
                  width: 3,

                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                  ),
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
            ],
          ),
        ),
      ],
    );
  }

  double _setWidht(double value, bool isMoreData) {
    if (value <= 0.3) {
      return value;
    } else if(isMoreData){
      return 0.9;
    } else {
      return value - 0.2;
    }
  }
}

class WorkoutData {
  final String day;
  final int total;

  WorkoutData(this.day, this.total);
}
