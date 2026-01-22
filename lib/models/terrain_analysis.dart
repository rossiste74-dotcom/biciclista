/// Terrain breakdown for a route segment
/// Shows percentage distribution of different surface types
class TerrainBreakdown {
  final double asphaltPercent;
  final double gravelPercent;
  final double pathPercent;

  const TerrainBreakdown({
    required this.asphaltPercent,
    required this.gravelPercent,
    required this.pathPercent,
  });

  factory TerrainBreakdown.fromJson(Map<String, dynamic> json) {
    return TerrainBreakdown(
      asphaltPercent: (json['asphalt_percent'] as num?)?.toDouble() ?? 0.0,
      gravelPercent: (json['gravel_percent'] as num?)?.toDouble() ?? 0.0,
      pathPercent: (json['path_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asphalt_percent': asphaltPercent,
      'gravel_percent': gravelPercent,
      'path_percent': pathPercent,
    };
  }

  /// Get dominant terrain type
  String get dominantTerrain {
    if (asphaltPercent >= gravelPercent && asphaltPercent >= pathPercent) {
      return 'Asfalto';
    } else if (gravelPercent >= pathPercent) {
      return 'Sterrato';
    } else {
      return 'Sentiero';
    }
  }
}

/// Technical difficulty rating for a route
/// Based on terrain composition, elevation, and distance
enum DifficultyRating {
  beginner,    // 1 🚴 Asfalto/ciclabili
  easy,        // 2 🚴 Strade bianche facili
  moderate,    // 3 🚵 Gravel tecnico
  hard,        // 4 🚵 Sentieri MTB
  expert,      // 5 ⛰️ Single track difficili
}

extension DifficultyRatingExtension on DifficultyRating {
  /// Get numeric difficulty (1-5)
  int get level {
    switch (this) {
      case DifficultyRating.beginner:
        return 1;
      case DifficultyRating.easy:
        return 2;
      case DifficultyRating.moderate:
        return 3;
      case DifficultyRating.hard:
        return 4;
      case DifficultyRating.expert:
        return 5;
    }
  }

  /// Get difficulty label in Italian
  String get label {
    switch (this) {
      case DifficultyRating.beginner:
        return 'Principiante';
      case DifficultyRating.easy:
        return 'Facile';
      case DifficultyRating.moderate:
        return 'Moderato';
      case DifficultyRating.hard:
        return 'Difficile';
      case DifficultyRating.expert:
        return 'Esperto';
    }
  }

  /// Get emoji icon
  String get emoji {
    switch (this) {
      case DifficultyRating.beginner:
        return '🚴';
      case DifficultyRating.easy:
        return '🚴‍♂️';
      case DifficultyRating.moderate:
        return '🚵';
      case DifficultyRating.hard:
        return '🚵‍♂️';
      case DifficultyRating.expert:
        return '⛰️';
    }
  }

  /// Get color for UI
  String get colorHex {
    switch (this) {
      case DifficultyRating.beginner:
        return '#4CAF50'; // Green
      case DifficultyRating.easy:
        return '#8BC34A'; // Light Green
      case DifficultyRating.moderate:
        return '#FFC107'; // Amber
      case DifficultyRating.hard:
        return '#FF5722'; // Deep Orange
      case DifficultyRating.expert:
        return '#D32F2F'; // Red
    }
  }

  /// Parse from numeric level
  static DifficultyRating fromLevel(int level) {
    switch (level) {
      case 1:
        return DifficultyRating.beginner;
      case 2:
        return DifficultyRating.easy;
      case 3:
        return DifficultyRating.moderate;
      case 4:
        return DifficultyRating.hard;
      case 5:
        return DifficultyRating.expert;
      default:
        return DifficultyRating.beginner;
    }
  }
}

/// Helper function to convert difficulty level to enum
DifficultyRating difficultyFromLevel(int level) {
  return DifficultyRatingExtension.fromLevel(level);
}
