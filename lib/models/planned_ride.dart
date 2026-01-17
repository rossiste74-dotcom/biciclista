import 'package:isar/isar.dart';

part 'planned_ride.g.dart';

@collection
class PlannedRide {
  Id id = Isar.autoIncrement;

  /// Date and time of the planned ride
  @Index()
  late DateTime rideDate;

  /// Name of the ride (optional)
  String? rideName;

  /// Local file path to the GPX file
  String? gpxFilePath;

  /// Weather forecast data (stored as JSON string)
  /// Contains temperature, wind, precipitation, etc.
  String? forecastWeather;

  /// Total distance in kilometers (extracted from GPX)
  late double distance;

  /// Total elevation gain in meters (extracted from GPX)
  late double elevation;

  /// Latitude for weather forecast (extracted from GPX)
  late double? latitude;

  /// Longitude for weather forecast (extracted from GPX)
  late double? longitude;

  /// User notes about the ride
  String? notes;

  /// AI analysis and advice for this ride
  String? aiAnalysis;

  /// Whether the ride has been completed
  @Index()
  bool isCompleted = false;

  /// ID of the bicycle used for this ride (optional)
  int? bicycleId;

  /// Timestamp when the ride was planned
  late DateTime createdAt;

  PlannedRide() {
    createdAt = DateTime.now();
  }
}
