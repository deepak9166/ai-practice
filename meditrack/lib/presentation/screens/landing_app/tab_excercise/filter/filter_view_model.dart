import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';

import '../../../../../enum/filter_enum.dart';
import '../../../../screen/base/screen_state.dart';

class FilterViewModel extends BaseViewModel {
  final List<FilterTypes> allowFilter;
  FilterViewModel(this.allowFilter) {
    filterSetup(allowFilter);
  }
  // FilterModel(name: 'MMG', type: FilterTypes.mmg),
  // FilterModel(name: 'MSG', type: FilterTypes.msg),
  // FilterModel(name: 'Equipments', type: FilterTypes.equipments),
  // FilterModel(name: 'Template Type', type: FilterTypes.templateType),
  // FilterModel(name: 'Custom Excercise', type: FilterTypes.customExcercise),

  List<FilterModel> filter = [];

  filterSetup(List<FilterTypes> supportTypes) async {
    changeScreenState(ScreenState.progress);
    try {
      for (var type in supportTypes) {
        switch (type) {
          case FilterTypes.mmg:
            await getMmgLevel(type);

          case FilterTypes.msg:
            await getMsgLevel(type);
          case FilterTypes.equipments:
            await getequipmentsLevel(type);
          case FilterTypes.templateType:
            await gettemplateType(type);
          case FilterTypes.customExcercise:
          // TODO: need to clear UI for custom excercise filter
        }
      }
    } catch (e) {
      appLog('Fetch filter with error $e');
    }
    changeScreenState(ScreenState.content);
  }

  // MMG LEVEL
  List<FilterItemsModel> _mmgLevelList = [];
  List<FilterItemsModel> get mmgLevelList => _mmgLevelList;
  Future<void> getMmgLevel(FilterTypes type) async {
    if (_mmgLevelList.isNotEmpty) {
      appLog(
        'MMG value already fetched : Total ${_mmgLevelList.length} items.',
      );
      return;
    }
    await Future.delayed(Duration(milliseconds: 200));
    _mmgLevelList = [
      FilterItemsModel(
        filterValues: [
          FilterValus(icon: '', id: 0, labelName: "Chest"),
          FilterValus(icon: '', id: 1, labelName: "Shoulders"),
          FilterValus(icon: '', id: 2, labelName: "Lats"),
          FilterValus(icon: '', id: 3, labelName: "Traps"),
          FilterValus(icon: '', id: 4, labelName: "Middle Back"),
          FilterValus(icon: '', id: 5, labelName: "Core"),
        ],
        name: "Upper Body",
      ),
      FilterItemsModel(
        filterValues: [
          FilterValus(icon: '', id: 6, labelName: "biceps"),
          FilterValus(icon: '', id: 7, labelName: "Triceps"),
          FilterValus(icon: '', id: 8, labelName: "Foreams"),
        ],
        name: "Arms",
      ),
    ];
    filter.add(FilterModel(name: type.name, type: type));
    appLog('MMG value new added : Total ${_mmgLevelList.length} items found.');
  }

  // MSG LEVEL
  List<FilterItemsModel> _msgLevelList = [];
  List<FilterItemsModel> get msgLevelList => _msgLevelList;
  Future<void> getMsgLevel(FilterTypes type) async {
    if (_msgLevelList.isNotEmpty) {
      appLog(
        'MSG value already fetched : Total ${_msgLevelList.length} items.',
      );
      return;
    }
    await Future.delayed(Duration(milliseconds: 200));
    _msgLevelList = [
      FilterItemsModel(
        filterValues: [
          FilterValus(icon: '', id: 0, labelName: "Upper Chest"),
          FilterValus(icon: '', id: 1, labelName: "Middle Chest"),
          FilterValus(icon: '', id: 2, labelName: "Lower Chest"),
        ],
        name: "Upper Body",
      ),
      FilterItemsModel(
        filterValues: [
          FilterValus(icon: '', id: 3, labelName: "Lats"),
          FilterValus(icon: '', id: 4, labelName: "Traps"),
          FilterValus(icon: '', id: 5, labelName: "Rotator Cuff"),
        ],
        name: "Back",
      ),
    ];
    filter.add(FilterModel(name: type.name, type: type));
    appLog('MSG value new added : Total ${_msgLevelList.length} items found.');
  }

  // Equipments
  List<FilterItemsModel> _equipmentsLevelList = [];
  List<FilterItemsModel> get equipmentsLevelList => _equipmentsLevelList;

  Future<void> getequipmentsLevel(FilterTypes type) async {
    if (_equipmentsLevelList.isNotEmpty) {
      appLog(
        'Equipments value already fetched : Total ${_equipmentsLevelList.length} items.',
      );
      return;
    }
    await Future.delayed(Duration(milliseconds: 200));
    _equipmentsLevelList = [
      FilterItemsModel(
        filterValues: [
          FilterValus(icon: '', id: 0, labelName: "Dumbbells"),
          FilterValus(icon: '', id: 1, labelName: "Barbells"),
          FilterValus(icon: '', id: 2, labelName: "Weight plates"),
        ],
        name: "",
      ),
    ];
    filter.add(FilterModel(name: type.name, type: type));
    appLog(
      'Equipments value new added : Total ${_equipmentsLevelList.length} items found.',
    );
  }

  // Template Type
  List<FilterValus> _templateTypeList = [];
  List<FilterValus> get templateTypeList => _templateTypeList;
  Future<void> gettemplateType(FilterTypes type) async {
    if (_templateTypeList.isNotEmpty) {
      appLog(
        'Template value already fetched : Total ${_templateTypeList.length} items.',
      );
      return;
    }
    await Future.delayed(Duration(milliseconds: 200));
    _templateTypeList = [
      FilterValus(icon: '', id: 0, labelName: "Bodyweight-only / Calisthenics"),
      FilterValus(icon: '', id: 1, labelName: "Free Weight-only"),
      FilterValus(icon: '', id: 2, labelName: "Plyometric-only"),
      FilterValus(
        icon: '',
        id: 3,
        labelName: "Compound / Functional Exercises-only",
      ),
      FilterValus(icon: '', id: 4, labelName: "Isolation Exercises-only"),
      FilterValus(icon: '', id: 5, labelName: "HIIT-focused-only"),
      FilterValus(icon: '', id: 6, labelName: "Cardio-focused-only / Aerobic"),
      FilterValus(
        icon: '',
        id: 7,
        labelName: "Stretch, Flexibility, Balance-only",
      ),
    ];
    filter.add(FilterModel(name: type.name, type: type));
    appLog(
      'Template value new added : Total ${_templateTypeList.length} items found.',
    );
  }
}

class FilterModel {
  final String name;
  bool isSelected;
  FilterTypes type;
  FilterModel({
    required this.name,
    this.isSelected = false,
    required this.type,
  });
}

class FilterItemsModel {
  final String name;
  final List<FilterValus> filterValues;

  FilterItemsModel({required this.filterValues, required this.name});
}

class FilterValus {
  final String labelName;
  final String icon;
  final int id;
  bool isSelected;

  FilterValus({
    required this.icon,
    required this.id,
    this.isSelected = false,
    required this.labelName,
  });
}
