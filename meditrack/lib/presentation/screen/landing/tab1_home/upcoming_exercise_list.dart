import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../common_model/exercise_model.dart';
import '../../../common_widgets/medicine_card.dart';

class UpcomingMedicineList extends StatelessWidget {
  final Stream<List<MedicineModel>> stream;

  const UpcomingMedicineList({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 122,
      child: StreamBuilder<List<MedicineModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: snapshot.hasError
                  ? Text('Error', style: Theme.of(context).textTheme.bodySmall)
                  : SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
            );
          }
          final list = snapshot.data!;
          if (list.isEmpty) {
            return Center(
              child: Text(
                'No upcoming medicines.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
            );
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = list[index];
              return SizedBox(
                width: 170,
                child: MedicineCard(
                  cardType: MedicineCardType.small,
                  item: item,
                  onAction: () {
                    if (item.medicineId != null) {
                      AppRouter.push(
                        context,
                        AppConstants.routeMedicineDetail,
                        extra: item.medicineId,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
