/// Model for community track in the catalog
class CommunityTrack {
  final String id;
  final String? creatorId;
  final String? creatorName;
  
  // Track info
  final String trackName;
  final String? description;
  
  // GPX data
  final Map<String, dynamic>? gpxData;
  final double distance;
  final double elevation;
  final int? duration; // seconds
  
  // Classification
  final String difficultyLevel; // easy, medium, hard, expert
  final String? region;
  final String country;
  final String? trackType; // road, gravel, mtb, mixed
  
  // Visibility & popularity
  final bool isPublic;
  final bool isFeatured;
  final int usageCount;
  final double avgRating;
  final int totalRatings;
  
  // Start coordinates
  final double? startLatitude;
  final double? startLongitude;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  CommunityTrack({
    required this.id,
    this.creatorId,
    this.creatorName,
    required this.trackName,
    this.description,
    this.gpxData,
    required this.distance,
    this.elevation = 0,
    this.duration,
    this.difficultyLevel = 'medium',
    this.region,
    this.country = 'IT',
    this.trackType,
    this.isPublic = true,
    this.isFeatured = false,
    this.usageCount = 0,
    this.avgRating = 0,
    this.totalRatings = 0,
    this.startLatitude,
    this.startLongitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityTrack.fromJson(Map<String, dynamic> json) {
    return CommunityTrack(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String?,
      creatorName: json['profiles'] != null ? json['profiles']['name'] as String? : null,
      trackName: json['track_name'] as String,
      description: json['description'] as String?,
      gpxData: json['gpx_data'] as Map<String, dynamic>?,
      distance: (json['distance'] as num).toDouble(),
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      duration: json['duration'] as int?,
      difficultyLevel: json['difficulty_level'] as String? ?? 'medium',
      region: json['region'] as String?,
      country: json['country'] as String? ?? 'IT',
      trackType: json['track_type'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      usageCount: json['usage_count'] as int? ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      totalRatings: json['total_ratings'] as int? ?? 0,
      startLatitude: (json['start_latitude'] as num?)?.toDouble(),
      startLongitude: (json['start_longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'track_name': trackName,
      'description': description,
      'gpx_data': gpxData,
      'distance': distance,
      'elevation': elevation,
      'duration': duration,
      'difficulty_level': difficultyLevel,
      'region': region,
      'country': country,
      'track_type': trackType,
      'is_public': isPublic,
      'is_featured': isFeatured,
      'usage_count': usageCount,
      'avg_rating': avgRating,
      'total_ratings': totalRatings,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
