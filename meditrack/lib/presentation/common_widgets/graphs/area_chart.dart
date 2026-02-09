import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AreaCharWithDatetData {
  final DateTime date;
  final double weight;

  AreaCharWithDatetData(this.date, this.weight);
}

class AreaChartWithDate extends StatelessWidget {
  final String title;
  final String label;
  final Color graphColor;
  // final Color secondColor;
  final List<AreaCharWithDatetData> data;
  final double maxValueRange;
  const AreaChartWithDate({
    super.key,
    this.title = '',
    required this.graphColor,
    this.label = '',
    // required this.secondColor,
    required this.data,
    required this.maxValueRange,
  });

  @override
  Widget build(BuildContext context) {
    final double maxWeight = data
        .map((e) => e.weight)
        .reduce((a, b) => a > b ? a : b);

    var firstColor = graphColor.withValues(alpha: 6.0);
    var secondColor = graphColor.withValues(alpha: 0.0);

    final ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true, // 👈 drag to scroll
      enablePinching: false, // optional
      enableDoubleTapZooming: false,
      zoomMode: ZoomMode.x, // 👈 only X-axis scroll
      enableMouseWheelZooming: true,
      enableDirectionalZooming: true,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: TextTheme.of(context).labelSmall, //labelSmall
            ),
          if (title.isNotEmpty) const SizedBox(height: 4),
          if (label.isNotEmpty)
            Text(label, style: TextTheme.of(context).headlineMedium),
          if (label.isNotEmpty) const SizedBox(height: 20),
          SfCartesianChart(
            enableAxisAnimation: true,
            zoomPanBehavior: _zoomPanBehavior,
            plotAreaBorderWidth: 0,
            primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.months,
              interval: 1,
              dateFormat: DateFormat('MMM yyyy'),
              labelRotation: 270,

              // 🔥 show only last 6 months
              autoScrollingMode: AutoScrollingMode.start,
              autoScrollingDelta: 6,
              autoScrollingDeltaType: DateTimeIntervalType.months,

              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
            ),
            primaryYAxis: NumericAxis(
              minimum: maxValueRange / 5,
              maximum: maxValueRange,
              interval: maxValueRange / 5,
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(width: 0),
            ),
            onTooltipRender: (tooltipArgs) {
              print('object');
            },
            tooltipBehavior: TooltipBehavior(
              enable: true,

              activationMode: ActivationMode.singleTap,
              color: graphColor,
              decimalPlaces: 0,
              borderColor: graphColor,
              textStyle: const TextStyle(color: Colors.white),
              builder: (data, point, series, pointIndex, seriesIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    "${(data as AreaCharWithDatetData).weight.toInt()}kg",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              format: 'point.y kg',
            ),
            onMarkerRender: (MarkerRenderArgs args) {
              final currentValue = data[args.pointIndex ?? 0].weight;

              if (currentValue != maxWeight) {
                args.markerWidth = 0;
                args.markerHeight = 0;
                args.color = firstColor;
                args.borderColor = secondColor;
              } else {
                args.markerWidth = 9;
                args.markerHeight = 9;
                args.borderWidth = 2;
                args.borderWidth = 2;
              }
            },
            series: <AreaSeries<AreaCharWithDatetData, DateTime>>[
              AreaSeries<AreaCharWithDatetData, DateTime>(
                dataSource: data,

                xValueMapper: (AreaCharWithDatetData d, _) => d.date,
                yValueMapper: (AreaCharWithDatetData d, _) => d.weight,
                borderColor: graphColor,
                borderWidth: 2,

                gradient: LinearGradient(
                  colors: [graphColor.withValues(alpha: 0.6), secondColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                markerSettings: MarkerSettings(
                  isVisible: true,
                  width: 10,
                  height: 10,
                  borderWidth: 3,
                  borderColor: Colors.white,
                  color: graphColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AreaChart extends StatelessWidget {
  final String title;
  final String label;
  final Color firstColor;
  final Color secondColor;
  final List<AreaChartData> data;
  final double maxValueRange;
  const AreaChart({
    super.key,
    this.title = '',
    required this.firstColor,
    this.label = '',
    required this.secondColor,
    required this.data,
    required this.maxValueRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: TextTheme.of(context).labelSmall, //labelSmall
            ),
          if (title.isNotEmpty) const SizedBox(height: 4),
          if (label.isNotEmpty)
            Text(label, style: TextTheme.of(context).headlineMedium),
          if (label.isNotEmpty) const SizedBox(height: 20),
          SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              labelRotation: 270,
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              minimum: maxValueRange / 5,
              maximum: maxValueRange,
              interval: maxValueRange / 5,
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(width: 0),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              color: firstColor,
              textStyle: const TextStyle(color: Colors.white),
              format: 'point.y kg',
            ),
            series: <AreaSeries<AreaChartData, String>>[
              AreaSeries<AreaChartData, String>(
                dataSource: data,
                xValueMapper: (AreaChartData d, _) => d.month,
                yValueMapper: (AreaChartData d, _) => d.weight,
                borderColor: firstColor,
                borderWidth: 3,
                gradient: LinearGradient(
                  colors: [firstColor, secondColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                markerSettings: MarkerSettings(
                  isVisible: true,
                  width: 10,
                  height: 10,
                  borderWidth: 3,
                  borderColor: Colors.white,
                  color: firstColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AreaChartVarient extends StatelessWidget {
  final String title;
  final String label;
  final Color firstColor;
  final Color secondColor;
  final List<AreaChartData> data;
  final double maxValueRange;
  const AreaChartVarient({
    super.key,
    this.title = '',
    required this.firstColor,
    this.label = '',
    required this.secondColor,
    required this.data,
    required this.maxValueRange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: TextTheme.of(context).labelSmall, //labelSmall
          ),
        if (title.isNotEmpty) const SizedBox(height: 4),
        if (label.isNotEmpty)
          Text(label, style: TextTheme.of(context).headlineMedium),
        if (label.isNotEmpty) const SizedBox(height: 20),
        SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            majorGridLines: const MajorGridLines(width: 0),
            labelRotation: 0,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(width: 0),
            // axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(axisLabelRenderArgs.text, TextStyle(fontSize: 8)),
          ),
          primaryYAxis: NumericAxis(
            minimum: maxValueRange / 5,
            maximum: maxValueRange,
            interval: maxValueRange / 5,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(width: 0),
          ),

          tooltipBehavior: TooltipBehavior(
            enable: true,
            color: firstColor,
            textStyle: const TextStyle(color: Colors.white),
            format: 'point.y',
          ),
          series: <AreaSeries<AreaChartData, String>>[
            AreaSeries<AreaChartData, String>(
              dataSource: data,
              xValueMapper: (AreaChartData d, _) => d.month,
              yValueMapper: (AreaChartData d, _) => d.weight,
              borderColor: firstColor,
              borderWidth: 3,
              gradient: LinearGradient(
                colors: [firstColor, secondColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              markerSettings: MarkerSettings(
                isVisible: true,
                width: 10,
                height: 10,
                borderWidth: 3,
                borderColor: Colors.white,
                color: firstColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AreaChartData {
  final String month;
  final double weight;

  AreaChartData(this.month, this.weight);
}
