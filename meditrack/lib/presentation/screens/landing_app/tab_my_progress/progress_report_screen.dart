import 'package:flutter/material.dart';
import 'package:meditrack/presentation/common_widgets/custom_input_dropdown.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import '../../../common_model/dropdown_value_model.dart';
import '../../../common_widgets/graphs/area_chart.dart';

class ProgressReportScreen extends StatelessWidget {
  const ProgressReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AreaChartData> _maxWeightData = [
      // Oct 2025
      AreaChartData('Oct 2025', 40),
      AreaChartData('Oct 2025', 42),
      AreaChartData('Oct 2025', 45),
      AreaChartData('Oct 2025', 44), // slight drop
      AreaChartData('Oct 2025', 48),

      // Dec 2025
      AreaChartData('Dec 2025', 50),
      AreaChartData('Dec 2025', 52),
      AreaChartData('Dec 2025', 55),
      AreaChartData('Dec 2025', 54), // slight drop
      AreaChartData('Dec 2025', 58),

      // Jan 2026
      AreaChartData('Jan 2026', 58),
      AreaChartData('Jan 2026', 60),
      AreaChartData('Jan 2026', 62),
      AreaChartData('Jan 2026', 61), // recovery dip
      AreaChartData('Jan 2026', 65),

      // Mar 2026
      AreaChartData('Mar 2026', 65),
      AreaChartData('Mar 2026', 67),
      AreaChartData('Mar 2026', 70),
      AreaChartData('Mar 2026', 69),
      AreaChartData('Mar 2026', 72),

      // May 2026
      AreaChartData('May 2026', 72),
      AreaChartData('May 2026', 74),
      AreaChartData('May 2026', 76),
      AreaChartData('May 2026', 75),
      AreaChartData('May 2026', 78),

      // June 2026
      AreaChartData('June 2026', 78),
      AreaChartData('June 2026', 80),
      AreaChartData('June 2026', 82),
      AreaChartData('June 2026', 81),
      AreaChartData('June 2026', 85),
    ];

    final List<AreaChartData> _avgWeightData = [
      AreaChartData('Oct 2025', 60),
      AreaChartData('Dec 2025', 70),
      AreaChartData('Jan 2026', 65),
      AreaChartData('Mar 2026', 70),
      AreaChartData('May 2026', 80),
    ];

    final List<AreaChartData> _totalRepsweightData = [
      AreaChartData('Oct 2025', 300),
      AreaChartData('Dec 2025', 350),
      AreaChartData('Jan 2026', 300),
      AreaChartData('Mar 2026', 450),
      AreaChartData('May 2026', 500),
    ];

    final List<AreaChartData> _totalVolumeWeightData = [
      AreaChartData('Oct 2025', 3000),
      AreaChartData('Dec 2025', 3500),
      AreaChartData('Jan 2026', 3500),
      AreaChartData('Mar 2026', 4000),
      AreaChartData('May 2026', 4500),
    ];

    final List<DropdownValueModel> exerciseList = [
      DropdownValueModel(title: "Back Extension", icon: "", value: "1"),
      DropdownValueModel(title: "Aerobics", icon: "", value: "2"),
      DropdownValueModel(title: "Harking", icon: "", value: "3"),
      DropdownValueModel(title: "Bench Press", icon: "", value: "4"),
      DropdownValueModel(title: "Pull Up", icon: "", value: "5"),
      DropdownValueModel(title: "Push ups", icon: "", value: "6"),
      DropdownValueModel(title: "Zumba", icon: "", value: "7"),
    ];
final List<AreaCharWithDatetData> _maxWeightDataDateTime = [
  // Jan 2026 (3)
  AreaCharWithDatetData(DateTime(2026, 1, 5), 58),
  AreaCharWithDatetData(DateTime(2026, 1, 16), 61),
  AreaCharWithDatetData(DateTime(2026, 1, 27), 63),

  // Feb 2026 (2)
  AreaCharWithDatetData(DateTime(2026, 2, 8), 64),
  AreaCharWithDatetData(DateTime(2026, 2, 22), 66),

  // Mar 2026 (3)
  AreaCharWithDatetData(DateTime(2026, 3, 6), 68),
  AreaCharWithDatetData(DateTime(2026, 3, 17), 70),
  AreaCharWithDatetData(DateTime(2026, 3, 27), 69), // small dip

  // Apr 2026 (2)
  AreaCharWithDatetData(DateTime(2026, 4, 9), 71),
  AreaCharWithDatetData(DateTime(2026, 4, 23), 73),

  // May 2026 (3)
  AreaCharWithDatetData(DateTime(2026, 5, 7), 75),
  AreaCharWithDatetData(DateTime(2026, 5, 16), 77),
  AreaCharWithDatetData(DateTime(2026, 5, 28), 76), // deload

  // Jun 2026 (2)
  AreaCharWithDatetData(DateTime(2026, 6, 11), 78),
  AreaCharWithDatetData(DateTime(2026, 6, 25), 80),

  // Jul 2026 (3)
  AreaCharWithDatetData(DateTime(2026, 7, 6), 82),
  AreaCharWithDatetData(DateTime(2026, 7, 15), 84),
  AreaCharWithDatetData(DateTime(2026, 7, 26), 83),

  // Aug 2026 (2)
  AreaCharWithDatetData(DateTime(2026, 8, 10), 85),
  AreaCharWithDatetData(DateTime(2026, 8, 24), 87),

  // Sep 2026 (3)
  AreaCharWithDatetData(DateTime(2026, 9, 5), 88),
  AreaCharWithDatetData(DateTime(2026, 9, 14), 90),
  AreaCharWithDatetData(DateTime(2026, 9, 27), 89),

  // Oct 2026 (2)
  AreaCharWithDatetData(DateTime(2026, 10, 12), 91),
  AreaCharWithDatetData(DateTime(2026, 10, 26), 92),

  // Nov 2026 (3)
  AreaCharWithDatetData(DateTime(2026, 11, 6), 93),
  AreaCharWithDatetData(DateTime(2026, 11, 15), 95), // max cap
  AreaCharWithDatetData(DateTime(2026, 11, 27), 94),

  // Dec 2026 (2)
  AreaCharWithDatetData(DateTime(2026, 12, 10), 96),
  AreaCharWithDatetData(DateTime(2026, 12, 28), 94),
];



    return Scaffold(
      appBar: AppBar(elevation: 1, title: Text('Progress Report')),

      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          VerticalSpacing.medium,
          CustomDropdownInput<DropdownValueModel>(
            hint: 'Select type',
            items: exerciseList,
            value: null,
            onChanged: (value) {},
          ),
          VerticalSpacing.medium,
          AreaChartWithDate(
            title: 'MAX WEIGHT',
            label: '82 KG',
            maxValueRange: 100,
            graphColor: Theme.of(context).primaryColor,
            data: _maxWeightDataDateTime,
          ),

          VerticalSpacing.medium,
          AreaChart(
            title: 'AVG. WEIGHT',
            label: '82 KG',
            maxValueRange: 100,
            firstColor: Color.fromRGBO(
              214,
              180,
              111,
              1,
            ), //rgba(214, 180, 111, 1)
            secondColor: Color.fromRGBO(
              214,
              180,
              111,
              0,
            ), //rgba(214, 180, 111, 0)
            data: _avgWeightData,
          ),
          VerticalSpacing.medium,
          AreaChart(
            title: 'TOTAL REPS',
            label: '450',
            maxValueRange: 500,
            firstColor: Color.fromRGBO(
              111,
              214,
              150,
              1,
            ), //rgba(111, 214, 150, 1)
            secondColor: Color.fromRGBO(
              111,
              214,
              150,
              0,
            ), //rgba(111, 214, 150, 0)
            data: _totalRepsweightData,
          ),
          VerticalSpacing.medium,
          AreaChart(
            title: 'TOTAL VOLUME',
            label: '4450',
            maxValueRange: 5000,
            firstColor: Color.fromRGBO(
              214,
              111,
              150,
              1,
            ), //rgba(214, 111, 150, 1)
            secondColor: Color.fromRGBO(
              214,
              111,
              150,
              0,
            ), //rgba(214, 111, 150, 0)
            data: _totalVolumeWeightData,
          ),
        ],
      ),
    );
  }
}
