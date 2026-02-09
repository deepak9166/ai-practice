import 'package:flutter/material.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import '../../../config/svg_config.dart';
import '../../../core/utils/share_helper.dart';
import '../../common_widgets/smart_image_view.dart';
import 'engagement_analytics_screen.dart';

class WorkoutSummary extends StatefulWidget {
  final bool isBestPerformOfDay;
  const WorkoutSummary({super.key, required this.isBestPerformOfDay});

  @override
  State<WorkoutSummary> createState() => _WorkoutSummaryState();
}

class _WorkoutSummaryState extends State<WorkoutSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: .5,
        leading: CloseButton(),
        title: Text('Workout Summary'),
        actions: [
          IconButton(
            onPressed: () {
              ShareHelper.shareMessage("Hello");
            },
            icon: SmartImageView(
              SvgImageId.iconShare.path,
              width: 24,
              height: 24,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: ListView(
        children: [
          _perfomaceCard(),
          VerticalSpacing.mediumExtra,
          _mmgTable(),
          VerticalSpacing.mediumExtra,
          _msgTable(),
          VerticalSpacing.mediumExtra,
          _trainingVolume(),
          VerticalSpacing.mediumExtra,
          _engagementAnalytics('Muscle Group Engagement Analytics'),
          VerticalSpacing.mediumExtra,
          _engagementAnalytics('MSG Muscle Group Engagement Analytics'),
          VerticalSpacing.mediumExtra,
          _notes(),
        ],
      ),
    );
  }

  Widget _completedLabel() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(color: Color(0xffD5FFDE)),
      child: Center(
        child: Text('Completed', style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }

  Widget _perfomaceCard() {
    return Visibility(
      visible: widget.isBestPerformOfDay == false,

      /// for best performance day
      replacement: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xff996FD6), Color(0xff8351CB)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerticalSpacing.mediumExtra,
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
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                ),
              ],
            ),
            VerticalSpacing.small,
            Text(
              'Upper Body Strength',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            VerticalSpacing.small,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SmartImageView(
                  SvgImageId.clockIcon.path,
                  height: 16,
                  width: 16,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                SizedBox(width: 5),
                Text(
                  'Sun, Dec 7', //'Sun, Dec 7'
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
                SizedBox(width: 15),
                SmartImageView(
                  SvgImageId.goalIcon.path,
                  height: 16,
                  width: 16,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                SizedBox(width: 5),
                Text(
                  'Chest, Arms, Shoulders',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  repersentSmallCardVerient2(
                    'Exercises\nperformed',
                    "20",
                    SvgImageId.iconDumbleDark.path,
                  ),
                  repersentSmallCardVerient2(
                    'Total\nReps',
                    '100',
                    SvgImageId.iconRepsDark.path,
                  ),
                  repersentSmallCardVerient2(
                    'Total Training\nVolume',
                    '15600',
                    SvgImageId.iconTrainingDark.path,
                  ),
                ],
              ),
            ),
            VerticalSpacing.extraLarge,
            SmartImageView(SvgImageId.simplificationDark.path),
          ],
        ),
      ),

      /// normal
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _completedLabel(),
          VerticalSpacing.mediumExtra,
          Text(
            'Upper Body Strength',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          VerticalSpacing.small,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SmartImageView(SvgImageId.clockIcon.path, height: 16, width: 16),
              SizedBox(width: 5),
              Text(
                'Sun, Dec 7',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              SizedBox(width: 15),
              SmartImageView(SvgImageId.goalIcon.path, height: 16, width: 16),
              SizedBox(width: 5),
              Text(
                'Chest, Arms, Shoulders',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                repersentSmallCard(
                  'Exercises\nperformed',
                  "20",
                  SvgImageId.iconDumble.path,
                ),
                repersentSmallCard(
                  'Total\nReps',
                  '100',
                  SvgImageId.iconReps.path,
                ),
                repersentSmallCard(
                  'Total Training\nVolume',
                  '15600',
                  SvgImageId.iconTraining.path,
                ),
              ],
            ),
          ),
          VerticalSpacing.extraLarge,
          SmartImageView(SvgImageId.simplification.path),
          VerticalSpacing.extraLarge,
        ],
      ),
    );
  }

  Widget repersentSmallCard(String title, String value, String image) {
    return Column(
      children: [
        SmartImageView(image, height: 45, width: 45),
        SizedBox(height: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryFixedVariant,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 16),
        ),
      ],
    );
  }

  Widget repersentSmallCardVerient2(String title, String value, String image) {
    return Column(
      children: [
        SmartImageView(image, height: 45, width: 45),
        SizedBox(height: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 16,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ],
    );
  }

  Widget _mmgTable() {
    return CustomTableComponant(
      highlightColumn: 0,
      columnFlex: [2, 1, 1, 1],
      heading: 'MMG Engagement',
      headerRowValue: ["Muscles Worked", "Exercises", "Reps", "Valume"],
      rowValue: [
        ["Upper Body", "04", "100", "6800"],
        ["Lower Body", "04", "80", "6800"],
      ],
    );
  }

  Widget _msgTable() {
    return CustomTableComponant(
      highlightColumn: 0,
      columnFlex: [2, 1, 1, 1],
      heading: 'MSG Engagement',
      headerRowValue: ["Muscles Worked", "Exercises", "Reps", "Valume"],
      rowValue: [
        ["Upper Chest", "04", "100", "6800"],
        ["Middle Chest", "04", "80", "6800"],
        ["Lower Chest", "03", "80", "6800"],
        ["Front Deltoid", "03", "80", "6800"],
        ["Lats", "04", "03", "6800"],
      ],
    );
  }

  Widget _trainingVolume() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Exercise-Level Training Volume',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ExpansionTile(
            backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            collapsedBackgroundColor: Theme.of(
              context,
            ).colorScheme.onSecondaryContainer,
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Row(
              children: [
                SmartImageView(
                  SvgImageId.iconTraining.path,
                  height: 55,
                  radius: 26.5,
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Training Volume',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    Text(
                      '15600',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
            children: [
              Divider(
                height: 2,
                thickness: 2,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              for (var item in [1, 2, 3, 4, 5])
                Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Bench press',
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Sets × Reps × Weight',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(fontSize: 12),
                      ),
                      trailing: Text(
                        '600',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontSize: 16),
                      ),
                    ),
                    Divider(
                      height: 0,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _engagementAnalytics(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Spacer(),
              InkWell(
                radius: 8,
                onTap: () {
                  _showEngagementAnalyticsPopup();
                  appLog('Open dilog');
                },
                child: SmartImageView(
                  SvgImageId.diagram.path,
                  height: 16,
                  width: 16,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 15),

        GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            mainAxisExtent: 74,
          ),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upper Chest',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryFixedVariant,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '120',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _notes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 20),
          ),
          Text(
            '''The Back Extension is a powerful bodyweight or equipment-assisted movement that targets the lower back. It improves spinal stability, posture, and core strength. Often used in rehabilitation and strength programs, it's a staple for reducing lower back strain.''',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  void _showEngagementAnalyticsPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.all(0),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content: EngagementAnalyticsScreen(),
      ),
    );
  }
}

class CustomTableComponant extends StatelessWidget {
  final String heading;
  final List<String> headerRowValue;
  final List<List<String>> rowValue;
  final List<double> columnFlex;
  final int highlightColumn;

  const CustomTableComponant({
    super.key,
    required this.heading,
    required this.headerRowValue,
    required this.rowValue,
    this.highlightColumn = -1,
    this.columnFlex = const [1, 1, 1, 1],
  });
  @override
  Widget build(BuildContext context) {
    List<List<String>> generatedRow = [];

    for (var rItem in rowValue) {
      List<String> row = List<String>.filled(headerRowValue.length, '');

      for (int i = 0; i < rItem.length && i < headerRowValue.length; i++) {
        row[i] = rItem[i].toString();
      }

      generatedRow.add(row);
    }

    Map<int, TableColumnWidth>? columnWidth = {};

    for (int i = 0; i < headerRowValue.length; i++) {
      var flex = (i >= 0 && i < columnFlex.length) ? columnFlex[i] : 1;
      columnWidth.putIfAbsent(i, () => FlexColumnWidth(flex.toDouble()));
    }

    print(columnWidth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(heading, style: Theme.of(context).textTheme.titleLarge),
          ),
        if (heading.isNotEmpty) SizedBox(height: 15),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Table(
            columnWidths: columnWidth,
            border: TableBorder.symmetric(
              // color: Theme.of(context).colorScheme.outline,
              // width: 1,
              borderRadius: BorderRadius.circular(8),
              outside: BorderSide(
                width: 1,
                color: Theme.of(context).colorScheme.outline,
              ),
              inside: BorderSide(
                width: 1,
                color: Theme.of(context).colorScheme.outline,
                style: BorderStyle.none,
              ),
              // style: BorderStyle.none,
            ),

            children: [
              // header row
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                children: [
                  for (var head in headerRowValue)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        head,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                      ),
                    ),
                ],
              ),

              for (int rowIndex = 0; rowIndex < generatedRow.length; rowIndex++)
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  children: [
                    for (int i = 0; i < generatedRow[rowIndex].length; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Text(
                              generatedRow[rowIndex][i],
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: i == highlightColumn
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSecondaryFixedVariant,
                                  ),
                            ),
                          ),
                          if (rowIndex != generatedRow.length - 1)
                            Divider(height: 0),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
