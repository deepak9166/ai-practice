import 'package:flutter/material.dart';
import 'package:meditrack/core/extensions/string_extensions.dart';
import 'package:meditrack/extension/keyboard_hide_extesion.dart';
import 'package:meditrack/presentation/screens/received_access_request/received_request_profile.dart' show RequestAccessProfile;

import '../../../config/svg_config.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_search_bar.dart';
import '../../common_widgets/smart_image_view.dart';
import '../../common_widgets/spacing_widgets.dart';

class ReceivedAccessRequestScreen extends StatefulWidget {
  const ReceivedAccessRequestScreen({super.key});

  @override
  State<ReceivedAccessRequestScreen> createState() => _ReceivedAccessRequestScreenState();
}

class _ReceivedAccessRequestScreenState extends State<ReceivedAccessRequestScreen> {
  @override
  Widget build(BuildContext context) {
    List<RequestAccessUsers> requestData = [
      RequestAccessUsers(
        name: 'Esther Howard',
        age: "25",
        gender: 'Female',
        accessType: 'Limited Access',
      ),
      RequestAccessUsers(
        name: 'Robert Fox',
        age: "25",
        gender: 'Male',
        accessType: 'Limited Access',
      ),
      RequestAccessUsers(
        name: 'Devon Lane',
        age: "25",
        gender: 'Female',
        accessType: 'Limited Access',
      ),
      RequestAccessUsers(
        name: 'Leslie Alexander',
        age: "27",
        gender: 'Male',
        accessType: 'Limited Access',
      ),
      RequestAccessUsers(
        name: 'Kathryn Murphy',
        age: "25",
        gender: 'Female',
        accessType: 'Limited Access',
      ),
    ];

    return Scaffold(
      appBar: AppBar(elevation: 1, title: Text('Recieved Access Request')),
      body: Column(
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
              itemCount: requestData.length,
              itemBuilder: (context, index) {
                return usersCard(index, requestData[index], isShared: true);
              },
              separatorBuilder: (context, index) =>
                  Divider(height: 0, indent: 20, endIndent: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget usersCard(
    int index,
    RequestAccessUsers item, {
    bool isShared = false,
  }) {
    Color getLightColorByIndex(int index) {
      final r = 200 + (index * 30) % 56;
      final g = 200 + (index * 50) % 56;
      final b = 200 + (index * 70) % 56;

      return Color.fromARGB(255, r, g, b).withValues(alpha: 0.7);
    }

    return ListTile(
      onTap: () {
        // open profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestAccessProfile(
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
            padding: const EdgeInsets.symmetric(vertical: 5),
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
                Text('Limited Access', style: TextTheme.of(context).bodySmall),
              ],
            ),
          ),
          if (isShared)
            Row(
              children: [
                SizedBox(
                  height: 26,
                  width: 80,
                  child: CustomButtonSmall(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    borderColor: Color(0xffF14336),
                    textColor: Color(0xffF14336),
                    onPressed: () {
                      //GiveLimitAccess
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => GiveLimitAccess(),
                      //   ),
                      // );
                    },
                    text: 'Reject',
                  ),
                ),
                SizedBox(width: 4),
                SizedBox(
                  height: 26,
                  width: 80,
                  child: CustomButtonSmall(
                    backgroundColor: Color(0xff28B446),
                    onPressed: () {
                      //FullAccess
                      //  Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => GiveFullAccess(),
                      //   ),
                      // );
                    },
                    text: 'Accept',
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

class RequestAccessUsers {
  String name;
  String gender;
  String age;
  String accessType;

  RequestAccessUsers({
    required this.accessType,
    required this.age,
    required this.gender,
    required this.name,
  });
}
