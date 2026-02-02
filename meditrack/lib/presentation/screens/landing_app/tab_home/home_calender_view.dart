import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../common_model/calender_dates_model.dart';

class HomeCalenderView extends ConsumerStatefulWidget {
  final List<MarkDatesModel> markDatesExcercise;

  const HomeCalenderView({super.key, required this.markDatesExcercise});

  @override
  ConsumerState<HomeCalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends ConsumerState<HomeCalenderView> {
  late CalendarFormat _calendarFormat;
  List<DateTime> specialDates = [];
  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.week;
    specialDates = widget.markDatesExcercise.map((e) => e.date).toList();
  }

  late final PageController pageControllerCalender;

  @override
  Widget build(BuildContext context) {
    final local = ref.watch(languageProvider);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TableCalendar(
        locale: local.languageCode,
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2190, 3, 14),
        focusedDay: DateTime.now(),
        onDaySelected: (selectedDay, focusedDay) {
          appLog('You tap on $selectedDay date');
        },
        onCalendarCreated: (pageController) {
          pageControllerCalender = pageController;
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Monthly',
          CalendarFormat.week: 'Weekly',
           CalendarFormat.twoWeeks: 'Year',
        },
        headerStyle: const HeaderStyle(
          headerPadding: EdgeInsets.all(0),
          formatButtonVisible: false, // Hide default button
          titleCentered: false,
          leftChevronVisible: false,
          rightChevronVisible: false,
        ),
        calendarStyle: CalendarStyle(
          cellAlignment: Alignment.center,
          selectedDecoration: BoxDecoration(),
          outsideDaysVisible: false,

          defaultDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
          ),
          weekendDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        daysOfWeekHeight: 26,
        rowHeight: 50,
        daysOfWeekStyle: DaysOfWeekStyle(
          decoration: BoxDecoration(color: Colors.white),
          dowTextFormatter: (date, locale) =>
              getDayNameFromNumber(date.weekday).toString(),
          weekdayStyle: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600),
          weekendStyle: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600),
        ),

        calendarFormat: _calendarFormat,
        currentDay: DateTime.now(),

        calendarBuilders: CalendarBuilders(
          headerTitleBuilder: (context, day) => _headerTileView(context, day),

          selectedBuilder: _selectedDayBuilder,

          todayBuilder: _todayDayBuilder,
        ),

        selectedDayPredicate: (day) {
          return specialDates.any((special) => isSameDay(day, special));
        },
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String getDayNameFromNumber(int weekdayNumber) {
    const List<String> days = [
      '',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    if (weekdayNumber < 1 || weekdayNumber > 7) {
      return 'NA';
    }

    return days[weekdayNumber].toUpperCase();
  }

  _headerTileView(BuildContext context, DateTime day) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat.yMMMM().format(day),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontSize: 14),
            ),
            const SizedBox(width: 8),
            InkWell(
              radius: 12,
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                pageControllerCalender.previousPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOutSine,
                );
              },
              child: SmartImageView(SvgImageId.iconBack.path),
            ),
            InkWell(
              radius: 12,
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                pageControllerCalender.nextPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOutSine,
                );
              },
              child: SmartImageView(SvgImageId.iconNext.path),
            ),
            // Icon(Icons.arrow_forward_ios,size: 10,),
            Spacer(),

            MenuAnchor(
              alignmentOffset: Offset(-16, -0),
              builder: (context, menuController, child) {
                return TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.only(left: 8),
                  ),
                  onPressed: () {
                    if (menuController.isOpen) {
                      menuController.close();
                    } else {
                      menuController.open();
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        _calendarFormat == CalendarFormat.month
                            ? 'Monthly'
                            : 'Weekly',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      SmartImageView(SvgImageId.iconDownArrow.path),
                    ],
                  ),
                );
              },
              style: MenuStyle(
                elevation: WidgetStatePropertyAll<double>(1),
                visualDensity: VisualDensity(horizontal: 1.5),
                backgroundColor: const WidgetStatePropertyAll<Color>(
                  Colors.white,
                ),
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.all(0),
                ),
              ),

              useRootOverlay: true,
              menuChildren: [
                MenuItemButton(
                  style: MenuItemButton.styleFrom(
                    padding: EdgeInsets.all(0),

                    visualDensity: VisualDensity(vertical: -4, horizontal: 4),
                  ),
                  onPressed: () {
                    setState(() => _calendarFormat = CalendarFormat.week);
                  },

                  child: Text(
                    'Weekly',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                MenuItemButton(
                  style: MenuItemButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    visualDensity: VisualDensity(vertical: -4, horizontal: 4),
                  ),
                  onPressed: () {
                    setState(() => _calendarFormat = CalendarFormat.month);
                  },

                  child: Text(
                    'Monthly',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _selectedDayBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    bool isBestPerformOfDay = checkPerformDate(day);
    int countDays = foundWorkoutCount(day);
    return Center(
      child: Visibility(
        visible: isBestPerformOfDay,
        replacement: Align(
          alignment: Alignment.center,
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimaryFixed,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSecondaryFixed,
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    day.day.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < countDays; i++)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 0.5),
                            height: 3,
                            width: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SmartImageView(SvgImageId.iconBlackStar.path),
            Align(
              alignment: Alignment.center,
              child: Text(
                day.day.toString(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondaryFixed,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _todayDayBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    return Center(
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            day.day.toString(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryFixed,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // Check best perfomace of the day
  bool checkPerformDate(DateTime day) {
    var foundDate = widget.markDatesExcercise.indexWhere(
      (e) =>
          e.date.day == day.day &&
          e.date.month == day.month &&
          e.date.year == day.year,
    );
    return foundDate == -1
        ? false
        : (widget.markDatesExcercise[foundDate].isBestPerformOfDay ?? false);
  }

  // Check workout count per day
  int foundWorkoutCount(DateTime day) {
    var foundDate = widget.markDatesExcercise.indexWhere(
      (e) =>
          e.date.day == day.day &&
          e.date.month == day.month &&
          e.date.year == day.year,
    );
    return foundDate == -1
        ? 0
        : widget.markDatesExcercise[foundDate].workoutCount;
  }
}
