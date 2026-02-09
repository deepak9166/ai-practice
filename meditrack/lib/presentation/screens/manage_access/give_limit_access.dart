import 'package:flutter/material.dart';
import 'package:meditrack/config/png_config.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../log/app_logs.dart';
import '../../common_model/exercise_model.dart';
import '../../common_widgets/medicine_card.dart';

class GiveLimitAccess extends StatelessWidget {
  const GiveLimitAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Give Limited Access of'),
        bottom: PreferredSize(
          preferredSize: Size(0, 30),
          child: Container(
            height: 28,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
            ),
            child: Center(
              child: Text(
                'You can share upto 10 list in limited access',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: 10,
          itemBuilder: (context, index) {
            return MedicineCard(
              item: MedicineModel(
                date: DateTime.now().toIso8601String(),
                type: 'Chest, Arms, Shoulders',
                name: 'Upper Body Strength',
                // previewImages: [
                //   PngImageId.yoga.path,
                //   PngImageId.yoga.path,
                //   PngImageId.yoga.path,
                // ],
                status: '',
              ),
              cardType: MedicineCardType.normal,
              onAction: () {
                appLog('Add navigation for Open full detail'); // TODO:
                AppRouter.push(context, AppConstants.routeWorkoutSummary);
              },
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 8),
        ),
      ),
    );
  }
}
