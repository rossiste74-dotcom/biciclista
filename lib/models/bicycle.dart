import 'package:isar/isar.dart';

part 'bicycle.g.dart';

@collection
class Bicycle {
  Id id = Isar.autoIncrement;

  /// Name of the bicycle (e.g., "My Road Bike")
  late String name;

  /// Type of bicycle (e.g., "Road", "MTB", "Gravel", "City")
  @Index()
  late String type;

  /// Gearing system type (e.g., "Mechanical", "Electronic", "Single Speed")
  late String gearingSystem;

  /// Total distance traveled by this bicycle in km
  late double totalDistance;

  /// Date of the last maintenance
  late DateTime lastMaintenance;

  /// Timestamp when the bicycle was added
  late DateTime createdAt;

  Bicycle() {
    createdAt = DateTime.now();
  }
}
