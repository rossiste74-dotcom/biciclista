import 'package:flutter/material.dart';
import 'dart:convert';

enum AvatarGender { male, female, other }
enum HairStyle { short, long, bald }

class UserAvatarConfig {
  AvatarGender gender;
  HairStyle hairStyle;
  Color hairColor;
  Color skinTone;
  bool hasBeard;
  Color helmetColor;
  Color jerseyColor;
  Color jerseyColor2;
  Color jerseyColor3;
  bool hasGlasses;

  UserAvatarConfig({
    required this.gender,
    required this.hairStyle,
    required this.hairColor,
    required this.skinTone,
    required this.hasBeard,
    required this.helmetColor,
    required this.jerseyColor,
    required this.jerseyColor2,
    required this.jerseyColor3,
    required this.hasGlasses,
  });

  factory UserAvatarConfig.defaultConfig() {
    return UserAvatarConfig(
      gender: AvatarGender.male,
      hairStyle: HairStyle.short,
      hairColor: Colors.brown,
      skinTone: const Color(0xFFFFE0BD),
      hasBeard: false,
      helmetColor: Colors.blue,
      jerseyColor: Colors.red,
      jerseyColor2: Colors.white,
      jerseyColor3: Colors.black,
      hasGlasses: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender.index,
      'hairStyle': hairStyle.index,
      'hairColor': hairColor.value,
      'skinTone': skinTone.value,
      'hasBeard': hasBeard,
      'helmetColor': helmetColor.value,
      'jerseyColor': jerseyColor.value,
      'jerseyColor2': jerseyColor2.value,
      'jerseyColor3': jerseyColor3.value,
      'hasGlasses': hasGlasses,
    };
  }

  factory UserAvatarConfig.fromJson(Map<String, dynamic> json) {
    // Handle legacy 'curly' index (was 2) or moved indices if needed. 
    // Enum values were: short (0), long (1), curly (2), bald (3).
    // Now: short (0), long (1), bald (2).
    // If we see index 2 (old curly), map it to something else (e.g., short 0) or map old bald (3) to new bald (2).
    // Safer: check raw value.
    
    int hairStyleIndex = json['hairStyle'] ?? 0;
    HairStyle style = HairStyle.short;
    
    // Legacy migration logic
    if (hairStyleIndex == 2) { 
        // Was curly, now mapped to short (or we can handle it differently)
        style = HairStyle.short; 
    } else if (hairStyleIndex == 3) {
        // Was bald, now index 2
        style = HairStyle.bald;
    } else if (hairStyleIndex >= 0 && hairStyleIndex < HairStyle.values.length) {
        style = HairStyle.values[hairStyleIndex];
    }

    return UserAvatarConfig(
      gender: AvatarGender.values[json['gender'] ?? 0],
      hairStyle: style,
      hairColor: Color(json['hairColor'] ?? Colors.brown.value),
      skinTone: Color(json['skinTone'] ?? 0xFFFFE0BD),
      hasBeard: json['hasBeard'] ?? false,
      helmetColor: Color(json['helmetColor'] ?? Colors.blue.value),
      jerseyColor: Color(json['jerseyColor'] ?? Colors.red.value),
      jerseyColor2: Color(json['jerseyColor2'] ?? Colors.white.value),
      jerseyColor3: Color(json['jerseyColor3'] ?? Colors.black.value),
      hasGlasses: json['hasGlasses'] ?? false,
    );
  }

  static UserAvatarConfig fromJsonString(String jsonString) {
    try {
      if (jsonString.isEmpty) return UserAvatarConfig.defaultConfig();
      return UserAvatarConfig.fromJson(json.decode(jsonString));
    } catch (e) {
      return UserAvatarConfig.defaultConfig();
    }
  }

  String toJsonString() => json.encode(toJson());
}
