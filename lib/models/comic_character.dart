class ComicCharacter {
  final String id;
  final String name;
  final String description;
  final String? avatarUrl;
  final String? visualDescription;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComicCharacter({
    required this.id,
    required this.name,
    required this.description,
    this.avatarUrl,
    this.visualDescription,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComicCharacter.fromJson(Map<String, dynamic> json) {
    return ComicCharacter(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      avatarUrl: json['avatar_url'] as String?,
      visualDescription: json['visual_description'] as String?,
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar_url': avatarUrl,
      'visual_description': visualDescription,
      if (userId != null) 'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ComicCharacter copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? visualDescription,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComicCharacter(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      visualDescription: visualDescription ?? this.visualDescription,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
