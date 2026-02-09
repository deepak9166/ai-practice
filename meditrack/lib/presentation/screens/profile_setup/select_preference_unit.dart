import 'package:flutter/material.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../common_model/radio_value_model.dart';
import '../../common_widgets/custom_radio_button_list.dart';

class SelectPreferenceUnit extends StatelessWidget {
  final bool forEidt;
  const SelectPreferenceUnit({super.key, required this.forEidt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(forEidt ? 'Metrics Preferences'  : 'Preferred Units'), elevation: 1),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerticalSpacing.small,
            Text(
              "Distance Unit*",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            VerticalSpacing.small,
            CustomRadioButtonList(
              options: [
                RadioValueModel(title: "Mile", value: 'mile'),
                RadioValueModel(title: "Kilometer", value: 'kilometer'),
              ],
              onChanged: (size) {
                // Update your cart or form
              },
            ),
            VerticalSpacing.small,
            Text(
              "Weight Unit*",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            VerticalSpacing.small,
            CustomRadioButtonList(
              options: [
                RadioValueModel(title: "Pound", value: 'pound'),
                RadioValueModel(title: "Kilogram", value: 'kilogram'),
              ],
              onChanged: (size) {
                // Update your cart or form
              },
            ),
            VerticalSpacing.small,
            Text(
              "Height/Length Unit*",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            VerticalSpacing.small,
            CustomRadioButtonList(
              options: [
                RadioValueModel(title: "Centimeter", value: 'centimeter'),
                RadioValueModel(title: "Inch", value: 'inch'),
              ],
              onChanged: (size) {
                // Update your cart or form
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                AppRouter.push(context, AppConstants.routeSelectMmgLevel);
              },
              child: Text('SAVE PREFERENCE'),
            ),
          ),
        ),
      ),
    );
  }
}
