/// Model for public user profiles
class PublicProfile {
  final String id;
  final String userId;
  
  // Public info
  final String displayName;
  final String? bio;
  final String? profileImageUrl;
  
  // Privacy settings
  final bool isPrivate;
  final bool showGarage;
  final bool showStats;
  
  // Statistics
  final double totalKm;
  final int totalRides;
  final double totalElevation;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  PublicProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    this.bio,
    this.profileImageUrl,
    this.isPrivate = false,
    this.showGarage = false,
    this.showStats = true,
    this.totalKm = 0.0,
    this.totalRides = 0,
    this.totalElevation = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PublicProfile.fromJson(Map<String, dynamic> json) {
    return PublicProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      bio: json['bio'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
      showGarage: json['show_garage'] as bool? ?? false,
      showStats: json['show_stats'] as bool? ?? true,
      totalKm: (json['total_km'] as num?)?.toDouble() ?? 0.0,
      totalRides: json['total_rides'] as int? ?? 0,
      totalElevation: (json['total_elevation'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': displayName,
      'bio': bio,
      'profile_image_url': profileImageUrl,
      'is_private': isPrivate,
      'show_garage': showGarage,
      'show_stats': showStats,
      'total_km': totalKm,
      'total_rides': totalRides,
      'total_elevation': totalElevation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PublicProfile copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? bio,
    String? profileImageUrl,
    bool? isPrivate,
    bool? showGarage,
    bool? showStats,
    double? totalKm,
    int? totalRides,
    double? totalElevation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PublicProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      showGarage: showGarage ?? this.showGarage,
      showStats: showStats ?? this.showStats,
      totalKm: totalKm ?? this.totalKm,
      totalRides: totalRides ?? this.totalRides,
      totalElevation: totalElevation ?? this.totalElevation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
