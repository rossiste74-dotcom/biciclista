import 'package:flutter/material.dart';
import 'dart:convert';

enum AvatarGender { male, female, other }
enum HairStyle { short, long, curly, bald }

class UserAvatarConfig {
  AvatarGender gender;
  HairStyle hairStyle;
  Color hairColor;
  Color skinTone;
  bool hasBeard;
  Color helmetColor;
  Color jerseyColor;

  UserAvatarConfig({
    required this.gender,
    required this.hairStyle,
    required this.hairColor,
    required this.skinTone,
    required this.hasBeard,
    required this.helmetColor,
    required this.jerseyColor,
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
    };
  }

  factory UserAvatarConfig.fromJson(Map<String, dynamic> json) {
    return UserAvatarConfig(
      gender: AvatarGender.values[json['gender'] ?? 0],
      hairStyle: HairStyle.values[json['hairStyle'] ?? 0],
      hairColor: Color(json['hairColor'] ?? Colors.brown.value),
      skinTone: Color(json['skinTone'] ?? 0xFFFFE0BD),
      hasBeard: json['hasBeard'] ?? false,
      helmetColor: Color(json['helmetColor'] ?? Colors.blue.value),
      jerseyColor: Color(json['jerseyColor'] ?? Colors.red.value),
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
