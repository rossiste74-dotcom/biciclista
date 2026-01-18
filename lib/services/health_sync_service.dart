import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'database_service.dart';
import '../models/health_snapshot.dart';

/// Service for synchronizing health data from Apple Health or Google Fit
class HealthSyncService {
  final _health = Health();
  final _db = DatabaseService();

  /// Request permissions for required health data types
  Future<bool> requestPermissions() async {
    // Configure to use Health Connect
    // await _health.configure(useHealthConnectIfAvailable: true);

    final types = [
       HealthDataType.HEART_RATE,
       HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
       HealthDataType.SLEEP_SESSION,
       HealthDataType.WEIGHT,
    ];

    try {
      final status = await _health.getHealthConnectSdkStatus();
      debugPrint('Health Connect Status: $status');

      if (status == HealthConnectSdkStatus.sdkUnavailable) {
         debugPrint('Health Connect SDK unavailable. Skipping payload request.');
         return false;
      }
      
      return await _health.requestAuthorization(
        types,
        permissions: types.map((e) => HealthDataAccess.READ).toList(),
      );
    } catch (e) {
      debugPrint('Error requesting health permissions: $e');
      return false;
    }
  }

  /// Synchronize health data for the last 7 days
  Future<void> syncRecentData() async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
      HealthDataType.SLEEP_SESSION,
      HealthDataType.WEIGHT,
    ];

    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));

    // For simplicity in this demo, we'll fetch only for "yesterday" or "today"
    // and map it to a HealthSnapshot. Real implementations would iterate through days.
    
    try {
      final healthData = await _health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: now,
        types: types,
      );
      
      final profile = await _db.getUserProfile();
      if (profile == null) return;

      // Group data by date to batch updates to the profile history
      Map<DateTime, Map<String, dynamic>> dailyData = {};

      for (var data in healthData) {
        final date = DateTime(data.dateFrom.year, data.dateFrom.month, data.dateFrom.day);
        dailyData.putIfAbsent(date, () => {});
        
        double? numericValue;
        if (data.value is NumericHealthValue) {
          numericValue = (data.value as NumericHealthValue).numericValue.toDouble();
        }

        switch (data.type) {
          case HealthDataType.WEIGHT:
            if (numericValue != null) {
              dailyData[date]!['weight'] = numericValue;
            }
            break;
          case HealthDataType.HEART_RATE:
          case HealthDataType.HEART_RATE_VARIABILITY_RMSSD:
            if (numericValue != null) {
              dailyData[date]!['hrv'] = numericValue.toInt();
            }
            break;
          case HealthDataType.SLEEP_SESSION:
            final duration = data.dateTo.difference(data.dateFrom).inMinutes / 60.0;
            dailyData[date]!['sleep'] = (dailyData[date]!['sleep'] ?? 0.0) + duration;
            break;
          default:
            break;
        }
      }

      // Update UserProfile history and summary fields
      for (var entry in dailyData.entries) {
        profile.updateHealthSnapshot(
          date: entry.key,
          weight: entry.value['weight'],
          hrv: entry.value['hrv'],
          sleepHours: entry.value['sleep'],
        );
      }

      profile.lastHealthSync = DateTime.now();
      await _db.saveUserProfile(profile);

      // Optional: Clean up older health snapshots if they are no longer the primary source
      // For now we keep them to avoid breaking other parts of the app until fully refactored
    } catch (e) {
      debugPrint('Error syncing health data: $e');
      throw Exception('Health sync failed: $e');
    }
  }
}
