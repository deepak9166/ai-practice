import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/constants/app_enums.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/extension/keyboard_hide_extesion.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/landing/tab_excercise/filter/exercise_filter.dart'
    show ExerciseFilter;

import '../../../../enum/filter_enum.dart' show FilterTypes;
import '../../../common_model/action_button.dart';
import '../../../common_widgets/custom_search_bar.dart';

import 'package:azlistview/azlistview.dart';

import '../../custom_exercise/view_model/custom_exercise_view_model.dart';

class ExcerciseScreen extends StatefulWidget {
  const ExcerciseScreen({super.key});

  @override
  State<ExcerciseScreen> createState() => _ExcerciseScreenState();
}

class _ExcerciseScreenState extends State<ExcerciseScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercises'),
        elevation: 1,
        actions: [
          ActionButtonAppBar(title: '+ EXERCISE', onPressed: () {}),
         
          SizedBox(width: 20),
        ],
      ),

      body: Column(
        children: [
          VerticalSpacing.mediumExtra,
          // Search
          CustomSearchBarView(
            hintText: 'Search Exercise',
            onPressed: () {
              context.hideKeyboard();
            },
          ),

          VerticalSpacing.mediumExtra,

          // Excercise
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ExerciseFilter(
              onSelectFilter: (type) {
                appLog('Select value : -- $type');
              },
              allowFilter: [
                FilterTypes.mmg,
                FilterTypes.msg,
                FilterTypes.equipments,
                FilterTypes.templateType,
                FilterTypes.customExcercise,
              ],
            ),
          ),
          VerticalSpacing.small,

          Expanded(child: ExcerciseListPage()),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ExcerciseListPage extends ConsumerStatefulWidget {
  const ExcerciseListPage({super.key});

  @override
  ConsumerState<ExcerciseListPage> createState() => _ExcerciseListPageState();
}

class _ExcerciseListPageState
    extends BaseConsumerState<ExcerciseListPage, CustomExerciseViewModel> {
  List<ExcerciseInfo> contactList = [];
  List<ExcerciseInfo> topList = [];

  @override
  void initState() {
    super.initState();
    // topList.add(
    //   ExcerciseInfo(
    //     name: '新的朋友',
    //     tagIndex: '↑',
    //     bgColor: Colors.orange,
    //     iconData: Icons.person_add,
    //     subName: "Idont",
    //   ),
    // );
    // topList.add(
    //   ExcerciseInfo(
    //     name: '群聊',
    //     tagIndex: '↑',
    //     bgColor: Colors.green,
    //     iconData: Icons.people,
    //   ),
    // );
    // topList.add(
    //   ExcerciseInfo(
    //     name: '标签',
    //     tagIndex: '↑',
    //     bgColor: Colors.blue,
    //     iconData: Icons.local_offer,
    //   ),
    // );
    // topList.add(
    //   ExcerciseInfo(
    //     name: '公众号',
    //     tagIndex: '↑',
    //     bgColor: Colors.blueAccent,
    //     iconData: Icons.person,
    //   ),
    // );
    loadData();
  }

  void loadData() async {
    //加载联系人列表

    for (var v in _list) {
      contactList.add(ExcerciseInfo.fromJson(v));
    }
    _handleList(contactList);
  }

  void _handleList(List<ExcerciseInfo> list) {
    if (list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = list[i].name;
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(contactList);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(contactList);

    // add topList.
    contactList.insertAll(0, topList);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(customExerciseViewModel);

    return Scaffold(
      body: AzListView(
        data: contactList,
        itemCount: contactList.length,
        itemBuilder: (BuildContext context, int index) {
          ExcerciseInfo model = contactList[index];
          return Utils.getWeChatListItem(
            context,
            model,
            defHeaderBgColor: Color(0xFFE5E5E5),
            viewmodel: viewModel,
          );
        },
        physics: BouncingScrollPhysics(),
        susItemBuilder: (BuildContext context, int index) {
          ExcerciseInfo model = contactList[index];
          if ('↑' == model.getSuspensionTag()) {
            return Container();
          }
          return Utils.getSusItem(context, model.getSuspensionTag());
        },
        indexBarData: ['↑', '☆', ...kIndexBarData],

        indexBarOptions: IndexBarOptions(
          needRebuild: true,
          ignoreDragCancel: true,

          downTextStyle: TextStyle(fontSize: 12, color: Colors.white),
          downItemDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          indexHintWidth: 120 / 2,
          indexHintHeight: 100 / 2,
          indexHintDecoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(PngImageId.bubbleGray.path),
              fit: BoxFit.contain,
            ),
          ),
          indexHintAlignment: Alignment.centerRight,
          indexHintChildAlignment: Alignment(-0.25, 0.0),
          indexHintOffset: Offset(-20, 0),
        ),
      ),
    );
  }

  @override
  CustomExerciseViewModel createViewModel() {
    return ref.read(customExerciseViewModel);
  }

  @override
  String screenName() {
    return "Excercise List Screen";
  }
}

class ExcerciseInfo extends ISuspensionBean {
  String name;
  String subName;
  String? tagIndex;
  String? namePinyin;

  Color? bgColor;
  IconData? iconData;

  String? img;
  String? id;
  String? firstletter;

  ExcerciseInfo({
    required this.name,
    required this.subName,
    this.tagIndex,
    this.namePinyin,
    this.bgColor,
    this.iconData,
    this.img,
    this.id,
    this.firstletter,
  });

  ExcerciseInfo.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      subName = json['subName'],
      img = json['img'],
      id = json['id']?.toString(),
      firstletter = json['firstletter'];

  Map<String, dynamic> toJson() => {
    //        'id': id,
    'name': name,
    'subName': subName,
    'img': img,
    //        'firstletter': firstletter,
    //        'tagIndex': tagIndex,
    //        'namePinyin': namePinyin,
    //        'isShowSuspension': isShowSuspension
  };

  @override
  String getSuspensionTag() => tagIndex!;

  @override
  String toString() => json.encode(this);
}

class Utils {
  static Widget getSusItem(
    BuildContext context,
    String tag, {
    double susHeight = 30,
  }) {
    if (tag == '★') {
      tag = '★ 热门城市';
    }
    return Container(
      height: susHeight,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 16.0),
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.centerLeft,
      child: Text(
        tag,
        softWrap: false,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  static Widget getWeChatListItem(
    BuildContext context,
    ExcerciseInfo model, {
    double susHeight = 40,
    Color? defHeaderBgColor,
    CustomExerciseViewModel? viewmodel,
  }) {
    return getWeChatItem(
      context,
      model,
      defHeaderBgColor: defHeaderBgColor,
      viewmodel: viewmodel,
    );
    //    return Column(
    //      mainAxisSize: MainAxisSize.min,
    //      children: <Widget>[
    //        Offstage(
    //          offstage: !(model.isShowSuspension == true),
    //          child: getSusItem(context, model.getSuspensionTag(),
    //              susHeight: susHeight),
    //        ),
    //        getWeChatItem(context, model, defHeaderBgColor: defHeaderBgColor),
    //      ],
    //    );
  }

  static Widget getWeChatItem(
    BuildContext context,
    ExcerciseInfo model, {
    Color? defHeaderBgColor,
    CustomExerciseViewModel? viewmodel,
  }) {
    DecorationImage? image;
    // if ((model.img ?? "").isNotEmpty) {
    //   image = DecorationImage(
    //     image: AssetImage(PngImageId.yoga.path),
    //     fit: BoxFit.contain,
    //   );
    // }

    image = DecorationImage(
      image: AssetImage(PngImageId.yoga.path),
      fit: BoxFit.contain,
    );
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: model.bgColor ?? defHeaderBgColor,
          image: image,
        ),
        child: model.iconData == null
            ? Text(model.firstletter ?? '', style: TextStyle(color: Colors.red))
            : Icon(model.iconData, color: Colors.white, size: 20),
      ),
      title: Text(model.name, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(
        model.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
      ),
      trailing: SmartImageView(SvgImageId.iconNext.path, height: 24),
      dense: true,
      onTap: () {
        appLog('on exercise tapped');
        viewmodel?.viewType = ExerciseDetailLayout.tabbed;
        viewmodel?.selectedExerciseIndex = 0;
        AppRouter.push(context, AppConstants.routeExerciseDetail, extra: 0);
      },
    );
  }
}

const List _list = [
  {"name": "Ab Wheel", "subName": "Core"},
  {"name": "Aerobics", "subName": "Cardio"},
  {"name": "Arnold Press", "subName": "Shoulders"},

  {"name": "Back Extension", "subName": "Back"},
  {"name": "Barbell Bench Press", "subName": "Chest"},
  {"name": "Barbell Curl", "subName": "Biceps"},
  {"name": "Battle Ropes", "subName": "Cardio"},
  {"name": "Bent Over Row", "subName": "Back"},
  {"name": "Box Jumps", "subName": "Legs"},

  {"name": "Cable Crossover", "subName": "Chest"},
  {"name": "Cable Row", "subName": "Back"},
  {"name": "Calf Raises", "subName": "Legs"},
  {"name": "Chest Fly", "subName": "Chest"},
  {"name": "Chin Ups", "subName": "Back"},
  {"name": "Clean and Jerk", "subName": "Full Body"},
  {"name": "Crunches", "subName": "Core"},

  {"name": "Deadlift", "subName": "Back"},
  {"name": "Decline Bench Press", "subName": "Chest"},
  {"name": "Dips", "subName": "Triceps"},
  {"name": "Dumbbell Curl", "subName": "Biceps"},
  {"name": "Dumbbell Fly", "subName": "Chest"},
  {"name": "Dumbbell Lunges", "subName": "Legs"},

  {"name": "Elliptical Trainer", "subName": "Cardio"},
  {"name": "Face Pulls", "subName": "Shoulders"},
  {"name": "Farmer Walk", "subName": "Full Body"},
  {"name": "Front Squat", "subName": "Legs"},

  {"name": "Glute Bridge", "subName": "Glutes"},
  {"name": "Goblet Squat", "subName": "Legs"},
  {"name": "Good Mornings", "subName": "Back"},

  {"name": "Hack Squat", "subName": "Legs"},
  {"name": "Hammer Curl", "subName": "Biceps"},
  {"name": "Hanging Leg Raises", "subName": "Core"},
  {"name": "Hip Thrust", "subName": "Glutes"},

  {"name": "Incline Bench Press", "subName": "Chest"},
  {"name": "Incline Dumbbell Curl", "subName": "Biceps"},

  {"name": "Jump Rope", "subName": "Cardio"},
  {"name": "Jump Squats", "subName": "Legs"},

  {"name": "Kettlebell Swing", "subName": "Full Body"},

  {"name": "Lat Pulldown", "subName": "Back"},
  {"name": "Leg Curl", "subName": "Legs"},
  {"name": "Leg Press", "subName": "Legs"},
  {"name": "Leg Raises", "subName": "Core"},
  {"name": "Lunges", "subName": "Legs"},

  {"name": "Mountain Climbers", "subName": "Cardio"},

  {"name": "Overhead Press", "subName": "Shoulders"},

  {"name": "Plank", "subName": "Core"},
  {"name": "Pull Ups", "subName": "Back"},
  {"name": "Push Ups", "subName": "Chest"},

  {"name": "Romanian Deadlift", "subName": "Back"},
  {"name": "Russian Twist", "subName": "Core"},

  {"name": "Seated Row", "subName": "Back"},
  {"name": "Shoulder Shrugs", "subName": "Shoulders"},
  {"name": "Sit Ups", "subName": "Core"},
  {"name": "Squats", "subName": "Legs"},
  {"name": "Step Ups", "subName": "Legs"},

  {"name": "Tricep Dips", "subName": "Triceps"},
  {"name": "Tricep Pushdown", "subName": "Triceps"},

  {"name": "Upright Row", "subName": "Shoulders"},

  {"name": "Walking Lunges", "subName": "Legs"},

  {"name": "Zercher Squat", "subName": "Legs"},
];
