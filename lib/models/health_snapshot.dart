import 'package:isar/isar.dart';

part 'health_snapshot.g.dart';

@collection
class HealthSnapshot {
  Id id = Isar.autoIncrement;

  /// Date of the health snapshot (without time component for daily tracking)
  @Index()
  late DateTime date;

  /// Heart Rate Variability in milliseconds
  /// Higher values generally indicate better recovery
  late int hrv;

  /// Total sleep duration in hours
  late double sleepHours;

  /// Daily weight measurement in kilograms
  late double dailyWeight;

  /// Timestamp when the snapshot was created
  late DateTime createdAt;

  HealthSnapshot() {
    createdAt = DateTime.now();
  }
}
