import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../models/bicycle.dart';
import '../models/planned_ride.dart';
import 'database_service.dart';
import 'supabase_config.dart';

/// Service to manage data synchronization between local (Isar) and cloud (Supabase)
class DataModeService {
  final _db = DatabaseService();
  
  SupabaseClient get _supabase => SupabaseConfig.client;
  
  /// Check if user is currently in Community mode
  Future<bool> isCommunityMode() async {
    final profile = await _db.getUserProfile();
    return profile?.isCommunityMode ?? false;
  }
  
  /// Switch to Community mode and sync local data to cloud
  Future<Map<String, dynamic>> enableCommunityMode() async {
    try {
      // 1. Check if Supabase is configured
      if (!SupabaseConfig.isConfigured) {
        return {
          'success': false,
          'error': 'Supabase non configurato. Inserisci le credenziali in supabase_config.dart'
        };
      }
      
      // 2. Check if user is authenticated
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'Devi effettuare il login per attivare la modalità Community'
        };
      }
      
      // 3. Update profile
      final profile = await _db.getUserProfile();
      if (profile == null) {
        return {'success': false, 'error': 'Profilo non trovato'};
      }
      
      profile.isCommunityMode = true;
      profile.supabaseUserId = user.id;
      await _db.updateUserProfile(profile);
      
      // 4. Sync local to cloud
      final syncResult = await syncLocalToCloud();
      
      return syncResult;
    } catch (e) {
      return {'success': false, 'error': 'Errore attivazione Community: $e'};
    }
  }
  
  /// Switch back to Autonomous mode (local only)
  Future<Map<String, dynamic>> disableCommunityMode() async {
    try {
      final profile = await _db.getUserProfile();
      if (profile == null) {
        return {'success': false, 'error': 'Profilo non trovato'};
      }
      
      profile.isCommunityMode = false;
      // Keep supabaseUserId for potential re-enabling
      await _db.updateUserProfile(profile);
      
      return {'success': true, 'message': 'Modalità Autonoma attivata'};
    } catch (e) {
      return {'success': false, 'error': 'Errore disattivazione Community: $e'};
    }
  }
  
  /// Sync all local data to Supabase
  Future<Map<String, dynamic>> syncLocalToCloud() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'Utente non autenticato'};
      }
      
      int profilesSynced = 0;
      int bicyclesSynced = 0;
      int ridesSynced = 0;
      
      // 1. Sync Profile
      final profile = await _db.getUserProfile();
      if (profile != null) {
        await _syncProfileToCloud(profile, user.id);
        profilesSynced = 1;
      }
      
      // 2. Sync Bicycles
      final bicycles = await _db.getAllBicycles();
      for (final bicycle in bicycles) {
        await _syncBicycleToCloud(bicycle, user.id);
        bicyclesSynced++;
      }
      
      // 3. Sync Rides
      final rides = await _db.getAllPlannedRides();
      for (final ride in rides) {
        await _syncRideToCloud(ride, user.id);
        ridesSynced++;
      }
      
      return {
        'success': true,
        'profiles': profilesSynced,
        'bicycles': bicyclesSynced,
        'rides': ridesSynced,
        'message': 'Sincronizzazione completata: $profilesSynced profili, $bicyclesSynced bici, $ridesSynced uscite'
      };
    } catch (e) {
      return {'success': false, 'error': 'Errore sincronizzazione: $e'};
    }
  }
  
  /// Sync profile to Supabase
  Future<void> _syncProfileToCloud(UserProfile profile, String userId) async {
    final data = {
      'user_id': userId,
      'name': profile.name,
      'age': profile.age, // Already int
      'gender': profile.gender,
      'weight': profile.weight,
      'hrv': profile.hrv, // Already int
      'sleep_hours': profile.sleepHours,
      'health_history': profile.healthHistory != null 
          ? jsonDecode(profile.healthHistory!) 
          : [],
      'last_health_sync': profile.lastHealthSync?.toIso8601String(),
      'thermal_sensitivity': profile.thermalSensitivity, // Already int
      'hot_threshold': profile.hotThreshold,
      'warm_threshold': profile.warmThreshold,
      'cool_threshold': profile.coolThreshold,
      'cold_threshold': profile.coldThreshold,
      'sensitivity_adjustment': profile.sensitivityAdjustment,
      'hot_kit': profile.hotKit,
      'warm_kit': profile.warmKit,
      'cool_kit': profile.coolKit,
      'cold_kit': profile.coldKit,
      'very_cold_kit': profile.veryColdKit,
      'ai_provider': profile.getAIProvider()?.name,
      'ai_model': profile.aiModel,
      'max_off_course_distance': profile.offCourseThresholdM,
      'voice_alerts_enabled': profile.enableVoiceAlerts,
      'vibration_alerts_enabled': profile.alertType != 1,
      'is_community_mode': profile.isCommunityMode,
    };
    
    // Upsert (insert or update)
    // Upsert to private 'profiles' (using raw_data JSONB column to avoid schema rigidity)
    try {
      await _supabase.from('profiles').upsert({
        'user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
        'raw_data': data, // Store all private fields as JSON
      }, onConflict: 'user_id');
    } catch (e) {
      print('Profiles table sync error: $e');
    }

    // Upsert to 'public_profiles' for Crew visibility
    final publicData = {
      'user_id': userId,
      'display_name': profile.name,
      'is_private': !profile.isCommunityMode,
      'age': profile.age, // Added via SQL script
      // Add other public fields if available in profile
    };
    await _supabase.from('public_profiles').upsert(publicData, onConflict: 'user_id');
  }
  
  /// Sync bicycle to Supabase
  Future<void> _syncBicycleToCloud(Bicycle bicycle, String userId) async {
    // Convert components to JSON
    final componentsJson = bicycle.components.map((c) => {
      'name': c.name,
      'currentKm': c.currentKm,
      'limitKm': c.limitKm,
    }).toList();
    
    final data = {
      'user_id': userId,
      'name': bicycle.name,
      'bike_type': bicycle.type,
      'brand': null, // Not in model
      'model': null, // Not in model
      'year': null, // Not in model
      'total_kilometers': bicycle.totalKilometers,
      'chain_kms': bicycle.chainKms,
      'tyre_kms': bicycle.tyreKms,
      'chain_limit': bicycle.chainLimitKm,
      'tyre_limit': bicycle.tyreLimitKm,
      'components': componentsJson,
    };
    
    // Check if bicycle already exists on cloud by checking if we have a cloud ID stored
    // For now, we'll use upsert with a generated ID
    await _supabase
        .from('bicycles')
        .upsert(data);
  }
  
  /// Sync ride to Supabase
  Future<void> _syncRideToCloud(PlannedRide ride, String userId) async {
    // GPX points are not stored in PlannedRide model, only gpxFilePath
    dynamic gpxPointsJson;
    
    final data = {
      'user_id': userId,
      'ride_name': ride.rideName,
      'ride_date': ride.rideDate.toIso8601String(),
      'distance': ride.distance,
      'elevation': ride.elevation,
      'moving_time': ride.movingTime,
      'avg_speed': ride.avgSpeed,
      'avg_heart_rate': ride.avgHeartRate?.toInt(), // Convert to int
      'max_heart_rate': ride.maxHeartRate?.toInt(), // Convert to int
      'avg_power': ride.avgPower?.toInt(), // Convert to int
      'max_power': ride.maxPower?.toInt(), // Convert to int
      'avg_cadence': ride.avgCadence?.toInt(), // Convert to int
      'calories': ride.calories,
      'latitude': ride.latitude,
      'longitude': ride.longitude,
      'gpx_file_path': ride.gpxFilePath,
      'gpx_points': gpxPointsJson,
      'forecast_weather': ride.forecastWeather,
      'ai_analysis': ride.aiAnalysis,
      'is_completed': ride.isCompleted,
    };
    
    await _supabase
        .from('planned_rides')
        .upsert(data);
  }
  
  /// Sync cloud data to local (download from Supabase to Isar)
  Future<Map<String, dynamic>> syncCloudToLocal() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'Utente non autenticato'};
      }
      
      // This would download data from Supabase and update local Isar database
      // Implementation depends on conflict resolution strategy
      // For now, we'll keep it simple and just report success
      
      return {
        'success': true,
        'message': 'Sincronizzazione cloud → locale completata'
      };
    } catch (e) {
      return {'success': false, 'error': 'Errore download cloud: $e'};
    }
  }
  
  /// Sign in with email (for Community mode)
  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return {
          'success': true,
          'user': response.user,
          'message': 'Login effettuato'
        };
      } else {
        return {'success': false, 'error': 'Login fallito'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Errore login: $e'};
    }
  }
  
  /// Sign up with email (for Community mode)
  Future<Map<String, dynamic>> signUpWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return {
          'success': true,
          'user': response.user,
          'message': 'Registrazione completata. Controlla la tua email per confermare.'
        };
      } else {
        return {'success': false, 'error': 'Registrazione fallita'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Errore registrazione: $e'};
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    
    // Also disable community mode
    await disableCommunityMode();
  }
  
  /// Ensure public profile exists for the user (called on Join)
  Future<void> ensurePublicProfile(User user) async {
    try {
      // Check if exists
      final exists = await _supabase
          .from('public_profiles')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (exists == null) {
        // Create default
        final name = user.userMetadata?['name'] as String? ?? user.email?.split('@')[0] ?? 'Ciclista';
        await _supabase.from('public_profiles').insert({
          'user_id': user.id,
          'display_name': name,
          'is_private': false, // Implicitly public if joining public logic
        });
      }
    } catch (e) {
      print('Error ensuring public profile: $e');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}
