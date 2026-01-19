import 'package:isar/isar.dart';
import 'track.dart';

part 'planned_ride.g.dart';

@collection
class PlannedRide {
  Id id = Isar.autoIncrement;

  /// Date and time of the planned ride
  @Index()
  late DateTime rideDate;

  /// Name of the ride (optional, overrides track name if set)
  String? rideName;

  // ========== TRACK REFERENCE (NEW) ==========
  
  /// Reference to Track (GPX route)
  int? trackId;
  
  /// Link to Track object
  final track = IsarLink<Track>();

  // ========== EVENT TYPE (NEW) ==========
  
  /// Is this a community group ride?
  @Index()
  bool isGroupRide = false;
  
  /// Supabase event ID if synced as group ride
  String? supabaseEventId;

  // ========== GPX DATA (DEPRECATED - use track.gpxFilePath) ==========
  
  /// Local file path to the GPX file
  /// @deprecated Use track.gpxFilePath instead
  String? gpxFilePath;

  /// Weather forecast data (stored as JSON string)
  /// Contains temperature, wind, precipitation, etc.
  String? forecastWeather;

  /// Total distance in kilometers (extracted from GPX)
  /// @deprecated Use track.distance instead when track is linked
  late double distance;

  /// Total elevation gain in meters (extracted from GPX)
  /// @deprecated Use track.elevation instead when track is linked
  late double elevation;

  /// Moving time in seconds (from external sync)
  int? movingTime;

  /// Average speed in km/h (from external sync)
  double? avgSpeed;

  /// Average Heart Rate (bpm)
  double? avgHeartRate;

  /// Max Heart Rate (bpm)
  double? maxHeartRate;

  /// Average Power (watts)
  double? avgPower;

  /// Max Power (watts)
  double? maxPower;

  /// Average Cadence (rpm)
  double? avgCadence;

  /// Calories (kcal)
  int? calories;

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

  // ========== HELPER GETTERS (BACKWARD COMPATIBILITY) ==========
  
  /// Get effective distance (from track if available, else legacy field)
  double get effectiveDistance => track.value?.distance ?? distance;
  
  /// Get effective elevation (from track if available, else legacy field)
  double get effectiveElevation => track.value?.elevation ?? elevation;
  
  /// Get effective GPX path (from track if available, else legacy field)
  String? get effectiveGpxPath => track.value?.gpxFilePath ?? gpxFilePath;
  
  /// Get display name (custom name or track name)
  String get displayName => rideName ?? track.value?.name ?? 'Uscita ${id}';
}
