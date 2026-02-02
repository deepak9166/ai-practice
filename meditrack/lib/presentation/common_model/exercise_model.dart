class ExerciseModel {
  final String name;
  final String date;
  final String msgNames;
  final String status;
  final List<String> previewImages;
  bool? isBestPerformOfDay;

  ExerciseModel({
    required this.date,
    required this.msgNames,
    required this.name,
    required this.previewImages,
    required this.status,
    this.isBestPerformOfDay = false,
  });
}
