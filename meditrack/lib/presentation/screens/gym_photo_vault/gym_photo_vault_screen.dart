import 'package:flutter/material.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/extension/keyboard_hide_extesion.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/user_image_upload_bottom_sheet.dart';

import '../../../enum/filter_enum.dart';
import '../../../log/app_logs.dart';
import '../../common_widgets/custom_search_bar.dart';
import '../../common_widgets/spacing_widgets.dart';
import '../landing_app/tab_excercise/filter/exercise_filter.dart';

class GymPhotoVaultScreen extends StatefulWidget {
  const GymPhotoVaultScreen({super.key});

  @override
  State<GymPhotoVaultScreen> createState() => _GymPhotoVaultScreenState();
}

class _GymPhotoVaultScreenState extends State<GymPhotoVaultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GymPhotoVault')),
      body: Column(
        children: [
          VerticalSpacing.mediumExtra,
          // Search
          CustomSearchBarView(
            hintText: 'Search Name',
            onPressed: () {
              context.hideKeyboard();
            },
          ),

          VerticalSpacing.mediumExtra,

          // Upload button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomButton(
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => UserImageUploadBottomSheet(
                    onUpload: (imageUrl, msgLevel) {
                      appLog('Image URL: $imageUrl, MSG Level: $msgLevel');
                    },
                  ),
                );
              },
              text: "UPLOAD PHOTO",
            ),
          ),

          VerticalSpacing.medium,
          // Excercise
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ExerciseFilter(
              onSelectFilter: (type) {
                appLog('Select value : -- $type');
              },
              allowFilter: [FilterTypes.mmg, FilterTypes.msg],
            ),
          ),
          VerticalSpacing.small,

          // Photo Vault List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(left: 20),
              itemBuilder: (context, index) => Text(
                '11 March 2026',
                style: TextTheme.of(context).labelLarge?.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSecondaryFixedVariant,
                ),
              ),
              separatorBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(top: 5, bottom: 10),
                child: SizedBox(
                  height: 195,
                  child: ListView.separated(
                    itemCount: 3,
                    scrollDirection: Axis.horizontal,

                    itemBuilder: (context, index) => SizedBox(
                      width: 169,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SmartImageView(PngImageId.gymPhoto.path, height: 165),
                          SizedBox(height: 5),
                          Text(
                            'Lats, Rear Deltoids',
                            style: TextTheme.of(
                              context,
                            ).labelLarge?.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    separatorBuilder: (context, index) => SizedBox(width: 8),
                  ),
                ),
              ),
              itemCount: 8,
            ),
          ),
        ],
      ),
    );
  }
}
