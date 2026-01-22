/// Route preferences for advanced routing configuration
class RoutePreferences {
  /// Prioritize cycleways and bike lanes
  final bool prioritizeCycleways;
  
  /// Avoid steep climbs (slopes > threshold)
  final bool avoidSteepClimbs;
  
  /// Slope threshold percentage for "steep" classification
  /// Default: 7.0%
  final double steepSlopeThreshold;
  
  /// Distance influence factor (0.0-1.0)
  /// Higher values prefer shorter routes even if less ideal terrain
  /// Lower values prefer better terrain even if longer
  final double distanceInfluence;

  const RoutePreferences({
    this.prioritizeCycleways = true,
    this.avoidSteepClimbs = false,
    this.steepSlopeThreshold = 7.0,
    this.distanceInfluence = 0.5,
  });
  
  RoutePreferences copyWith({
    bool? prioritizeCycleways,
    bool? avoidSteepClimbs,
    double? steepSlopeThreshold,
    double? distanceInfluence,
  }) {
    return RoutePreferences(
      prioritizeCycleways: prioritizeCycleways ?? this.prioritizeCycleways,
      avoidSteepClimbs: avoidSteepClimbs ?? this.avoidSteepClimbs,
      steepSlopeThreshold: steepSlopeThreshold ?? this.steepSlopeThreshold,
      distanceInfluence: distanceInfluence ?? this.distanceInfluence,
    );
  }
}
