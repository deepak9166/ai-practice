import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import '../../../log/app_logs.dart';
import '../../common_widgets/graphs/area_chart.dart';
import 'detail_list_card_view.dart';

class MeasurementDetailScreen extends StatelessWidget {
  const MeasurementDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AreaChartData> _totalRepsweightData = [
      AreaChartData('01/04', 5.9),
      AreaChartData('05/04', 8.2),
      AreaChartData('06/04', 7.8),
      AreaChartData('07/04', 8),
      AreaChartData('08/04', 8.5),
    ];

    final List<ListValueModel> historyData = [
      ListValueModel(icon: 'neck', title: '5’2 In', value: '04/04'),
      ListValueModel(icon: 'shoulders', title: '5’2 In', value: '05/04'),
      ListValueModel(icon: 'chest', title: '5’2 In', value: '10/04'),

      ListValueModel(icon: 'right_calf', title: '5’2 In', value: '15/04'),
      ListValueModel(icon: 'left_calf', title: '5’2 In', value: '20/04'),
      ListValueModel(icon: 'left_calf', title: '5’2 In', value: '25/04'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Height'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SmartImageView(SvgImageId.add.path),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          VerticalSpacing.mediumExtra,
          AreaChartVarient(
            maxValueRange: 10,
            firstColor: Color.fromRGBO(
              153,
              111,
              214,
              0.6,
            ), //rgba(153, 111, 214, 0.6)
            secondColor: Color.fromRGBO(153, 111, 214, 0),
            data: _totalRepsweightData,
          ),

          VerticalSpacing.mediumExtra,
          DetailListCardView(
            title: 'Height History',
            data: historyData,
            onTap: (value) {
              appLog('click for value ${value.title}');
            },
          ),
        ],
      ),
    );
  }
}
