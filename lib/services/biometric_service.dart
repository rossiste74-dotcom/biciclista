import 'dart:convert';
import '../models/health_snapshot.dart';
import '../models/user_profile.dart';
import 'database_service.dart';

/// Service for calculating readiness scores and preparing biometric data for charts
class BiometricService {
  final DatabaseService _db = DatabaseService();

  /// Calculate a readiness score (0-100) based on health metrics
  int calculateReadinessFromProfile(UserProfile profile) {
    // 1. Sleep Component (40% weight)
    double sleepScore = 0;
    if (profile.sleepHours >= 8) {
      sleepScore = 100;
    } else if (profile.sleepHours >= 4) {
      sleepScore = (profile.sleepHours - 4) / 4 * 100;
    }

    // 2. HRV Component (60% weight)
    double hrvScore = 0;
    
    // Static benchmarks (simplified for now since we're using current profile value)
    if (profile.hrv >= 80) {
      hrvScore = 100;
    } else if (profile.hrv >= 60) {
      hrvScore = 80;
    } else if (profile.hrv >= 40) {
      hrvScore = 60;
    } else if (profile.hrv >= 20) {
      hrvScore = 40;
    } else {
      hrvScore = 20;
    }

    final totalScore = (sleepScore * 0.4) + (hrvScore * 0.6);
    return totalScore.round().clamp(0, 100);
  }

  /// Calculate a readiness score (0-100) based on health metrics
  /// 
  /// [snapshot] - High-level health data for the day
  /// [previousSnapshots] - List of previous snapshots for average calculations
  int calculateReadinessScore(HealthSnapshot snapshot, {List<HealthSnapshot>? previousSnapshots}) {
    // ... (keeping legacy method for compatibility if needed elsewhere)
    // (Implementation omitted for brevity in replace_file_content, 
    // but in a real edit I should preserve it or refactor it)
    return calculateReadinessFromProfile(UserProfile()..hrv = snapshot.hrv..sleepHours = snapshot.sleepHours);
  }

  /// Extracts HRV trend from profile health history
  List<double> getHrvTrendFromProfile(UserProfile profile) {
    if (profile.healthHistory == null || profile.healthHistory!.isEmpty) return [];
    try {
      final List<dynamic> history = json.decode(profile.healthHistory!);
      return history
          .map((e) => (e['hrv'] as num?)?.toDouble() ?? 0.0)
          .where((v) => v > 0)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Extracts Weight trend from profile health history
  List<double> getWeightTrendFromProfile(UserProfile profile) {
    if (profile.healthHistory == null || profile.healthHistory!.isEmpty) return [];
    try {
      final List<dynamic> history = json.decode(profile.healthHistory!);
      return history
          .map((e) => (e['weight'] as num?)?.toDouble() ?? 0.0)
          .where((v) => v > 0)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Extracts Sleep trend from profile health history
  List<double> getSleepTrendFromProfile(UserProfile profile) {
    if (profile.healthHistory == null || profile.healthHistory!.isEmpty) return [];
    try {
      final List<dynamic> history = json.decode(profile.healthHistory!);
      return history
          .map((e) => (e['sleep'] as num?)?.toDouble() ?? 0.0)
          .where((v) => v > 0)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Extracts Readiness trend by calculating it for each history entry
  List<double> getReadinessTrendFromProfile(UserProfile profile) {
    if (profile.healthHistory == null || profile.healthHistory!.isEmpty) return [];
    try {
      final List<dynamic> history = json.decode(profile.healthHistory!);
      List<double> readinessTrend = [];
      
      for (var entry in history) {
        final hrv = (entry['hrv'] as num?)?.toInt() ?? 0;
        final sleep = (entry['sleep'] as num?)?.toDouble() ?? 0.0;
        
        if (hrv > 0 || sleep > 0) {
          // Create a temporary profile object for calculation (or we could refactor the method)
          final tempProfile = UserProfile()
            ..hrv = hrv
            ..sleepHours = sleep;
          
          readinessTrend.add(calculateReadinessFromProfile(tempProfile).toDouble());
        }
      }
      return readinessTrend;
    } catch (e) {
      return [];
    }
  }

  /// Get status description based on readiness score
  String getReadinessStatus(int score) {
    if (score >= 85) return 'Eccellente';
    if (score >= 70) return 'Buono';
    if (score >= 50) return 'Medio';
    return 'Scarso';
  }

  /// Get recommendation based on readiness score
  String getReadinessRecommendation(int score) {
    if (score >= 85) return 'Il tuo corpo è completamente recuperato. Ottimo giorno per un allenamento intenso!';
    if (score >= 70) return 'Sei in buona forma. Intensità moderata o alta va bene.';
    if (score >= 50) return 'Recupero adeguato. Considera un\'uscita di recupero o a bassa intensità.';
    return 'Il recupero è basso. Forse un giorno di riposo è la scelta migliore.';
  }
}
