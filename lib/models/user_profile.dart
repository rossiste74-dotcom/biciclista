import 'package:isar/isar.dart';
import 'dart:convert';
import 'ai_provider.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  /// User's name
  String? name;

  /// User's gender
  String? gender;

  /// User's age in years
  late int age;

  /// User's weight in kilograms
  late double weight;

  /// User's height in centimeters
  double? height;

  /// Resting Heart Rate (RHR) in beats per minute
  late int restingHeartRate;

  /// Functional Threshold Power (FTP) in watts
  late int functionalThresholdPower;

  /// Thermal sensitivity scale (1-5)
  /// 1 = Very cold-resistant
  /// 3 = Average
  /// 5 = Very cold-sensitive
  @Index()
  late int thermalSensitivity;

  /// User's preferred distance unit (km or miles)
  late String preferredUnit;

  /// Clothing thresholds (Celsius)
  /// Temperature > hotThreshold: Summer kit
  late double hotThreshold;
  /// Temperature 15-20: Summer kit + Vest
  late double warmThreshold;
  /// Temperature 10-15: Long sleeves
  late double coolThreshold;
  /// Temperature 5-10: Light jacket
  late double coldThreshold;
  /// Temperature < 5: Winter gear
  
  /// Adjustment factor for thermal sensitivity (degrees per level)
  late double sensitivityAdjustment;

  /// Clothing Kits (stored as lists of ClothingItem enum indexes)
  late List<int> hotKit;
  late List<int> warmKit;
  late List<int> coolKit;
  late List<int> coldKit;
  late List<int> veryColdKit;

  /// Difficulty index weights
  late double difficultyDistanceWeight;
  late double difficultyElevationWeight;

  // ==================== Navigation Settings ====================
  /// Enable voice alerts for off-course warnings
  bool enableVoiceAlerts = true;
  
  /// Alert type: 0 = Both, 1 = Only Voice, 2 = Only Vibration
  int alertType = 0;
  
  /// Off-course distance threshold in meters
  double offCourseThresholdM = 30.0;
  
  /// Energy saving mode (allows screen to turn off)
  bool energySavingMode = false;

  // ==================== Health Tracking ====================
  /// Heart Rate Variability (HRV) in milliseconds
  int hrv = 0;
  
  /// Daily sleep hours
  double sleepHours = 0.0;
  
  /// Health data history (JSON string with date/weight/hrv/sleep objects)
  /// Format: [{"date": "2024-01-16", "weight": 75.0, "hrv": 45, "sleep": 7.5}, ...]
  String? healthHistory;
  
  /// Timestamp of last health sync
  DateTime? lastHealthSync;

  // ==================== AI Configuration ====================
  /// Selected AI provider for AI Coach feature (stored as byte index, 255 = not set)
  @Index()
  byte aiProviderIndex = 255;
  
  /// API key for the selected AI provider (stored locally, not synced)
  String? aiApiKey;

  /// Timestamp when the profile was created
  late DateTime createdAt;

  /// Timestamp when the profile was last updated
  late DateTime updatedAt;

  UserProfile() {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
    
    // Default thresholds
    hotThreshold = 20.0;
    warmThreshold = 15.0;
    coolThreshold = 10.0;
    coldThreshold = 5.0;
    sensitivityAdjustment = 3.0; // +/- 3 degrees based on sensitivity

    // Default kits (using ClothingItem enum indexes)
    // 0: summerKit, 1: vest, 2: armWarmers, 3: legWarmers, 4: longSleeveJersey
    // 5: lightJacket, 6: winterJacket, 7: windbreaker, 8: baseLayer, 9: thermalGloves
    // 10: shoeCovers, 11: neckWarmer
    hotKit = [0]; // summerKit
    warmKit = [0]; // summerKit (vest is added dynamically for wind)
    coolKit = [0, 4, 2]; // summerKit, longSleeveJersey, armWarmers
    coldKit = [8, 5, 3]; // baseLayer, lightJacket, legWarmers
    veryColdKit = [8, 6, 3, 9, 10, 11]; // baseLayer, winterJacket, legWarmers, gloves, shoeCovers, neckWarmer

    // Default difficulty weights
    difficultyDistanceWeight = 0.05;
    difficultyElevationWeight = 0.008;
  }

  /// Updates current biometric values and appends to health history JSON
  void updateHealthSnapshot({
    required DateTime date,
    double? weight,
    int? hrv,
    double? sleepHours,
  }) {
    // 1. Update summary fields if this is latest or has values
    if (weight != null && weight > 0) this.weight = weight;
    if (hrv != null && hrv > 0) this.hrv = hrv;
    if (sleepHours != null && sleepHours > 0) this.sleepHours = sleepHours;
    
    // 2. Manage history JSON
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    List<dynamic> history = [];
    
    if (healthHistory != null && healthHistory!.isNotEmpty) {
      try {
        history = json.decode(healthHistory!);
      } catch (e) {
        history = [];
      }
    }

    // Find if entry for this date already exists
    int existingIndex = history.indexWhere((e) => e['date'] == dateStr);
    
    Map<String, dynamic> entry = existingIndex != -1 
        ? Map<String, dynamic>.from(history[existingIndex])
        : {'date': dateStr};

    if (weight != null && weight > 0) entry['weight'] = weight;
    if (hrv != null && hrv > 0) entry['hrv'] = hrv;
    if (sleepHours != null && sleepHours > 0) entry['sleep'] = sleepHours;

    if (existingIndex != -1) {
      history[existingIndex] = entry;
    } else {
      history.add(entry);
    }

    // Sort by date and keep reasonable amount (e.g., last 30 days)
    history.sort((a, b) => a['date'].compareTo(b['date']));
    if (history.length > 30) {
      history = history.sublist(history.length - 30);
    }

    healthHistory = json.encode(history);
    updatedAt = DateTime.now();
  }

  /// Get the AI provider from the stored byte index
  AIProvider? getAIProvider() {
    if (aiProviderIndex == 255) return null;
    return AIProvider.values[aiProviderIndex];
  }

  /// Set the AI provider by storing its index
  void setAIProvider(AIProvider? provider) {
    aiProviderIndex = provider == null ? 255 : provider.index;
  }
}
