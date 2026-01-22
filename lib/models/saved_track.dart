/// Model for user's saved track reference (no GPX duplication)
class SavedTrack {
  final String id;
  final String userId;
  final String trackId;
  
  // Customization
  final String? customName;
  final String? notes;
  
  // Timestamp
  final DateTime savedAt;

  // Joined data (populated when fetching with track details)
  final String? trackName;
  final double? distance;
  final double? elevation;
  final String? difficultyLevel;
  final String? gpxData; // Added for community tracks JSON data

  SavedTrack({
    required this.id,
    required this.userId,
    required this.trackId,
    this.customName,
    this.notes,
    required this.savedAt,
    this.trackName,
    this.distance,
    this.elevation,
    this.difficultyLevel,
    this.gpxData,
  });

  factory SavedTrack.fromJson(Map<String, dynamic> json) {
    return SavedTrack(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      trackId: json['track_id'] as String,
      customName: json['custom_name'] as String?,
      notes: json['notes'] as String?,
      savedAt: DateTime.parse(json['saved_at'] as String),
      // Joined fields (optional)
      trackName: json['track_name'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      elevation: (json['elevation'] as num?)?.toDouble(),
      difficultyLevel: json['difficulty_level'] as String?,
      gpxData: json['gpx_data'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'track_id': trackId,
      'custom_name': customName,
      'notes': notes,
      'saved_at': savedAt.toIso8601String(),
    };
  }

  /// Get display name (custom or original)
  String get displayName => customName ?? trackName ?? 'Traccia';
}

/// Model for track rating
class TrackRating {
  final String id;
  final String userId;
  final String trackId;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  TrackRating({
    required this.id,
    required this.userId,
    required this.trackId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory TrackRating.fromJson(Map<String, dynamic> json) {
    return TrackRating(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      trackId: json['track_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'track_id': trackId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
