class MarkDatesModel {
  final DateTime date;
  final int workoutCount;
  final bool? isBestPerformOfDay;

  MarkDatesModel({
    required this.date,
    required this.workoutCount,
    this.isBestPerformOfDay = false,
  });
}
