
/// Track model - GPX route without scheduling (timeless)
/// Mapped to 'personal_tracks' in Supabase
class Track {
  // Supabase ID (UUID String)
  String? id;
  
  // Supabase User ID
  String? userId;
  
  // Basic info
  late String name;
  String? description;
  
  // GPX File URL (in Storage) - replaces local path for cloud
  String? gpxUrl; 
  // Local cache path (optional, for download)
  String? gpxFilePath;
  
  // Stats
  late double distance; // km
  late double elevation; // meters
  int? duration; // estimated seconds
  
  // Classification
  String terrainType = 'mixed'; // road, gravel, mtb, mixed
  String? region;
  
  // Origin tracking
  late String source; // manual, strava, garmin, community
  String? communityTrackId; // If imported from community catalog
  String? communityGpxData; // JSON content for tracks without storage file
  
  // Timestamps
  late DateTime createdAt;
  late DateTime updatedAt;
  
  // BRouter terrain analysis (optional)
  double? asphaltPercent;
  double? gravelPercent;
  double? pathPercent;
  int? difficultyLevel; // 1-5
  
  // Sync
  // Removed local sync fields as we are now cloud-only
  
  Track();

  // Helper getters
  String get displayName => name.isNotEmpty ? name : 'Percorso ${id ?? "Nuovo"}';
  
  String get terrainIcon {
    switch (terrainType) {
      case 'road': return '🚴';
      case 'gravel': return '🚵';
      case 'mtb': return '⛰️';
      case 'mixed': return '🛤️';
      default: return '🚴';
    }
  }
  
  String get terrainLabel {
    switch (terrainType) {
      case 'road': return 'Strada';
      case 'gravel': return 'Gravel';
      case 'mtb': return 'MTB';
      case 'mixed': return 'Misto';
      default: return terrainType;
    }
  }
}
