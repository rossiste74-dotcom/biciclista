/// Model for group ride participants
class GroupRideParticipant {
  final String id;
  final String userId;
  final String displayName;
  final String? profileImageUrl;
  final String status; // pending, confirmed, declined, left
  final bool isCreator;
  final DateTime joinedAt;

  GroupRideParticipant({
    required this.id,
    required this.userId,
    required this.displayName,
    this.profileImageUrl,
    this.status = 'confirmed',
    this.isCreator = false,
    required this.joinedAt,
  });

  factory GroupRideParticipant.fromJson(Map<String, dynamic> json) {
    return GroupRideParticipant(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String? ?? 'Ciclista',
      profileImageUrl: json['profile_image_url'] as String?,
      status: json['status'] as String? ?? 'confirmed',
      isCreator: json['is_creator'] as bool? ?? false,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }
  GroupRideParticipant copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? profileImageUrl,
    String? status,
    bool? isCreator,
    DateTime? joinedAt,
  }) {
    return GroupRideParticipant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      isCreator: isCreator ?? this.isCreator,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

/// Model for group rides (uscite di gruppo)
class GroupRide {
  final String id;
  final String creatorId;
  final String rideName;
  final String? description;
  
  // Route data
  final Map<String, dynamic>? gpxData;
  final String? gpxFileUrl;
  final String? gpxFilePath; // Local file path
  final double? distance;
  final double? elevation;
  
  // Meeting info
  final String meetingPoint;
  final double? meetingLatitude;
  final double? meetingLongitude;
  final DateTime meetingTime;
  
  // Difficulty: easy, medium, hard, expert
  final String difficultyLevel;
  
  // Participants
  final int maxParticipants;
  final int currentParticipants;
  List<GroupRideParticipant> participants;
  
  // Visibility
  final bool isPublic;
  
  // Status: planned, active, completed, cancelled
  final String status;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupRide({
    required this.id,
    required this.creatorId,
    required this.rideName,
    this.description,
    this.gpxData,
    this.gpxFileUrl,
    this.gpxFilePath,
    this.distance,
    this.elevation,
    required this.meetingPoint,
    this.meetingLatitude,
    this.meetingLongitude,
    required this.meetingTime,
    this.difficultyLevel = 'medium',
    this.maxParticipants = 10,
    this.currentParticipants = 0,
    this.participants = const [],
    this.isPublic = true,
    this.status = 'planned',
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupRide.fromJson(Map<String, dynamic> json) {
    var participantsList = <GroupRideParticipant>[];

    // Check both aliased and raw key
    final rawParticipants = json['participants'] ?? json['group_ride_participants'];
    
    if (rawParticipants != null) {
      participantsList = (rawParticipants as List)
          .map((p) => GroupRideParticipant.fromJson(p))
          .toList();
    }

    return GroupRide(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      rideName: json['ride_name'] as String,
      description: json['description'] as String?,
      gpxData: json['gpx_data'] as Map<String, dynamic>?,
      gpxFileUrl: json['gpx_file_url'] as String?,
      gpxFilePath: json['gpx_file_path'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      elevation: (json['elevation'] as num?)?.toDouble(),
      meetingPoint: json['meeting_point'] as String,
      meetingLatitude: (json['meeting_latitude'] as num?)?.toDouble(),
      meetingLongitude: (json['meeting_longitude'] as num?)?.toDouble(),
      meetingTime: DateTime.parse(json['meeting_time'] as String),
      difficultyLevel: json['difficulty_level'] as String? ?? 'medium',
      maxParticipants: json['max_participants'] as int? ?? 10,
      currentParticipants: json['current_participants'] as int? ?? participantsList.length,
      participants: participantsList,
      isPublic: json['is_public'] as bool? ?? true,
      status: json['status'] as String? ?? 'planned',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'ride_name': rideName,
      'description': description,
      'gpx_data': gpxData,
      'gpx_file_url': gpxFileUrl,
      'gpx_file_path': gpxFilePath,
      'distance': distance,
      'elevation': elevation,
      'meeting_point': meetingPoint,
      'meeting_latitude': meetingLatitude,
      'meeting_longitude': meetingLongitude,
      'meeting_time': meetingTime.toIso8601String(),
      'difficulty_level': difficultyLevel,
      'max_participants': maxParticipants,
      'is_public': isPublic,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GroupRide copyWith({
    String? id,
    String? creatorId,
    String? rideName,
    String? description,
    Map<String, dynamic>? gpxData,
    String? gpxFileUrl,
    String? gpxFilePath,
    double? distance,
    double? elevation,
    String? meetingPoint,
    double? meetingLatitude,
    double? meetingLongitude,
    DateTime? meetingTime,
    String? difficultyLevel,
    int? maxParticipants,
    int? currentParticipants,
    List<GroupRideParticipant>? participants,
    bool? isPublic,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupRide(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      rideName: rideName ?? this.rideName,
      description: description ?? this.description,
      gpxData: gpxData ?? this.gpxData,
      gpxFileUrl: gpxFileUrl ?? this.gpxFileUrl,
      gpxFilePath: gpxFilePath ?? this.gpxFilePath,
      distance: distance ?? this.distance,
      elevation: elevation ?? this.elevation,
      meetingPoint: meetingPoint ?? this.meetingPoint,
      meetingLatitude: meetingLatitude ?? this.meetingLatitude,
      meetingLongitude: meetingLongitude ?? this.meetingLongitude,
      meetingTime: meetingTime ?? this.meetingTime,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      participants: participants ?? this.participants,
      isPublic: isPublic ?? this.isPublic,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
