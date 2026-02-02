import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../common_model/dropdown_value_model.dart';
import 'photo_access_manange.dart';
import 'workout_list.dart';

class GiveFullAccess extends StatelessWidget {
  const GiveFullAccess({super.key});

  @override
  Widget build(BuildContext context) {
    List<DropdownValueModel> menu = [
      DropdownValueModel(
        title: 'Muscle Measurement',
        icon: SvgImageId.measurment.path,
        value: '1',
      ),
      DropdownValueModel(
        title: 'Photos',
        icon: SvgImageId.phone.path,
        value: '2',
      ),
      DropdownValueModel(
        title: 'Workout Lists',
        icon: SvgImageId.workoutList.path,
        value: '3',
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Give Full Access of')),

      body: ListView.separated(
        itemCount: menu.length,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          var menuItem = menu[index];
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            leading: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SmartImageView(menuItem.icon, height: 30, width: 30),
            ),
            tileColor: Theme.of(context).colorScheme.onSecondaryContainer,
            title: Text(
              menuItem.title,
              style: TextTheme.of(context).titleSmall,
            ),
            trailing: SmartImageView(SvgImageId.iconNextSmall.path),
            onTap: () {
               appLog('handle value ${menuItem.value}');
              if (menuItem.value == "1") {
               AppRouter.push(context, AppConstants.routeMyMeasurement);
              } else if (menuItem.value == "2") {

                Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoAccessManange(),));
              } else if (menuItem.value == "3") {
                Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutList(),));

                //WorkoutList
              }
            },
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 10),
      ),
    );
  }
}
