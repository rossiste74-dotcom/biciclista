import 'package:isar/isar.dart';

part 'track.g.dart';

/// Track model - GPX route without scheduling (timeless)
@collection
class Track {
  Id id = Isar.autoIncrement;
  
  // Basic info
  late String name;
  String? description;
  
  // GPX data
  String? gpxFilePath;
  
  // Stats
  late double distance; // km
  late double elevation; // meters
  int? duration; // estimated seconds
  
  // Classification
  @Index()
  late String terrainType; // road, gravel, mtb, mixed
  String? region;
  
  // Origin tracking
  late String source; // manual, strava, garmin, community
  String? communityTrackId; // If imported from community catalog
  
  // Timestamps
  late DateTime createdAt;
  late DateTime updatedAt;
  
  // Sync
  @Index()
  String? supabaseId;
  String? gpxUrl;
  DateTime? lastSyncedAt;
  
  Track();

  // Helper getters
  String get displayName => name.isNotEmpty ? name : 'Percorso $id';
  
  String get terrainIcon {
    switch (terrainType) {
      case 'road':
        return '🚴';
      case 'gravel':
        return '🚵';
      case 'mtb':
        return '⛰️';
      case 'mixed':
        return '🛤️';
      default:
        return '🚴';
    }
  }
  
  String get terrainLabel {
    switch (terrainType) {
      case 'road':
        return 'Strada';
      case 'gravel':
        return 'Gravel';
      case 'mtb':
        return 'MTB';
      case 'mixed':
        return 'Misto';
      default:
        return terrainType;
    }
  }
}
