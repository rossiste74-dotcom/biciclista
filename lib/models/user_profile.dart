import 'dart:convert';
import 'package:flutter/material.dart';
import 'ai_provider.dart';
import 'user_avatar_config.dart';

enum UserRole {
  presidente,
  capitano,
  gregario,
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.presidente: return 'Presidente';
      case UserRole.capitano: return 'Capitano';
      case UserRole.gregario: return 'Gregario';
    }
  }

  String get icon {
    switch (this) {
      case UserRole.presidente: return '🏆🚵'; // Moto/Bici d'oro
      case UserRole.capitano: return '🚵';   // MTB
      case UserRole.gregario: return '🛺';   // Triciclo (Tuk-tuk)
    }
  }

  Widget iconWidget({double height = 24.0}) {
    switch (this) {
      case UserRole.presidente:
        return Image.asset('assets/ranks/presidente.png', height: height);
      case UserRole.capitano:
        return Image.asset('assets/ranks/capitano.png', height: height);
      case UserRole.gregario:
        return Image.asset('assets/ranks/gregario.png', height: height);
    }
  }
  
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'presidente': return UserRole.presidente;
      case 'capitano': return UserRole.capitano;
      default: return UserRole.gregario;
    }
  }
}

class MaintenanceDefinition {
  String? name;
  double? defaultInterval;
}

/// User Profile model
/// Mapped directly to Supabase 'profiles' table
class UserProfile {
  // Supabase UUID
  String id = '';
  
  /// User's role in the community
  UserRole role = UserRole.gregario;

  /// Maintenance definitions for all bikes
  List<MaintenanceDefinition> maintenanceDefinitions = [];

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
  late int thermalSensitivity;

  /// User's preferred distance unit (km or miles)
  late String preferredUnit;

  /// Clothing thresholds (Celsius)
  late double hotThreshold;
  late double warmThreshold;
  late double coolThreshold;
  late double coldThreshold;
  
  /// Adjustment factor for thermal sensitivity
  late double sensitivityAdjustment;

  /// Clothing Kits (indices)
  late List<int> hotKit;
  late List<int> warmKit;
  late List<int> coolKit;
  late List<int> coldKit;
  late List<int> veryColdKit;

  /// Difficulty index weights
  late double difficultyDistanceWeight;
  late double difficultyElevationWeight;

  // ==================== Navigation Settings ====================
  bool enableVoiceAlerts = true;
  int alertType = 0;
  double offCourseThresholdM = 30.0;
  bool energySavingMode = false;

  // ==================== Health Tracking ====================
  int hrv = 0;
  double sleepHours = 0.0;
  String? healthHistory; // JSON
  DateTime? lastHealthSync;

  // ==================== Cloud Sync ====================
  // Legacy flag, now implicit
  bool isCommunityMode = true; 
  String? supabaseUserId;
  String? avatarData; // JSON

  // ==================== AI Configuration ====================
  // Stored as int index 0-255 in DB for efficiency or string? 
  // Let's keep using int mapping for now to match logic.
  int aiProviderIndex = 255;
  String? aiApiKey;
  String? coachPersonality;
  String? aiModel;

  late DateTime createdAt;
  late DateTime updatedAt;

  UserProfile() {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
    
    // Defaults
    age = 30;
    weight = 70.0;
    restingHeartRate = 60;
    functionalThresholdPower = 200;
    thermalSensitivity = 3;
    preferredUnit = 'km';
    
    hotThreshold = 20.0;
    warmThreshold = 15.0;
    coolThreshold = 10.0;
    coldThreshold = 5.0;
    sensitivityAdjustment = 3.0;
    
    maintenanceDefinitions = [
      MaintenanceDefinition()..name = 'Catena'..defaultInterval = 3500.0,
      MaintenanceDefinition()..name = 'Copertoni'..defaultInterval = 5000.0,
      MaintenanceDefinition()..name = 'Freni'..defaultInterval = 2500.0,
    ];

    hotKit = [0]; 
    warmKit = [0]; 
    coolKit = [0, 4, 2];
    coldKit = [8, 5, 3];
    veryColdKit = [8, 6, 3, 9, 10, 11];

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
    if (weight != null && weight > 0) this.weight = weight;
    if (hrv != null && hrv > 0) this.hrv = hrv;
    if (sleepHours != null && sleepHours > 0) this.sleepHours = sleepHours;
    
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    List<dynamic> history = [];
    
    if (healthHistory != null && healthHistory!.isNotEmpty) {
      try {
        history = json.decode(healthHistory!);
      } catch (e) {
        history = [];
      }
    }

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

    history.sort((a, b) => a['date'].compareTo(b['date']));
    if (history.length > 30) {
      history = history.sublist(history.length - 30);
    }

    healthHistory = json.encode(history);
    updatedAt = DateTime.now();
  }

  AIProvider? getAIProvider() {
    if (aiProviderIndex == 255) return null;
    return AIProvider.values[aiProviderIndex];
  }

  void setAIProvider(AIProvider? provider) {
    aiProviderIndex = provider == null ? 255 : provider.index;
  }
  
  // TO_JSON / FROM_JSON could be useful for Supabase, 
  // but we might handle that in service.
  UserAvatarConfig? get avatarConfig {
    if (avatarData == null) return null;
    return UserAvatarConfig.fromJsonString(avatarData!);
  }
}
