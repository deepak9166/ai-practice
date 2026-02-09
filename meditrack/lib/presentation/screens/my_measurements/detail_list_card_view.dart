import 'package:flutter/material.dart';

import '../../../config/svg_config.dart';
import '../../common_widgets/smart_image_view.dart';
import '../../common_widgets/spacing_widgets.dart';

class DetailListCardView extends StatelessWidget {
  final String title;
  final List<ListValueModel> data;
  final Function(ListValueModel value) onTap;
  const DetailListCardView({
    super.key,
    required this.title,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextTheme.of(context).titleSmall?.copyWith(
            fontSize: 18,
            color: Theme.of(context).primaryColor,
          ),
        ),

        VerticalSpacing.small,

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            borderRadius: BorderRadius.circular(9),
          ),
          child: ListView.separated(
            padding: EdgeInsets.all(0),
            itemBuilder: (context, index) {
              var item = data[index];
              return ListTile(
                onTap: () => onTap(item),
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: SmartImageView(
                  SvgImageId.iconMiter.path,
                  height: 24,
                  width: 24,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextTheme.of(context).titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.value,
                      style: TextTheme.of(context).titleMedium?.copyWith(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
                trailing: SmartImageView(
                  SvgImageId.iconNext.path,
                  height: 24,
                  width: 24,
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(
              height: 0,
              color: Theme.of(context).scaffoldBackgroundColor,
              thickness: 2,
            ),
            itemCount: data.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
      ],
    );
  }
}

class ListValueModel {
  final String title;
  final String value;
  final String icon;

  ListValueModel({
    required this.title,
    required this.value,
    required this.icon,
  });
}
