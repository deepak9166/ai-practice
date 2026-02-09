import 'package:flutter/material.dart';
import 'package:meditrack/core/extensions/string_extensions.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/screens/manage_access/manage_access_screen.dart';

import '../../../config/svg_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../log/app_logs.dart';
import '../../common_model/dropdown_value_model.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/smart_image_view.dart';
import 'photo_access_manange.dart';
import 'workout_list.dart';

class ManageProfileAccess extends StatelessWidget {
  final Color profileColor;
  final AccessManageUsers item;
  final bool isRecieved;
  const ManageProfileAccess({
    super.key,
    required this.profileColor,
    required this.item,
    required this.isRecieved,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                VerticalSpacing.mediumExtra,
                CircleAvatar(
                  backgroundColor: profileColor,
                  radius: 50,
                  child: Text(
                    item.name.firstTwoLetter,
                    style: TextTheme.of(context).headlineMedium,
                  ),
                ),
                VerticalSpacing.medium,
                Text(item.name, style: TextTheme.of(context).headlineMedium),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${item.age} Years',
                      style: TextTheme.of(
                        context,
                      ).bodySmall?.copyWith(fontSize: 14),
                    ),
                    Center(
                      child: Container(
                        height: 3,
                        width: 3,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryFixedVariant,
                        ),
                      ),
                    ),
                    Text(
                      item.gender,
                      style: TextTheme.of(
                        context,
                      ).bodySmall?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                VerticalSpacing.smallXs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 26,
                      width: 103,
                      child: CustomButtonSmall(
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        borderColor: Theme.of(context).primaryColor,
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {},
                        text: 'Limited Access',
                      ),
                    ),
                    SizedBox(width: 6),
                    SizedBox(
                      height: 26,
                      width: 103,
                      child: CustomButtonSmall(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondary,
                        onPressed: () {},
                        text: 'Full Access',
                      ),
                    ),
                  ],
                ),
                VerticalSpacing.mediumExtra,
              ],
            ),
          ),
          if (isRecieved) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Note',style: TextTheme.of(context).titleSmall, textAlign: TextAlign.left,),
            ),
             VerticalSpacing.smallXs,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '''The Back Extension is a powerful bodyweight or equipment-assisted movement that targets the lower back. It improves spinal stability, posture, and core strength. Often used in rehabilitation and strength programs, it's a staple for reducing lower back strain.''',
              ),
            ),
             VerticalSpacing.medium,
            options(),
          ],
        ],
      ),
    );
  }

  Widget options() {
    List<DropdownValueModel> menu = [
      DropdownValueModel(
        title: 'Muscle Measurement',
        icon: SvgImageId.measurment.path,
        value: '1',
      ),
      DropdownValueModel(
        title: 'Photos',
        icon: SvgImageId.photo.path,
        value: '2',
      ),
      DropdownValueModel(
        title: 'Workout Lists',
        icon: SvgImageId.workoutList.path,
        value: '3',
      ),
    ];
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: menu.length,
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        var menuItem = menu[index];
        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          leading: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SmartImageView(menuItem.icon, height: 30, width: 30),
          ),
          title: Text(menuItem.title, style: TextTheme.of(context).titleSmall),
          trailing: SmartImageView(SvgImageId.iconNextSmall.path),
          onTap: () {
            appLog('handle value ${menuItem.value}');
            if (menuItem.value == "1") {
              AppRouter.push(context, AppConstants.routeMyMeasurement);
            } else if (menuItem.value == "2") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PhotoAccessManange()),
              );
            } else if (menuItem.value == "3") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkoutList()),
              );

              //WorkoutList
            }
          },
        );
      },
      separatorBuilder: (context, index) => Divider(
        height: 0,
      ),
    );
  }
}
