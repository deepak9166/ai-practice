import 'package:flutter/material.dart';
import 'package:meditrack/presentation/screens/add_workout/view_model/add_workout_viewmodel.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';

class WorkoutHistoryViewModel extends BaseViewModel {
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

  final ValueNotifier<bool> _workoutEntryToggle = ValueNotifier(false);
  final List<WorkoutEntry> _workoutEntries = [
    WorkoutEntry(title: 'Upper Body'),
    WorkoutEntry(title: 'Lower Body'),
  ];


  ValueNotifier<bool> get workoutEntryToggle => _workoutEntryToggle;
  List<WorkoutEntry> get workoutEntries => _workoutEntries;

  final ValueNotifier<List<String>> _exercises = ValueNotifier(
    _createDummyExercises(10),
  );

  ValueNotifier<List<String>> get exercises => _exercises;

  static List<String> _createDummyExercises(int count) {
    return [
      'Upper Body Strength',
      'Push-ups',
      'Aerobics',
      'Planks',
      'Back Extension',
      'Jumping jacks',
      'Lunges',
      'Mountain climbers',
      'Bicycle crunches',
      'High knees',
    ];
  }

  @override
  void dispose() {
    _exercises.dispose();
    super.dispose();
  }
}
