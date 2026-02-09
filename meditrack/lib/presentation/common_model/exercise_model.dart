class MedicineModel {
  final String name;
  final String date;
  final String type;
  final String status;
  final int? medicineId;
  final int? intakeId;

  MedicineModel({
    required this.date,
    required this.type,
    required this.name,
    required this.status,
    this.medicineId,
    this.intakeId,
  });
}
