import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_enums.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/exercise_set.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';

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
    secondaryLabel: '',
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

class ExerciseViewModel extends ChangeNotifier {
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

  ExerciseViewModel(Exercise exercise)
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

/// Add Workout ViewModel
///
/// Manages the state and business logic for the Add Workout screen.
class AddWorkoutViewModel extends BaseViewModel {
  final _workoutNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();

  TextEditingController get workoutNameController => _workoutNameController;
  TextEditingController get dateController => _dateController;
  TextEditingController get startTimeController => _startTimeController;
  TextEditingController get durationController => _durationController;
  TextEditingController get caloriesController => _caloriesController;

  final ValueNotifier<List<ExerciseViewModel>> _strengthExercises =
      ValueNotifier([]);
  final ValueNotifier<List<ExerciseViewModel>> _cardioExercises = ValueNotifier(
    [],
  );
  final ValueNotifier<List<ExerciseViewModel>> _otherExercises = ValueNotifier(
    [],
  );
  final ValueNotifier<bool> _workoutEntryToggle = ValueNotifier(false);
  final List<WorkoutEntry> _workoutEntries = [
    WorkoutEntry(title: 'Upper Body'),
    WorkoutEntry(title: 'Lower Body'),
  ];

  ValueNotifier<List<ExerciseViewModel>> get strengthExercises =>
      _strengthExercises;
  ValueNotifier<List<ExerciseViewModel>> get cardioExercises =>
      _cardioExercises;
  ValueNotifier<List<ExerciseViewModel>> get otherExercises => _otherExercises;
  ValueNotifier<bool> get workoutEntryToggle => _workoutEntryToggle;
  List<WorkoutEntry> get workoutEntries => _workoutEntries;

  /// Add a new exercise to the specified category
  void addExercise(String category, Exercise exercise) {
    // Set default enabled fields based on category
    Set<ExerciseField> defaultFields;
    switch (category) {
      case 'strength':
        defaultFields = {ExerciseField.reps, ExerciseField.weight};
        break;
      case 'cardio':
        defaultFields = {ExerciseField.duration, ExerciseField.distance};
        break;
      default:
        defaultFields = {ExerciseField.reps, ExerciseField.bodyWeight};
    }
    final updatedExercise = Exercise(
      name: exercise.name,
      sets: exercise.sets,
      enabledFields: defaultFields,
    );
    final exerciseVM = ExerciseViewModel(updatedExercise);
    switch (category) {
      case 'strength':
        _strengthExercises.value = [..._strengthExercises.value, exerciseVM];
        break;
      case 'cardio':
        _cardioExercises.value = [..._cardioExercises.value, exerciseVM];
        break;
      case 'other':
        _otherExercises.value = [..._otherExercises.value, exerciseVM];
        break;
    }
  }

  /// Remove an exercise from the specified category
  void removeExercise(String category, int index) {
    switch (category) {
      case 'strength':
        final list = List<ExerciseViewModel>.from(_strengthExercises.value);
        list[index].dispose();
        list.removeAt(index);
        _strengthExercises.value = list;
        break;
      case 'cardio':
        final list = List<ExerciseViewModel>.from(_cardioExercises.value);
        list[index].dispose();
        list.removeAt(index);
        _cardioExercises.value = list;
        break;
      case 'other':
        final list = List<ExerciseViewModel>.from(_otherExercises.value);
        list[index].dispose();
        list.removeAt(index);
        _otherExercises.value = list;
        break;
    }
  }

  /// Save the workout
  Future<void> saveWorkout(BuildContext context) async {
    // TODO: Implement save logic, e.g., call repository to save workout
    // For now, just print
    print('Saving workout: ${_workoutNameController.text}');
    print('Date: ${_dateController.text}');
    print('Start Time: ${_startTimeController.text}');
    print('Duration: ${_durationController.text}');
    print('Calories: ${_caloriesController.text}');
    print(
      'Strength Exercises: ${_strengthExercises.value.map((e) => e.exercise.toJson()).toList()}',
    );
    print(
      'Cardio Exercises: ${_cardioExercises.value.map((e) => e.exercise.toJson()).toList()}',
    );
    print(
      'Other Exercises: ${_otherExercises.value.map((e) => e.exercise.toJson()).toList()}',
    );

    // Navigate back or to success screen
    if (context.mounted) {
      AppRouter.pop(context);
    }
  }

  @override
  void dispose() {
    _workoutNameController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    for (var vm in _strengthExercises.value) {
      vm.dispose();
    }
    for (var vm in _cardioExercises.value) {
      vm.dispose();
    }
    for (var vm in _otherExercises.value) {
      vm.dispose();
    }
    _strengthExercises.dispose();
    _cardioExercises.dispose();
    _otherExercises.dispose();
    _workoutEntryToggle.dispose();
    for (var entry in _workoutEntries) {
      entry.dispose();
    }
    super.dispose();
  }
}

class WorkoutEntry {
  final String title;
  final ValueNotifier<double> value;

  WorkoutEntry({required this.title, double initialValue = 0.0})
    : value = ValueNotifier(initialValue);

  void dispose() {
    value.dispose();
  }
}
