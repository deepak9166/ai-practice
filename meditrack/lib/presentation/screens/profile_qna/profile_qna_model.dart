enum QnaType { singleChoice, multiChoice, input, percentage }

class ProfileQnaModel {
  final int step;
  final int totalSteps;

  final String title;
  final String? info;
  final String? description;

  final QnaType type;

  final List<QnaOptionModel>? options;

  final String? hintText; // for input
  final String? unit; // kg, %, times, etc.

  dynamic value; // selected value / input value

  ProfileQnaModel({
    required this.step,
    required this.totalSteps,
    required this.title,
    this.info,
    this.description,
    required this.type,
    this.options,
    this.hintText,
    this.unit,
    this.value,
  });
}

class QnaOptionModel {
  final String id;
  final String title;
  dynamic value;

  QnaOptionModel({required this.id, required this.title, required this.value});
}
