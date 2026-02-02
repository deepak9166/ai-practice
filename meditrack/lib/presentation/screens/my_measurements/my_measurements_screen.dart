import 'package:flutter/material.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/screens/my_measurements/detail_list_card_view.dart';

import '../../../core/constants/app_constants.dart';

class MyMeasurementsScreen extends StatelessWidget {
  const MyMeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ListValueModel> basicInformationData = [
      ListValueModel(icon: 'weight', title: 'Weight', value: '75 kg'),
      ListValueModel(icon: 'height', title: 'Height', value: "5'2 In"),
      ListValueModel(icon: 'waist', title: 'Waist', value: '28 cm'),
      ListValueModel(icon: 'body_fat', title: 'Body Fat %', value: '15%'),
      ListValueModel(icon: 'calorie', title: 'Calorie Intake', value: '97 cal'),
      ListValueModel(icon: 'alcohol', title: 'Alcohol Intake', value: '10 ml'),
    ];

    final List<ListValueModel> circumferencesData = [
      ListValueModel(icon: 'neck', title: 'Neck', value: '39 cm'),
      ListValueModel(icon: 'shoulders', title: 'Shoulders', value: '48 cm'),
      ListValueModel(icon: 'chest', title: 'Chest', value: '100 cm'),
      ListValueModel(
        icon: 'right_arm',
        title: 'Right arm (biceps & Triceps)',
        value: '34 cm',
      ),
      ListValueModel(
        icon: 'left_arm',
        title: 'Left arm (biceps & Triceps)',
        value: '33.5 cm',
      ),
      ListValueModel(
        icon: 'right_forearm',
        title: 'Right Forearm',
        value: '28 cm',
      ),
      ListValueModel(
        icon: 'left_forearm',
        title: 'Left Forearm',
        value: '27.5 cm',
      ),
      ListValueModel(icon: 'belly', title: 'Belly', value: '92 cm'),
      ListValueModel(icon: 'hips', title: 'Hips (Glutes)', value: '98 cm'),
      ListValueModel(
        icon: 'right_thigh',
        title: 'Right Thigh (Quads & Hams)',
        value: '56 cm',
      ),
      ListValueModel(
        icon: 'left_thigh',
        title: 'Left Thigh (Quads & Hams)',
        value: '55.5 cm',
      ),
      ListValueModel(icon: 'right_calf', title: 'Calf (Right)', value: '38 cm'),
      ListValueModel(icon: 'left_calf', title: 'Calf (Left)', value: '37.5 cm'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('My Measurements')),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          VerticalSpacing.small,
          DetailListCardView(
            onTap: (value) {
              appLog('click for value ${value.title}');
              AppRouter.push(context, AppConstants.routeMyMeasurementDetail);
            },
            title: 'Basic Information',
            data: basicInformationData,
          ),
          VerticalSpacing.mediumExtra,
          DetailListCardView(
            title: 'Circumferences',
            data: circumferencesData,
            onTap: (value) {
              appLog('click for value ${value.title}');
              AppRouter.push(context, AppConstants.routeMyMeasurementDetail);
            },
          ),
        ],
      ),
    );
  }
}
