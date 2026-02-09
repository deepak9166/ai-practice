// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:meditrack/config/svg_config.dart';
// import 'package:meditrack/log/app_logs.dart';
// import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
// import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/constants/language_keys.dart';
// import '../../../../core/router/app_router.dart';
// import '../../../common_model/calender_dates_model.dart';
// import '../../../common_model/exercise_model.dart';
// import '../../../common_widgets/app_drawer.dart';
// import '../../../common_widgets/medicine_card.dart';
// import 'home_calender_view.dart';
// import '../../../screen/landing/tab1_home/upcoming_exercise_list.dart';
// import 'workout_templates_list.dart';

// class OldHomeScreen extends StatefulWidget {
//   const OldHomeScreen({super.key});

//   @override
//   State<OldHomeScreen> createState() => _OldHomeScreenState();
// }

// class _OldHomeScreenState extends State<OldHomeScreen>
//     with AutomaticKeepAliveClientMixin {
//   // @override
//   // void initState() {
//   //  super.initState();
//   //}

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Scaffold(
//       appBar: AppBar(
//         foregroundColor: Colors.white,
//         backgroundColor: Theme.of(context).primaryColor,
//         systemOverlayStyle: const SystemUiOverlayStyle(
//           statusBarIconBrightness: Brightness.light,
//           statusBarBrightness: Brightness.dark,
//         ),
//         title: Text(
//           LanguageKeys.home.tr(),
//           style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
//         ),
//         actions: [
//           // IconButton(
//           //   icon: const Icon(Icons.settings),
//           //   onPressed: () {
//           //     AppRouter.push(context, AppConstants.routeSettings);
//           //   },
//           // ),
//           IconButton(
//             icon: SmartImageView(SvgImageId.calendar.path, color: Colors.white),
//             onPressed: () {
//               AppRouter.push(context, AppConstants.routeCalender);
//             },
//           ),
//           IconButton(
//             icon: SmartImageView(SvgImageId.notification.path),
//             onPressed: () {
//               AppRouter.push(context, AppConstants.routeNotification);
//             },
//           ),
//           SizedBox(width: 20),
//         ],
//       ),
//       drawer: Drawer(
//         width: MediaQuery.of(context).size.width * .75,
//         child: const AppDrawer(),
//       ),

//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             VerticalSpacing.mediumExtra,
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: HomeCalenderView(
//                 markDatesExcercise: [
//                   MarkDatesModel(date: DateTime(2025, 12, 30), workoutCount: 1),
//                   MarkDatesModel(date: DateTime(2026, 1, 8), workoutCount: 2),
//                   MarkDatesModel(date: DateTime(2026, 1, 9), workoutCount: 1),
//                   MarkDatesModel(
//                     date: DateTime(2026, 1, 10),
//                     workoutCount: 3,
//                     isBestPerformOfDay: true,
//                   ),
//                   MarkDatesModel(date: DateTime(2026, 1, 11), workoutCount: 4),
//                 ],
//               ),
//             ),

//             VerticalSpacing.mediumExtra,
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 'Today’s Workout',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),

//             VerticalSpacing.small,

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: MedicineCard(
//                 item: MedicineModel(
//                   date: DateTime.now().toIso8601String(),
//                   type: 'Chest, Arms, Shoulders',
//                   name: 'Upper Body Strength',
//                   previewImages: [],
//                   status: '',
//                 ),
//                 cardType: MedicineCardType.medium,
//                 onAction: () {
//                   appLog('Add navigation for Open full detail');
//                   AppRouter.push(context, AppConstants.routeTodayWorkout);
//                 },
//               ),
//             ),
//             VerticalSpacing.mediumExtra,
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 'Upcoming Workout',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),
//             VerticalSpacing.small,

//             Padding(
//               padding: const EdgeInsets.only(left: 20),
//               child: UpcomingMedicineList(),
//             ),
//             VerticalSpacing.mediumExtra,
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 children: [
//                   Text(
//                     'Workout Templates',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   Spacer(),
//                   InkWell(
//                     onTap: () {
//                       appLog('open for see all');
//                     },
//                     child: Text(
//                       'See All',
//                       style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                         fontSize: 14,
//                         color: Theme.of(context).primaryColor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             VerticalSpacing.small,

//             Padding(
//               padding: const EdgeInsets.only(left: 20),
//               child: WorkoutTemplatesList(),
//             ),
//             VerticalSpacing.small,
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }
// }
