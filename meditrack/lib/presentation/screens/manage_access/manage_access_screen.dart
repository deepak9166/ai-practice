import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/extensions/string_extensions.dart';
import 'package:meditrack/extension/keyboard_hide_extesion.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import '../../common_widgets/custom_search_bar.dart';
import 'give_full_access.dart';
import 'give_limit_access.dart';
import 'manage_access_profile.dart';

class ManageAccessScreen extends StatefulWidget {
  const ManageAccessScreen({super.key});

  @override
  State<ManageAccessScreen> createState() => _ManageAccessScreenState();
}

class _ManageAccessScreenState extends State<ManageAccessScreen> {
  List<AccessManageUsers> sharedList = [
    AccessManageUsers(
      name: 'Esther Howard',
      age: "25",
      gender: 'Female',
      accessType: 'Limited Access',
    ),
    AccessManageUsers(
      name: 'Robert Fox',
      age: "25",
      gender: 'Male',
      accessType: 'Limited Access',
    ),
    AccessManageUsers(
      name: 'Devon Lane',
      age: "25",
      gender: 'Female',
      accessType: 'Limited Access',
    ),
    AccessManageUsers(
      name: 'Leslie Alexander',
      age: "27",
      gender: 'Male',
      accessType: 'Limited Access',
    ),
    AccessManageUsers(
      name: 'Kathryn Murphy',
      age: "25",
      gender: 'Female',
      accessType: 'Limited Access',
    ),
  ];

  List<AccessManageUsers> recievedList = [
    AccessManageUsers(
      name: 'Devon Lane',
      age: "20",
      gender: 'Female',
      accessType: 'Limited Access',
    ),
    AccessManageUsers(
      name: 'Leslie Alexander',
      age: "21",
      gender: 'Male',
      accessType: 'Limited Access',
    ),
    AccessManageUsers(
      name: 'Kathryn Murphy',
      age: "26",
      gender: 'Female',
      accessType: 'Limited Access',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Access')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 1.0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              tabs: const [
                Tab(text: 'Give/Shared'),
                Tab(text: 'Recieved'),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  tabGiveOrSharedView(sharedList),
                  tabRecievedView(recievedList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabGiveOrSharedView(List<AccessManageUsers> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerticalSpacing.medium,
        // Search
        CustomSearchBarView(
          hintText: 'Search Name',
          onPressed: () {
            context.hideKeyboard();
          },
        ),

        VerticalSpacing.small,

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'App Users',
            style: TextTheme.of(context).labelSmall?.copyWith(fontSize: 14),
          ),
        ),

        Expanded(
          child: ListView.separated(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return usersCard(index, data[index], isShared: true);
            },
            separatorBuilder: (context, index) => Divider(
              height: 0,
              indent: 20,
              endIndent: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget tabRecievedView(List<AccessManageUsers> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerticalSpacing.mediumExtra,
        // Search
        CustomSearchBarView(
          hintText: 'Search Name',
          onPressed: () {
            context.hideKeyboard();
          },
        ),

        VerticalSpacing.small,

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'App Users',
            style: TextTheme.of(context).labelSmall?.copyWith(fontSize: 14),
          ),
        ),

        Expanded(
          child: ListView.separated(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return usersCard(index, data[index], isShared: false);
            },
             separatorBuilder: (context, index) => Divider(
              height: 0,
              indent: 20,
              endIndent: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget usersCard(int index, AccessManageUsers item, {bool isShared = false}) {
    Color getLightColorByIndex(int index) {
      final r = 200 + (index * 30) % 56;
      final g = 200 + (index * 50) % 56;
      final b = 200 + (index * 70) % 56;

      return Color.fromARGB(255, r, g, b);
    }

    return ListTile(
      onTap: () {
        // open profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageProfileAccess(
              profileColor: getLightColorByIndex(index),
              item: item,
              isRecieved:isShared == false ,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundColor: getLightColorByIndex(index),
        child: Text(
          item.name.firstTwoLetter,
          style: TextTheme.of(context).titleLarge,
        ),
      ),
      title: Text(item.name, style: TextTheme.of(context).labelLarge),
      subtitle: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${item.age} Years',
                  style: TextTheme.of(context).bodySmall,
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
                Text(item.gender, style: TextTheme.of(context).bodySmall),
              ],
            ),
          ),
          if (isShared)
            Row(
              children: [
                SizedBox(
                  height: 26,
                  width: 103,
                  child: CustomButtonSmall(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    borderColor: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      //GiveLimitAccess
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiveLimitAccess(),
                        ),
                      );
                    },
                    text: 'Limited Access',
                  ),
                ),
                SizedBox(width: 4),
                SizedBox(
                  height: 26,
                  width: 103,
                  child: CustomButtonSmall(
                    backgroundColor: Theme.of(context).colorScheme.onSecondary,
                    onPressed: () {
                      //FullAccess
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiveFullAccess(),
                        ),
                      );
                    },
                    text: 'Full Access',
                  ),
                ),
              ],
            ),
        ],
      ),
      // isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [SmartImageView(SvgImageId.iconNextSmall.path)],
      ),
    );
  }

}

class AccessManageUsers {
  String name;
  String gender;
  String age;
  String accessType;

  AccessManageUsers({
    required this.accessType,
    required this.age,
    required this.gender,
    required this.name,
  });
}
