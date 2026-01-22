
import 'track.dart';

class PlannedRide {
  // Supabase ID (UUID String)
  String? id;

  /// Date and time of the planned ride
  late DateTime rideDate;

  /// Name of the ride (optional, overrides track name if set)
  String? rideName;

  // ========== TRACK REFERENCE ==========
  
  /// Reference to Track ID (Foreign Key)
  String? trackId;
  
  /// Runtime link to Track object (manual join)
  Track? track;

  // ========== EVENT TYPE ==========
  
  /// Is this a community group ride?
  bool isGroupRide = false;
  
  /// Supabase event ID if synced as group ride
  String? supabaseEventId;

  // ========== GPX DATA (DEPRECATED - use track.gpxFilePath) ==========
  
  /// Local file path to the GPX file (Legacy/Fallback)
  String? gpxFilePath;

  /// Weather forecast data (stored as JSON string)
  String? forecastWeather;

  /// Total distance in kilometers (extracted from GPX)
  late double distance;

  /// Total elevation gain in meters (extracted from GPX)
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
  bool isCompleted = false;

  /// ID of the bicycle used for this ride (optional)
  String? bicycleId;

  /// Timestamp when the ride was planned
  late DateTime createdAt;

  PlannedRide() {
    createdAt = DateTime.now();
  }

  // ========== HELPER GETTERS ==========
  
  /// Get effective distance (from track if available, else legacy field)
  double get effectiveDistance => track?.distance ?? distance;
  
  /// Get effective elevation (from track if available, else legacy field)
  double get effectiveElevation => track?.elevation ?? elevation;
  
  /// Get effective GPX path (from track if available, else legacy field)
  String? get effectiveGpxPath => track?.gpxFilePath ?? gpxFilePath;
  
  /// Get display name (custom name or track name)
  String get displayName => rideName ?? track?.name ?? 'Uscita ${id ?? ""}';
}
