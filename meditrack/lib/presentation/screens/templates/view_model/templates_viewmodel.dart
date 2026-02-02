import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_enums.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_set.dart';
import 'package:meditrack/presentation/screens/base/base_view_model.dart';

class TemplatesViewModel extends BaseViewModel {
  final ValueNotifier<List<double>> mmgValues = ValueNotifier([0.5, 0.5, 0.5]);
  static const List<String> mmgTitles = [
    'Beginner Level',
    'Intermediate Level',
    'Advanced Level',
  ];

  final ValueNotifier<List<Map<String, dynamic>>> usersShare = ValueNotifier([
    {
      'name': 'John Doe',
      'initials': 'JD',
      'age': '25',
      'gender': 'Male',
      'isSelected': false,
    },
    {
      'name': 'Jane Smith',
      'initials': 'JS',
      'age': '25',
      'gender': 'Male',
      'isSelected': true,
    },
    {
      'name': 'Alex Johnson',
      'initials': 'AJ',
      'age': '25',
      'gender': 'Male',
      'isSelected': false,
    },
    // Add more users as needed
  ]);

  static List<String> get titles => mmgTitles;

  final ValueNotifier<List<Exercise>> _listExercises = ValueNotifier(
    _createDummyExercises(10),
  );

  final ValueNotifier<List<Exercise>> _adminExercises = ValueNotifier(
    _createDummyExercises(10),
  );
  final ValueNotifier<List<Exercise>> _customExercises = ValueNotifier(
    _createDummyExercises(10),
  );
  final ValueNotifier<List<Exercise>> _sharedExercises = ValueNotifier(
    _createDummyExercises(10),
  );

  final ValueNotifier<List<bool>> _adminItemExpandedStates = ValueNotifier(
    List.generate(10, (_) => true),
  );
  final ValueNotifier<List<List<bool>>> _adminSetExpandedStates = ValueNotifier(
    List.generate(10, (i) => List.generate(i + 1, (_) => false)),
  );

  static List<Exercise> _createDummyExercises(int count) {
    final exerciseNames = [
      'Arm circles',
      'Push-ups',
      'Squats',
      'Planks',
      'Burpees',
      'Jumping jacks',
      'Lunges',
      'Mountain climbers',
      'Bicycle crunches',
      'High knees',
    ];
    return List.generate(count, (index) {
      final sets = List.generate(
        index + 1,
        (setIndex) => ExerciseSet(
          reps: (index + 1) * 10 + setIndex * 5,
          weight: (index + 1) * 5.0 + setIndex * 2.0,
          assistedWeight: setIndex * 1.0,
          extraWeight: setIndex * 0.5,
          bodyWeight: 70.0 + index * 2.0,
          duration: (index + 1) * 30.0 + setIndex * 10.0,
          distance: (index + 1) * 1.0 + setIndex * 0.5,
          calorieBurned: (index + 1) * 50.0 + setIndex * 20.0,
        ),
      );
      final exercise = Exercise(
        name: exerciseNames[index % exerciseNames.length],
        sets: sets,
        enabledFields: {
          ExerciseField.reps,
          ExerciseField.weight,
          ExerciseField.duration,
        },
      );
      return exercise;
    });
  }

  ValueNotifier<List<Exercise>> get listExercises => _listExercises;
  ValueNotifier<List<Exercise>> get adminExercises => _adminExercises;
  ValueNotifier<List<Exercise>> get customExercises => _customExercises;
  ValueNotifier<List<Exercise>> get sharedExercises => _sharedExercises;
  ValueNotifier<List<bool>> get exerciseExpandedStates =>
      _adminItemExpandedStates;
  ValueNotifier<List<List<bool>>> get setExpandedStates =>
      _adminSetExpandedStates;

  void toggleExerciseExpansion(int index) {
    final list = List<bool>.from(_adminItemExpandedStates.value);
    list[index] = !list[index];
    _adminItemExpandedStates.value = list;
  }

  void toggleSetExpansion(int exerciseIndex, int setIndex) {
    final list = List<List<bool>>.from(_adminSetExpandedStates.value);
    list[exerciseIndex][setIndex] = !list[exerciseIndex][setIndex];
    _adminSetExpandedStates.value = list;
  }

  @override
  void dispose() {
    mmgValues.dispose();
    _adminExercises.dispose();
    _listExercises.dispose();
    _customExercises.dispose();
    _sharedExercises.dispose();
    _adminItemExpandedStates.dispose();
    _adminSetExpandedStates.dispose();
    super.dispose();
  }
}

/// Configuration for each exercise field
class ExerciseFieldConfig {
  final String defaultValue;
  final dynamic Function(String) parser;
  final String label;
  final String secondaryLabel;
  final bool isPickerEnabled;
  final String? pickerType;
  final bool hasIncrementDecrement;

  const ExerciseFieldConfig({
    required this.defaultValue,
    required this.parser,
    required this.label,
    required this.secondaryLabel,
    this.isPickerEnabled = false,
    this.pickerType,
    this.hasIncrementDecrement = false,
  });
}

/// Static configurations for all exercise fields
final Map<ExerciseField, ExerciseFieldConfig> _fieldConfigs = {
  ExerciseField.reps: ExerciseFieldConfig(
    defaultValue: '1',
    parser: (s) => int.tryParse(s) ?? 1,
    label: 'Reps ',
    secondaryLabel: '(lbs)',
    isPickerEnabled: true,
    pickerType: 'reps',
    hasIncrementDecrement: true,
  ),
  ExerciseField.weight: ExerciseFieldConfig(
    defaultValue: '0.0',
    parser: (s) => double.tryParse(s) ?? 0.0,
    label: 'Weight ',
    secondaryLabel: '(kg)',
  ),
  ExerciseField.assistedWeight: ExerciseFieldConfig(
    defaultValue: '0.0',
    parser: (s) => double.tryParse(s) ?? 0.0,
    label: 'Assisted Weight ',
    secondaryLabel: '(kg)',
  ),
  ExerciseField.extraWeight: ExerciseFieldConfig(
    defaultValue: '0.0',
    parser: (s) => double.tryParse(s) ?? 0.0,
    label: 'Extra Weight ',
    secondaryLabel: '(kg)',
  ),
  ExerciseField.bodyWeight: ExerciseFieldConfig(
    defaultValue: '0.0',
    parser: (s) => double.tryParse(s) ?? 0.0,
    label: 'Body Weight ',
    secondaryLabel: '(kg)',
    isPickerEnabled: true,
    pickerType: 'weight',
  ),
  ExerciseField.duration: ExerciseFieldConfig(
    defaultValue: '0.0',
    parser: (s) => double.tryParse(s) ?? 0.0,
    label: 'Duration ',
    secondaryLabel: '(mins)',
  ),
  ExerciseField.distance: ExerciseFieldConfig(
    defaultValue: '0.0',
    parser: (s) => double.tryParse(s) ?? 0.0,
    label: 'Distance ',
    secondaryLabel: '(Mile)',
  ),
  ExerciseField.calorieBurned: ExerciseFieldConfig(
    defaultValue: '0.0',
    parser: (s) => double.tryParse(s) ?? 0.0,
    label: 'Calorie Burned ',
    secondaryLabel: '(cal)',
  ),
};

/// Helper function to get value from ExerciseSet by field
dynamic _getValueFromSet(ExerciseSet set, ExerciseField field) {
  switch (field) {
    case ExerciseField.reps:
      return set.reps;
    case ExerciseField.weight:
      return set.weight;
    case ExerciseField.assistedWeight:
      return set.assistedWeight;
    case ExerciseField.extraWeight:
      return set.extraWeight;
    case ExerciseField.bodyWeight:
      return set.bodyWeight;
    case ExerciseField.duration:
      return set.duration;
    case ExerciseField.distance:
      return set.distance;
    case ExerciseField.calorieBurned:
      return set.calorieBurned;
  }
}

/// ViewModel for managing individual template exercise state and logic
class TemplateExerciseViewModel extends ChangeNotifier {
  final TextEditingController _nameController;
  final Map<ExerciseField, List<TextEditingController>> _controllers;
  final List<bool> _setExpandedStates;
  late bool _allExpanded;
  late bool _itemExpanded;
  final Set<ExerciseField> _enabledFields;

  TextEditingController get nameController => _nameController;
  List<bool> get setExpandedStates => _setExpandedStates;
  bool get allExpanded => _allExpanded;
  bool get itemExpanded => _itemExpanded;
  Set<ExerciseField> get enabledFields => _enabledFields;

  ExerciseFieldConfig getConfig(ExerciseField field) => _fieldConfigs[field]!;

  List<TextEditingController> getControllers(ExerciseField field) =>
      _controllers[field]!;

  TemplateExerciseViewModel(Exercise exercise)
    : _nameController = TextEditingController(text: exercise.name),
      _enabledFields = Set.from(exercise.enabledFields),
      _controllers = {
        for (var field in ExerciseField.values)
          field: exercise.sets
              .map(
                (set) => TextEditingController(
                  text: _getValueFromSet(set, field).toString(),
                ),
              )
              .toList(),
      },
      _setExpandedStates = List.generate(exercise.sets.length, (_) => false) {
    _allExpanded = false;
    _itemExpanded = true;
    _nameController.addListener(_updateExercise);
    for (var field in ExerciseField.values) {
      for (var controller in _controllers[field]!) {
        controller.addListener(_updateExercise);
      }
    }
  }

  void _updateExercise() {
    notifyListeners();
  }

  Exercise get exercise {
    final sets = List.generate(
      _controllers[ExerciseField.reps]!.length,
      (index) => ExerciseSet(
        reps: _fieldConfigs[ExerciseField.reps]!.parser(
          _controllers[ExerciseField.reps]![index].text,
        ),
        weight: _fieldConfigs[ExerciseField.weight]!.parser(
          _controllers[ExerciseField.weight]![index].text,
        ),
        assistedWeight: _fieldConfigs[ExerciseField.assistedWeight]!.parser(
          _controllers[ExerciseField.assistedWeight]![index].text,
        ),
        extraWeight: _fieldConfigs[ExerciseField.extraWeight]!.parser(
          _controllers[ExerciseField.extraWeight]![index].text,
        ),
        bodyWeight: _fieldConfigs[ExerciseField.bodyWeight]!.parser(
          _controllers[ExerciseField.bodyWeight]![index].text,
        ),
        duration: _fieldConfigs[ExerciseField.duration]!.parser(
          _controllers[ExerciseField.duration]![index].text,
        ),
        distance: _fieldConfigs[ExerciseField.distance]!.parser(
          _controllers[ExerciseField.distance]![index].text,
        ),
        calorieBurned: _fieldConfigs[ExerciseField.calorieBurned]!.parser(
          _controllers[ExerciseField.calorieBurned]![index].text,
        ),
      ),
    );
    return Exercise(
      name: _nameController.text,
      sets: sets,
      enabledFields: _enabledFields,
    );
  }

  void incrementValue(ExerciseField field, int index) {
    final current = _fieldConfigs[field]!.parser(
      _controllers[field]![index].text,
    );
    if (current is int) {
      _controllers[field]![index].text = (current + 1).toString();
    } else if (current is double) {
      _controllers[field]![index].text = (current + 1.0).toString();
    }
    notifyListeners();
  }

  void decrementValue(ExerciseField field, int index) {
    final current = _fieldConfigs[field]!.parser(
      _controllers[field]![index].text,
    );
    if (current is int) {
      if (current > 0) {
        _controllers[field]![index].text = (current - 1).toString();
      }
    } else if (current is double) {
      _controllers[field]![index].text = (current - 1.0).toString();
    }
    notifyListeners();
  }

  void incrementReps(int index) {
    incrementValue(ExerciseField.reps, index);
  }

  void decrementReps(int index) {
    decrementValue(ExerciseField.reps, index);
  }

  void addSet() {
    for (var field in ExerciseField.values) {
      _controllers[field]!.add(
        TextEditingController(text: _fieldConfigs[field]!.defaultValue),
      );
      _controllers[field]!.last.addListener(_updateExercise);
    }
    _setExpandedStates.add(_allExpanded);
    notifyListeners();
  }

  void removeSet(int index) {
    for (var field in ExerciseField.values) {
      _controllers[field]!.removeAt(index);
    }
    _setExpandedStates.removeAt(index);
    notifyListeners();
  }

  void toggleSetExpansion(int index) {
    _setExpandedStates[index] = !_setExpandedStates[index];
    notifyListeners();
  }

  void toggleAllExpansion() {
    _allExpanded = !_allExpanded;
    for (int i = 0; i < _setExpandedStates.length; i++) {
      _setExpandedStates[i] = _allExpanded;
    }
    notifyListeners();
  }

  void toggleItemExpansion() {
    _itemExpanded = !_itemExpanded;
    notifyListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var field in ExerciseField.values) {
      for (var controller in _controllers[field]!) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
