import 'package:flutter/material.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/extension/date_time_formate_extesion.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/common_widgets/status_label_widget.dart';

import '../common_model/exercise_model.dart';
import 'preview_images.dart';

enum ExeciseCardType { small, medium, normal, bestPerformDay }

class ExerciseCard extends StatelessWidget {
  final ExerciseModel item;
  final Function()? onAction;
  final void Function(Offset details)? onTopBtnTapped;
  final String? buttonIcon;
  final ExeciseCardType cardType;
  const ExerciseCard({
    super.key,
    required this.item,
    this.onAction,
    this.onTopBtnTapped,
    this.buttonIcon,
    this.cardType = ExeciseCardType.normal,
  });

  @override
  Widget build(BuildContext context) {
    bool isMediumCard = ExeciseCardType.medium == cardType;
    bool isSmallCard = ExeciseCardType.small == cardType;
    bool isNormalCard = ExeciseCardType.normal == cardType;
    bool isBestPerformOfDay = ExeciseCardType.bestPerformDay == cardType;

    if (isSmallCard) {
      return Container(
        padding: EdgeInsets.all(14),
        decoration: isBestPerformOfDay
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: RadialGradient(
                  colors: [Color(0xff996FD6), Color(0xff8351CB)],
                ),
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBestPerformOfDay)
              Row(
                children: [
                  SmartImageView(
                    PngImageId.starReward.path,
                    height: 44,
                    width: 44,
                  ),
                  Text(
                    'Best Performance Day of\nThis Month',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontSize: 18)
                        .copyWith(
                          color: isBestPerformOfDay ? Colors.white : null,
                        ),
                  ),
                ],
              ),
            if (isBestPerformOfDay) VerticalSpacing.small,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontSize: 14)
                        .copyWith(
                          color: isBestPerformOfDay ? Colors.white : null,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4),
                if ((buttonIcon?.isNotEmpty) == true)
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      final box = context.findRenderObject() as RenderBox;

                      final offset = box.localToGlobal(
                        Offset(box.size.width - 50, 40),
                      );

                      onTopBtnTapped?.call(offset);
                    },
                    child: SmartImageView(buttonIcon),
                  ),
              ],
            ),
            VerticalSpacing.smallXs,
            Column(
              children: [
                Row(
                  children: [
                    SmartImageView(
                      SvgImageId.clockIcon.path,
                      height: 16,
                      width: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      item.date.toShortDayMonth(), //'Sun, Dec 7'
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontSize: 12)
                          .copyWith(
                            color: isBestPerformOfDay ? Colors.white : null,
                          ),
                    ),
                  ],
                ),
                VerticalSpacing.smallXs,

                Row(
                  children: [
                    SmartImageView(
                      SvgImageId.goalIcon.path,
                      height: 16,
                      width: 16,
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        item.msgNames,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontSize: 12)
                            .copyWith(
                              color: isBestPerformOfDay ? Colors.white : null,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            VerticalSpacing.smallXs,
            SizedBox(
              height: 20,
              child: Row(
                children: [
                  SizedBox(
                    child: PreviewImages(size: 19, images: item.previewImages),
                  ),
                  Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      if (onAction != null) {
                        onAction!();
                      } else {
                        appLog('Use action property for use this');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        children: [
                          Text(
                            'See',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondary,
                                )
                                .copyWith(
                                  color: isBestPerformOfDay
                                      ? Colors.white
                                      : null,
                                ),
                          ),
                          SmartImageView(
                            SvgImageId.iconNextSmall.path,
                            height: 16,
                            width: 16,
                            fit: BoxFit.contain,
                            color: isBestPerformOfDay ? Colors.white : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    // For large card,
    else {
      return Container(
        padding: EdgeInsets.all(14),
        decoration: isBestPerformOfDay
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: RadialGradient(
                  colors: [Color(0xff996FD6), Color(0xff8351CB)],
                ),
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBestPerformOfDay)
              Row(
                children: [
                  SmartImageView(
                    PngImageId.starReward.path,
                    height: 44,
                    width: 44,
                  ),
                  Text(
                    'Best Performance Day of\nThis Month',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontSize: 18)
                        .copyWith(
                          color: isBestPerformOfDay ? Colors.white : null,
                        ),
                  ),
                ],
              ),
            if (isBestPerformOfDay) VerticalSpacing.small,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontSize: isMediumCard ? 14 : 18)
                        .copyWith(
                          color: isBestPerformOfDay ? Colors.white : null,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4),
                if ((!isBestPerformOfDay &&
                    isMediumCard == false &&
                    item.status.isNotEmpty))
                  if (isNormalCard == false)
                    StatusLabelWidget(status: item.status),
                if ((buttonIcon?.isNotEmpty) == true)
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      final box = context.findRenderObject() as RenderBox;

                      final offset = box.localToGlobal(
                        Offset(box.size.width - 50, 40),
                      );

                      onTopBtnTapped?.call(offset);
                    },
                    child: SmartImageView(buttonIcon),
                  ),
              ],
            ),
            VerticalSpacing.small,
            Row(
              children: [
                SmartImageView(
                  SvgImageId.clockIcon.path,
                  height: 16,
                  width: 16,
                ),
                SizedBox(width: 5),
                Text(
                  item.date.toShortDayMonth(), //'Sun, Dec 7'
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontSize: 12)
                      .copyWith(
                        color: isBestPerformOfDay ? Colors.white : null,
                      ),
                ),
                SizedBox(width: 15),
                SmartImageView(SvgImageId.goalIcon.path, height: 16, width: 16),
                SizedBox(width: 5),
                Text(
                  item.msgNames,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontSize: 12)
                      .copyWith(
                        color: isBestPerformOfDay ? Colors.white : null,
                      ),
                ),
              ],
            ),
            VerticalSpacing.small,
            Visibility(
              visible: isMediumCard == false,
              replacement: SizedBox(
                height: 20,
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (onAction != null) {
                          onAction!();
                        } else {
                          appLog('Use action property for use this');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Row(
                          children: [
                            SmartImageView(
                              SvgImageId.playCircle.path,
                              height: 16,
                              width: 16,
                              fit: BoxFit.contain,
                              color: isBestPerformOfDay ? Colors.white : null,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Start workout',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondary,
                                  )
                                  .copyWith(
                                    color: isBestPerformOfDay
                                        ? Colors.white
                                        : null,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              child: SizedBox(
                height: (isNormalCard && onAction == null) ? 0 : 20,
                child: Row(
                  children: [
                    SizedBox(
                      child: PreviewImages(
                        size: 19,
                        images: item.previewImages,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (onAction != null) {
                          onAction!();
                        } else {
                          appLog('Use action property for use this');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Row(
                          children: [
                            Text(
                              'See Detail',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondary,
                                  )
                                  .copyWith(
                                    color: isBestPerformOfDay
                                        ? Colors.white
                                        : null,
                                  ),
                            ),
                            SmartImageView(
                              SvgImageId.iconNextSmall.path,
                              height: 16,
                              width: 16,
                              fit: BoxFit.contain,
                              color: isBestPerformOfDay ? Colors.white : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
