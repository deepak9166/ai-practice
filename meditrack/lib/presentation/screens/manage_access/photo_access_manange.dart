import 'package:flutter/material.dart';
import 'package:meditrack/extension/keyboard_hide_extesion.dart';

import '../../../config/png_config.dart';
import '../../common_widgets/custom_search_bar.dart';
import '../../common_widgets/image_preview.dart';
import '../../common_widgets/smart_image_view.dart';
import '../../common_widgets/spacing_widgets.dart';

class PhotoAccessManange extends StatefulWidget {
  const PhotoAccessManange({super.key});

  @override
  State<PhotoAccessManange> createState() => _PhotoAccessManangeState();
}

class _PhotoAccessManangeState extends State<PhotoAccessManange> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo')),
      body: Column(
        children: [
          VerticalSpacing.medium,
          // Search
          CustomSearchBarView(
            hintText: 'Search Name',
            onPressed: () {
              context.hideKeyboard();
            },
          ),

          VerticalSpacing.medium,

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
                          InkWell(
                            radius: 8,
                            onTap: () {
                              showPreviewBottomSheet(PngImageId.gymPhoto.path);
                            },
                            child: SmartImageView(
                              PngImageId.gymPhoto.path,
                              height: 165,
                            ),
                          ),
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

  void showPreviewBottomSheet(String path) {
    // showModalBottomSheet(
    //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    //   isScrollControlled: true,
    //   constraints: BoxConstraints(
    //     maxHeight: MediaQuery.of(context).size.height,
    //   ),
    //   context: context,
    //   builder: (context) => SafeArea(child: ImagePreview(imageUrl: path)),
    // );

    Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreview(imageUrl: path),));
  }
}
