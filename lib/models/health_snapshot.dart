
class HealthSnapshot {
  int? id; // or ignore

  /// Date of the health snapshot (without time component for daily tracking)
  late DateTime date;

  /// Heart Rate Variability in milliseconds
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
