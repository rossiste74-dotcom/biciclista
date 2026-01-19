/// Model for real-time map markers (danger alerts, rest stops, etc.)
class MapMarker {
  final String id;
  final String userId;
  
  // Location
  final double latitude;
  final double longitude;
  
  // Type: danger, rest, info, photo
  final String markerType;
  
  // Info
  final String? title;
  final String? description;
  final String? imageUrl;
  
  // Expiration (24h auto)
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;

  MapMarker({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.markerType,
    this.title,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
  });

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    return MapMarker(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      markerType: json['marker_type'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'marker_type': markerType,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Check if marker is still valid (not expired)
  bool get isValid => isActive && expiresAt.isAfter(DateTime.now());

  /// Get remaining time until expiration
  Duration get timeRemaining => expiresAt.difference(DateTime.now());
}
