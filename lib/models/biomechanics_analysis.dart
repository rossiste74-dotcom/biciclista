import 'dart:convert';

/// Cycle discipline type for biomechanical ranges
enum BikeType { road, ttTri, mtb }

/// Action type for technical adjustments
enum AdjustmentAction { up, down, fore, aft, increase, decrease, none }

/// Metadata about the analysis process
class BiomechanicsMetadata {
  final BikeType bikeTypeDetected;
  final double imageQualityScore;
  final List<String> validationErrors;

  BiomechanicsMetadata({
    required this.bikeTypeDetected,
    required this.imageQualityScore,
    required this.validationErrors,
  });

  factory BiomechanicsMetadata.fromJson(Map<String, dynamic> json) {
    return BiomechanicsMetadata(
      bikeTypeDetected: _parseBikeType(json['bike_type_detected']),
      imageQualityScore: (json['image_quality_score'] as num?)?.toDouble() ?? 0.0,
      validationErrors: (json['validation_errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bike_type_detected': bikeTypeDetected.name.toUpperCase(),
      'image_quality_score': imageQualityScore,
      'validation_errors': validationErrors,
    };
  }

  static BikeType _parseBikeType(String? type) {
    switch (type?.toUpperCase()) {
      case 'TT_TRI':
        return BikeType.ttTri;
      case 'MTB':
        return BikeType.mtb;
      case 'ROAD':
      default:
        return BikeType.road;
    }
  }
}

/// Core biometric measurements
class Biometrics {
  final double kneeExtensionAngle;
  final double backAngle;
  final double shoulderAngle;
  final double kopsOffsetMm;

  Biometrics({
    required this.kneeExtensionAngle,
    required this.backAngle,
    required this.shoulderAngle,
    required this.kopsOffsetMm,
  });

  factory Biometrics.fromJson(Map<String, dynamic> json) {
    return Biometrics(
      kneeExtensionAngle: (json['knee_extension_angle'] as num?)?.toDouble() ?? 0.0,
      backAngle: (json['back_angle'] as num?)?.toDouble() ?? 0.0,
      shoulderAngle: (json['shoulder_angle'] as num?)?.toDouble() ?? 0.0,
      kopsOffsetMm: (json['kops_offset_mm'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'knee_extension_angle': kneeExtensionAngle,
      'back_angle': backAngle,
      'shoulder_angle': shoulderAngle,
      'kops_offset_mm': kopsOffsetMm,
    };
  }
}

/// Single adjustment recommendation
class Recommendation {
  final AdjustmentAction action;
  final int valueMm;
  final String reason;

  Recommendation({
    required this.action,
    required this.valueMm,
    required this.reason,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      action: _parseAction(json['action']),
      valueMm: (json['value_mm'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action.name.toUpperCase(),
      'value_mm': valueMm,
      'reason': reason,
    };
  }

  static AdjustmentAction _parseAction(String? action) {
    switch (action?.toUpperCase()) {
      case 'UP': return AdjustmentAction.up;
      case 'DOWN': return AdjustmentAction.down;
      case 'FORE': return AdjustmentAction.fore;
      case 'AFT': return AdjustmentAction.aft;
      case 'INCREASE': return AdjustmentAction.increase;
      case 'DECREASE': return AdjustmentAction.decrease;
      case 'NONE':
      default:
        return AdjustmentAction.none;
    }
  }
}

/// Set of technical recommendations
class BiomechanicsRecommendations {
  final Recommendation saddleHeight;
  final Recommendation saddleForeAft;
  final Recommendation handlebarStack;

  BiomechanicsRecommendations({
    required this.saddleHeight,
    required this.saddleForeAft,
    required this.handlebarStack,
  });

  factory BiomechanicsRecommendations.fromJson(Map<String, dynamic> json) {
    return BiomechanicsRecommendations(
      saddleHeight: Recommendation.fromJson(json['saddle_height']),
      saddleForeAft: Recommendation.fromJson(json['saddle_fore_aft']),
      handlebarStack: Recommendation.fromJson(json['handlebar_stack']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saddle_height': saddleHeight.toJson(),
      'saddle_fore_aft': saddleForeAft.toJson(),
      'handlebar_stack': handlebarStack.toJson(),
    };
  }
}

/// Visual keypoint
class KeyPoint {
  final String label;
  final double x;
  final double y;

  KeyPoint({required this.label, required this.x, required this.y});

  factory KeyPoint.fromJson(Map<String, dynamic> json) {
    return KeyPoint(
      label: json['label'] as String,
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'x': x,
      'y': y,
    };
  }
}

/// Connection line for skeleton overlay
class SkeletonLine {
  final String from;
  final String to;

  SkeletonLine({required this.from, required this.to});

  factory SkeletonLine.fromJson(Map<String, dynamic> json) {
    return SkeletonLine(
      from: json['from'] as String,
      to: json['to'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
    };
  }
}

/// Data for visual overlay drawing
class VisualOverlay {
  final List<KeyPoint> points;
  final List<SkeletonLine> lines;

  VisualOverlay({required this.points, required this.lines});

  factory VisualOverlay.fromJson(Map<String, dynamic> json) {
    return VisualOverlay(
      points: (json['points'] as List<dynamic>?)
              ?.map((e) => KeyPoint.fromJson(e))
              .toList() ??
          [],
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => SkeletonLine.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((e) => e.toJson()).toList(),
      'lines': lines.map((e) => e.toJson()).toList(),
    };
  }
}

/// Top-level analysis result model
class BiomechanicsAnalysis {
  final BiomechanicsMetadata metadata;
  final Biometrics biometrics;
  final BiomechanicsRecommendations recommendations;
  final VisualOverlay visualOverlay;
  final String? verdict;
  final DateTime? createdAt;
  final String? id;

  BiomechanicsAnalysis({
    required this.metadata,
    required this.biometrics,
    required this.recommendations,
    required this.visualOverlay,
    this.verdict,
    this.createdAt,
    this.id,
  });

  factory BiomechanicsAnalysis.fromJson(Map<String, dynamic> json) {
    return BiomechanicsAnalysis(
      metadata: BiomechanicsMetadata.fromJson(json['metadata']),
      biometrics: Biometrics.fromJson(json['biometrics']),
      recommendations: BiomechanicsRecommendations.fromJson(json['recommendations']),
      visualOverlay: VisualOverlay.fromJson(json['visual_overlay']),
      verdict: json['verdict'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      id: json['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'biometrics': biometrics.toJson(),
      'recommendations': recommendations.toJson(),
      'visual_overlay': visualOverlay.toJson(),
      if (verdict != null) 'verdict': verdict,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (id != null) 'id': id,
    };
  }
}
