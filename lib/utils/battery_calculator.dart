/// Battery consumption calculator for e-bikes
/// 
/// Calculates estimated energy consumption in Wh (Watt-hours)
/// based on route characteristics and bike configuration
class BatteryCalculator {
  /// Calculate total energy consumption for a route
  /// 
  /// Returns estimated consumption in Wh
  static double calculateConsumption({
    required double totalDistanceKm,
    required double elevationGainM,
    required double userWeightKg,
    required double bikeWeightKg,
    required int assistanceLevel, // 1-5
  }) {
    // 1. Gravitational potential energy
    // E = m * g * h
    // Convert to Wh: Joules / 3600
    final totalMass = userWeightKg + bikeWeightKg;
    final gravitationalWh = (totalMass * 9.81 * elevationGainM) / 3600;
    
    // 2. Base consumption for flat terrain
    // Depends on assistance level (2-10 Wh/km range)
    // Eco (1): 2 Wh/km
    // Medium (3): 6 Wh/km
    // Turbo (5): 10 Wh/km
    final baseWhPerKm = assistanceLevel * 2.0;
    final flatConsumption = totalDistanceKm * baseWhPerKm;
    
    // 3. Total consumption (simplified model)
    // Real-world factors like wind, rolling resistance vary
    // This gives a reasonable estimate
    return gravitationalWh + flatConsumption;
  }
  
  /// Calculate remaining battery percentage after route
  /// 
  /// Returns value between 0.0 and 100.0
  static double calculateRemainingBattery({
    required double batteryCapacityWh,
    required double consumptionWh,
    double currentBatteryPercent = 100.0,
  }) {
    final currentWh = batteryCapacityWh * (currentBatteryPercent / 100.0);
    final remainingWh = currentWh - consumptionWh;
    final remainingPercent = (remainingWh / batteryCapacityWh) * 100.0;
    
    // Clamp between 0 and 100
    return remainingPercent.clamp(0.0, 100.0);
  }
  
  /// Check if route is feasible with current battery level
  static bool isRouteFeasible({
    required double batteryCapacityWh,
    required double consumptionWh,
    double currentBatteryPercent = 100.0,
    double safetyMarginPercent = 10.0, // Reserve 10% safety margin
  }) {
    final remaining = calculateRemainingBattery(
      batteryCapacityWh: batteryCapacityWh,
      consumptionWh: consumptionWh,
      currentBatteryPercent: currentBatteryPercent,
    );
    
    return remaining >= safetyMarginPercent;
  }
}
