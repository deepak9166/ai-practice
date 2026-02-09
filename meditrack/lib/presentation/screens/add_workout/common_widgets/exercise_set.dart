import 'package:meditrack/core/constants/app_enums.dart';

class ExerciseSet {
  int reps;
  double weight;
  double assistedWeight;
  double extraWeight;
  double bodyWeight;
  double duration;
  double distance;
  double calorieBurned;

  ExerciseSet({
    this.reps = 1,
    this.weight = 0.0,
    this.assistedWeight = 0.0,
    this.extraWeight = 0.0,
    this.bodyWeight = 0.0,
    this.duration = 0.0,
    this.distance = 0.0,
    this.calorieBurned = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'assistedWeight': assistedWeight,
      'extraWeight': extraWeight,
      'bodyWeight': bodyWeight,
      'duration': duration,
      'distance': distance,
      'calorieBurned': calorieBurned,
    };
  }
}

/// Model for an exercise in the workout
class Exercise {
  String name;
  String? exerciseImg;
  List<ExerciseSet> sets;
  Set<ExerciseField> enabledFields;

  Exercise({
    required this.name,
    this.exerciseImg,
    List<ExerciseSet>? sets,
    Set<ExerciseField>? enabledFields,
  }) : sets = sets ?? [ExerciseSet()],
       enabledFields =
           enabledFields ?? {ExerciseField.reps, ExerciseField.weight};

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exerciseImg': exerciseImg,
      'sets': sets.map((set) => set.toJson()).toList(),
      'enabledFields': enabledFields.map((e) => e.name).toList(),
    };
  }
}
