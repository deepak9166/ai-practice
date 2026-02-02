import 'package:flutter/material.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';

class SchedulingViewModel extends BaseViewModel {
  final ValueNotifier<List<String>> _adminExercises = ValueNotifier(
    _createDummyExercises(10),
  );
  final ValueNotifier<List<String>> _customExercises = ValueNotifier(
    _createDummyExercises(10),
  );
  final ValueNotifier<List<String>> _sharedExercises = ValueNotifier(
    _createDummyExercises(10),
  );

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

  ValueNotifier<List<String>> get adminExercises => _adminExercises;
  ValueNotifier<List<String>> get customExercises => _customExercises;
  ValueNotifier<List<String>> get sharedExercises => _sharedExercises;

  @override
  void dispose() {
    _adminExercises.dispose();
    _customExercises.dispose();
    _sharedExercises.dispose();
    super.dispose();
  }
}
