import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/user_profile.dart';
import '../models/bicycle.dart';
import '../models/planned_ride.dart';
import '../models/track.dart';
import '../models/health_snapshot.dart';
import '../models/alert_rule.dart';
import '../models/biomechanics_analysis.dart';
import '../models/comic_character.dart';

/// Singleton service for Cloud-Only database operations via Supabase
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  // Get Supabase client
  SupabaseClient get _supabase => Supabase.instance.client;

  // No auth? 
  String? get _userId => _supabase.auth.currentUser?.id;

  /// No-op for now, or ensure auth check
  Future<void> init() async {
     // Isar init removed.
  }

  /// Close connection (no-op for Supabase REST)
  Future<void> close() async {}

  // ==================== UserProfile CRUD ====================

  /// Get the user profile (cloud)
  Future<UserProfile?> getUserProfile() async {
    final uid = _userId;
    if (uid == null) return null;

    try {
      final data = await _supabase.from('profiles').select().eq('user_id', uid).maybeSingle();
      if (data == null) return null;
      
      final p = UserProfile();
      p.id = uid; 
      p.name = data['name'];
      p.gender = data['gender'];
      p.age = data['age'] ?? 30;
      p.weight = (data['weight'] ?? 70.0).toDouble();
      p.height = (data['height'] ?? 175.0).toDouble();
      p.restingHeartRate = data['resting_heart_rate'] ?? 60;
      p.functionalThresholdPower = data['ftp'] ?? 200;
      p.hrv = data['hrv'] ?? 0;
      p.sleepHours = (data['sleep_hours'] ?? 0.0).toDouble();
      p.thermalSensitivity = data['thermal_sensitivity'] ?? 3;
      p.role = UserRoleExtension.fromString(data['role'] ?? 'Gregario');
      
      // Handle JSON fields (Supabase returns Map/List, Model expects String)
      final avatarJson = data['avatar_data'];
      if (avatarJson != null) {
        p.avatarData = avatarJson is String ? avatarJson : json.encode(avatarJson);
      }
      
      final historyJson = data['health_history'];
      if (historyJson != null) {
        p.healthHistory = historyJson is String ? historyJson : json.encode(historyJson);
      } 
      
      // Load last sync date if available
      if (data['last_health_sync'] != null) {
        p.lastHealthSync = DateTime.tryParse(data['last_health_sync']);
      }
      
      return p;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  /// Save or update user profile (Cloud)
  Future<void> saveUserProfile(UserProfile profile, {bool syncToCloud = true}) async {
    final uid = _userId;
    if (uid == null) return;
    
    try {
      await _supabase.from('profiles').upsert({
        'user_id': uid,
        'name': profile.name,
        'gender': profile.gender,
        'age': profile.age,
        'weight': profile.weight.toDouble(),
        'height': profile.height != null ? profile.height!.toDouble() : null,
        'resting_heart_rate': profile.restingHeartRate.toInt(),
        'ftp': profile.functionalThresholdPower.toInt(),
        'hrv': profile.hrv.toInt(),
        'sleep_hours': profile.sleepHours.toDouble(),
        'thermal_sensitivity': profile.thermalSensitivity.toInt(),
        'role': profile.role.name,
        'avatar_data': profile.avatarData != null ? json.decode(profile.avatarData!) : null,
        'health_history': profile.healthHistory != null ? json.decode(profile.healthHistory!) : null,
        'last_health_sync': profile.lastHealthSync?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (e) {
      print('Error saving profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async => saveUserProfile(profile);

  /// Get all user profiles for the Crew tab (with stats from planned_rides)
  Future<List<UserProfile>> getAllProfiles() async {
    try {
      final res = await _supabase.from('profiles').select().order('name', ascending: true);
      
      return (res as List).map((data) {
        final p = UserProfile();
        p.id = data['user_id'] ?? '';
        p.name = data['name'];
        p.gender = data['gender'];
        p.age = data['age'] ?? 30;
        p.weight = (data['weight'] ?? 70.0).toDouble();
        p.role = UserRoleExtension.fromString(data['role'] ?? 'Gregario');
        
        final avatarJson = data['avatar_data'];
        if (avatarJson != null) {
          p.avatarData = avatarJson is String ? avatarJson : json.encode(avatarJson);
        }
        
        return p;
      }).toList();
    } catch (e) {
      print('Error fetching all profiles: $e');
      return [];
    }
  }

  /// Crew with aggregated ride statistics (calls get_crew_with_stats RPC)
  Future<List<Map<String, dynamic>>> getCrewWithStats() async {
    try {
      final res = await _supabase.rpc('get_crew_with_stats');
      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      print('Error fetching crew with stats: $e');
      return [];
    }
  }

  /// Update role of any user (only allowed for Capitano/Presidente via RLS)
  Future<bool> updateUserRole(String targetUserId, UserRole newRole) async {
    try {
      await _supabase
          .from('profiles')
          .update({'role': newRole.name})
          .eq('user_id', targetUserId);
      return true;
    } catch (e) {
      print('Error updating user role: $e');
      return false;
    }
  }

  // ==================== Bicycle CRUD ====================

  Future<String> createBicycle(Bicycle bicycle) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not authenticated');

    final data = {
      'user_id': uid,
      'name': bicycle.name,
      'bike_type': bicycle.type, 
      'total_kilometers': bicycle.totalKilometers,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final res = await _supabase.from('bicycles').insert(data).select('id').single();
    return res['id'] as String;
  }

  Future<List<Bicycle>> getAllBicycles() async {
    final uid = _userId;
    if (uid == null) return [];

    try {
      final list = await _supabase.from('bicycles').select().eq('user_id', uid);
      return (list as List).map((map) {
        final b = Bicycle();
        b.id = map['id']?.toString();
        b.name = map['name'] ?? 'Bici';
        b.type = map['bike_type'] ?? 'Road';
        b.totalKilometers = (map['total_kilometers'] ?? 0).toDouble();
        return b;
      }).toList();
    } catch (e) {
      print('Error fetching bicycles: $e');
      return [];
    }
  }

  Future<Bicycle?> getBicycleById(String id) async {
     final data = await _supabase.from('bicycles').select().eq('id', id).maybeSingle();
     if (data == null) return null;
     
     final b = Bicycle();
     b.id = data['id']?.toString();
     b.name = data['name'];
     b.type = data['bike_type'] ?? 'Road';
     b.totalKilometers = (data['total_kilometers'] ?? 0).toDouble();
     return b;
  }

  Future<void> updateBicycle(Bicycle bicycle) async {
    if (bicycle.id == null) return;
    
    await _supabase.from('bicycles').update({
      'name': bicycle.name,
      'bike_type': bicycle.type,
      'total_kilometers': bicycle.totalKilometers,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bicycle.id!);
  }

  Future<bool> deleteBicycle(String id) async {
    await _supabase.from('bicycles').delete().eq('id', id);
    return true;
  }

  // ==================== PlannedRide CRUD ====================

  Future<bool> doesRideExist(DateTime date) async {
    final uid = _userId;
    if (uid == null) return false;
    
    final start = date.subtract(const Duration(minutes: 1));
    final end = date.add(const Duration(minutes: 1));
    
    final count = await _supabase
        .from('planned_rides')
        .count()
        .eq('user_id', uid)
        .gte('ride_date', start.toIso8601String())
        .lte('ride_date', end.toIso8601String());
        
    return count > 0;
  }

  Future<String> createPlannedRide(PlannedRide ride) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not Auth');

    final data = {
      'user_id': uid,
      'ride_name': ride.rideName,
      'ride_date': ride.rideDate.toIso8601String(),
      'distance': ride.distance,
      'elevation': ride.elevation,
      'track_id': ride.trackId, 
      'bicycle_id': ride.bicycleId, 
      'supabase_event_id': ride.supabaseEventId,
      'is_completed': ride.isCompleted,
      'latitude': ride.latitude,
      'longitude': ride.longitude,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    final res = await _supabase.from('planned_rides').insert(data).select('id').single();
    return res['id'] as String;
  }

  Future<List<PlannedRide>> getAllPlannedRides() async {
    final uid = _userId;
    if (uid == null) return [];
    
    try {
      final res = await _supabase.from('planned_rides')
          .select('*, personal_tracks(*)') 
          .eq('user_id', uid)
          .order('ride_date', ascending: true);
          
      return (res as List).map((map) => _mapPlannedRide(map)).toList();
    } catch (e) {
      print('Error fetching rides: $e');
      return [];
    }
  }

  Future<List<PlannedRide>> getUpcomingRides() async {
    final uid = _userId;
    if (uid == null) return [];
    final now = DateTime.now().toIso8601String();
    
    final res = await _supabase.from('planned_rides')
        .select()
        .eq('user_id', uid)
        .gt('ride_date', now)
        .order('ride_date', ascending: true);
        
    return (res as List).map((map) => _mapPlannedRide(map)).toList();
  }

  /// Get upcoming rides created by OTHER community users (for the dashboard community slider)
  Future<List<PlannedRide>> getCommunityUpcomingRides() async {
    try {
      final res = await _supabase.rpc('get_community_upcoming_rides');
      return (res as List).map((map) {
        final r = PlannedRide();
        r.id = map['id'] as String?;
        r.rideName = map['ride_name'] as String? ?? 'Uscita Community';
        r.rideDate = DateTime.tryParse(map['ride_date'] as String? ?? '') ?? DateTime.now();
        r.distance = (map['distance'] as num?)?.toDouble() ?? 0.0;
        r.elevation = (map['elevation'] as num?)?.toDouble() ?? 0.0;
        r.latitude = (map['start_latitude'] as num?)?.toDouble();
        r.longitude = (map['start_longitude'] as num?)?.toDouble();
        return r;
      }).toList();
    } catch (e) {
      print('Error fetching community upcoming rides: $e');
      return [];
    }
  }

  Future<List<PlannedRide>> getIncompleteRides() async {
    final uid = _userId;
    if (uid == null) return [];

    // Fetch all incomplete rides, past and future
    final res = await _supabase.from('planned_rides')
        .select()
        .eq('user_id', uid)
        .eq('is_completed', false)
        .order('ride_date', ascending: true);

    return (res as List).map((map) => _mapPlannedRide(map)).toList();
  }
  
  Future<List<PlannedRide>> getImportedRides() async {
    final uid = _userId;
    if (uid == null) return [];

    // Fetch rides with "Health" marker in NAME (since notes column is missing)
    final res = await _supabase.from('planned_rides')
        .select()
        .eq('user_id', uid)
        .ilike('ride_name', '%(Health)%')
        .order('ride_date', ascending: false);

    return (res as List).map((map) => _mapPlannedRide(map)).toList();
  }

  /// Get total kilometers from imported "Other" activities (non-cycling)
  Future<double> getOtherActivitiesKm() async {
    final uid = _userId;
    if (uid == null) return 0.0;

    final res = await _supabase.from('planned_rides')
        .select()
        .eq('user_id', uid)
        .eq('is_completed', true)
        .ilike('ride_name', '%(Health)%')
        .order('ride_date', ascending: false);

    final rides = (res as List).map((map) => _mapPlannedRide(map)).toList();
    
    // Filter out cycling activities
    final otherActivities = rides.where((r) {
      final name = (r.rideName ?? '').toUpperCase();
      return !name.contains('CYCLING') && !name.contains('BIKING');
    });
    
    double total = 0;
    for (var r in otherActivities) {
      total += r.distance;
    }
    return total;
  }

  PlannedRide _mapPlannedRide(Map<String, dynamic> map) {
    final r = PlannedRide();
    r.id = map['id']?.toString();
    r.rideName = map['ride_name'];
    r.rideDate = DateTime.parse(map['ride_date']);
    r.distance = (map['distance'] ?? 0).toDouble();
    r.elevation = (map['elevation'] ?? 0).toDouble();
    r.isCompleted = map['is_completed'] ?? false;
    r.trackId = map['track_id']?.toString();
    r.bicycleId = map['bicycle_id']?.toString();
    r.supabaseEventId = map['supabase_event_id']?.toString();
    
    if (map['personal_tracks'] != null) {
       // Ideally manually map track if needed, but simplistic for now
    }
    return r;
  }

  Future<PlannedRide?> getPlannedRideById(String id) async {
    final data = await _supabase.from('planned_rides').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return _mapPlannedRide(data);
  }

  Future<void> updatePlannedRide(PlannedRide ride) async {
    if (ride.id == null) return;
    await _supabase.from('planned_rides').update({
       'ride_name': ride.rideName,
       'ride_date': ride.rideDate.toIso8601String(),
       'distance': ride.distance,
       'is_completed': ride.isCompleted,
       'track_id': ride.trackId,
       'bicycle_id': ride.bicycleId,
       'supabase_event_id': ride.supabaseEventId,
       'latitude': ride.latitude,
       'longitude': ride.longitude,
       'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', ride.id!);
  }

  Future<bool> deletePlannedRide(String id) async {
    await _supabase.from('planned_rides').delete().eq('id', id);
    return true;
  }
  
  // ==================== Health / Stats ====================
  
  Future<List<PlannedRide>> getCompletedRides() async {
    final uid = _userId;
    if (uid == null) return [];
    
    final res = await _supabase.from('planned_rides')
       .select()
       .eq('user_id', uid)
       .eq('is_completed', true)
       .order('ride_date', ascending: false);
    return (res as List).map((m) => _mapPlannedRide(m)).toList();
  }

  Future<Set<String>> getCompletedGroupRideIds() async {
    final uid = _userId;
    if (uid == null) return {};

    try {
      final res = await _supabase.from('planned_rides')
          .select('supabase_event_id')
          .eq('user_id', uid)
          .eq('is_completed', true)
          .not('supabase_event_id', 'is', null);
      
      return (res as List).map((m) => m['supabase_event_id'] as String).toSet();
    } catch (e) {
      print('Error fetching completed group ride IDs: $e');
      return {};
    }
  }

  Future<double> getWeeklyCompletedKm() async {
    final rides = await getCompletedRides();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    double total = 0;
    for (var r in rides) {
       if (r.rideDate.isAfter(startOfWeek)) {
         total += r.distance;
       }
    }
    return total;
  }
  
  /// Monthly km + elevation from the last 12 months (calls get_my_monthly_stats RPC)
  Future<List<Map<String, dynamic>>> getMonthlyStats() async {
    try {
      final res = await _supabase.rpc('get_my_monthly_stats');
      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      print('Error fetching monthly stats: $e');
      return [];
    }
  }

  Future<double> getTotalCompletedKm() async {
     final rides = await getCompletedRides();
     double total = 0;
     for (var r in rides) {
       total += r.distance;
     }
     return total;
  }

  Future<int> getTotalCompletedRidesCount() async {
     final uid = _userId;
     if (uid == null) return 0;
     final count = await _supabase.from('planned_rides').count().eq('user_id', uid).eq('is_completed', true);
     return count;
  }
  
  /// Ottieni tutte le attività concluse pubbliche della community, con le coordinate della traccia associata.
  Future<List<PlannedRide>> getCommunityCompletedRides() async {
    try {
      // Usiamo una RPC (Remote Procedure Call) Postgres per bypassare in modo sicuro
      // le policy RLS su personal_tracks e profiles.
      final res = await _supabase.rpc('get_community_completed_activities');

      final List<PlannedRide> rides = [];
      for (var map in (res as List)) {
         final ride = PlannedRide();
         ride.id = map['ride_id']?.toString();
         ride.rideName = map['ride_name'];
         
         if (map['ride_date'] != null) {
            ride.rideDate = DateTime.parse(map['ride_date']);
         } else {
            ride.rideDate = DateTime.now();
         }
         
         ride.distance = (map['distance'] ?? 0).toDouble();
         ride.elevation = (map['elevation'] ?? 0).toDouble();
         ride.isCompleted = true; // by definition of the query
         
         // Dati uniti (Join)
         ride.notes = map['author_name']; // Usiamo questo campo temporaneamente per l'UI
         
         if (map['start_latitude'] != null && map['start_longitude'] != null) {
            ride.latitude = (map['start_latitude'] as num).toDouble();
            ride.longitude = (map['start_longitude'] as num).toDouble();
            rides.add(ride);
         }
      }
      return rides;
    } catch (e) {
      print('Error fetching community completed rides: $e');
      return [];
    }
  }
  
  // ==================== HealthSnapshot CRUD ====================

  Future<int> createHealthSnapshot(HealthSnapshot snapshot) async {
    // Assuming 'health_snapshots' table exists in Supabase
    final uid = _userId;
    if (uid == null) return 0;

    final data = {
      'user_id': uid,
      'date': snapshot.date.toIso8601String(),
      'hrv': snapshot.hrv,
      'sleep_hours': snapshot.sleepHours,
      'daily_weight': snapshot.dailyWeight,
      'created_at': snapshot.createdAt.toIso8601String(),
    };

    try {
      final res = await _supabase.from('health_snapshots').insert(data).select('id').single();
      return res['id'] as int;
    } catch (e) {
      print('Error saving health snapshot: $e');
      // Return 0 or rethrow? 0 usually means nothing happened in this app context
      return 0;
    }
  }
  
  // ==================== AlertRule CRUD ====================
  
  Future<List<AlertRule>> getAlertRules() async {
     // Assuming 'alert_rules' table
     final uid = _userId;
     if (uid == null) return AlertRule.createDefaultRules(); // Return defaults if offline/logged out?

     try {
       final res = await _supabase.from('alert_rules').select().eq('user_id', uid).order('display_order');
       final remoteRules = (res as List).map((m) {
          final r = AlertRule();
          r.id = m['id'];
          r.eventTypeIndex = m['event_type_index'];
          r.actionIndex = m['action_index'];
          r.triggerValue = (m['trigger_value'] as num?)?.toDouble();
          r.voiceMessage = m['voice_message'];
          r.isEnabled = m['is_enabled'] ?? true;
          r.displayOrder = m['display_order'] ?? 0;
          return r;
       }).toList();
       
       if (remoteRules.isEmpty) {
         return await initDefaultAlertRulesIfNeeded();
       }
       return remoteRules;
     } catch (e) {
       print('Error getting alert rules: $e');
       return AlertRule.createDefaultRules();
     }
  }
  
  Future<List<AlertRule>> getEnabledAlertRules() async {
     final rules = await getAlertRules();
     return rules.where((r) => r.isEnabled).toList();
  }
  
  Future<int> saveAlertRule(AlertRule rule) async {
    final uid = _userId;
    if (uid == null) return 0;
    
    final data = {
      'user_id': uid,
      'event_type_index': rule.eventTypeIndex,
      'action_index': rule.actionIndex,
      'trigger_value': rule.triggerValue,
      'voice_message': rule.voiceMessage,
      'is_enabled': rule.isEnabled,
      'display_order': rule.displayOrder,
    };
    
    if (rule.id != null) {
      // Update
      await _supabase.from('alert_rules').update(data).eq('id', rule.id!);
      return rule.id!;
    } else {
      // Create
      final res = await _supabase.from('alert_rules').insert(data).select('id').single();
      return res['id'] as int;
    }
  }

  Future<void> saveAlertRules(List<AlertRule> rules) async {
    for (var r in rules) {
      await saveAlertRule(r);
    }
  }

  Future<bool> deleteAlertRule(int id) async {
    await _supabase.from('alert_rules').delete().eq('id', id);
    return true;
  }
  
  Future<List<AlertRule>> initDefaultAlertRulesIfNeeded() async {
     // If we are here, we probably found no rules.
     // Create defaults in DB
     final defaults = AlertRule.createDefaultRules();
     await saveAlertRules(defaults);
     return defaults;
  }

  // ==================== Streams ====================
  Stream<void> watchPlannedRides() => const Stream.empty();
  Stream<void> watchBicycles() => const Stream.empty();
  Stream<void> watchUserProfile() => const Stream.empty();
  // ==================== Daily Wisdom CRUD ====================

  Future<String?> getDailyWisdom(DateTime date) async {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    try {
      final data = await _supabase.from('daily_wisdom').select('content').eq('date', dateStr).maybeSingle();
      if (data != null) {
        return data['content'] as String;
      }
      return null;
    } catch (e) {
      print('Error fetching daily wisdom: $e');
      return null;
    }
  }

  Future<void> saveDailyWisdom(DateTime date, String content) async {
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      try {
        await _supabase.from('daily_wisdom').insert({
          'date': dateStr,
          'content': content,
        });
      } catch (e) {
        // Ignore duplicate key errors (race condition if two users gen at same time)
        print('Error saving daily wisdom (might exist): $e');
      }
  }
  // ==================== Dashboard Messages ====================

  // Cache for messages
  Map<String, String>? _weatherMessages;
  Map<String, String>? _statsMessages;
  Map<String, String>? _maintenanceMessages;
  Map<String, String>? _challengeMessages;

  Future<Map<String, String>> getWeatherMessages() async {
    if (_weatherMessages != null) return _weatherMessages!;
    
    try {
      final response = await _supabase.from('weather_messages').select('condition_key, message_text');
      final Map<String, String> messages = {};
      for (var row in response) {
        messages[row['condition_key'] as String] = row['message_text'] as String;
      }
      _weatherMessages = messages;
      return messages;
    } catch (e) {
      print('Error fetching weather messages: $e');
      return {};
    }
  }

  Future<Map<String, String>> getStatsMessages() async {
    if (_statsMessages != null) return _statsMessages!;
    
    try {
      final response = await _supabase.from('stats_messages').select('condition_key, message_text');
      final Map<String, String> messages = {};
      for (var row in response) {
        messages[row['condition_key'] as String] = row['message_text'] as String;
      }
      _statsMessages = messages;
      return messages;
    } catch (e) {
      print('Error fetching stats messages: $e');
      return {};
    }
  }

  Future<Map<String, String>> getMaintenanceMessages() async {
    if (_maintenanceMessages != null) return _maintenanceMessages!;
    
    try {
      final response = await _supabase.from('maintenance_messages').select('condition_key, message_text');
      final Map<String, String> messages = {};
      for (var row in response) {
        messages[row['condition_key'] as String] = row['message_text'] as String;
      }
      _maintenanceMessages = messages;
      return messages;
    } catch (e) {
      print('Error fetching maintenance messages: $e');
      return {};
    }
  }

  Future<Map<String, String>> getChallengeMessages() async {
    if (_challengeMessages != null) return _challengeMessages!;
    
    try {
      final response = await _supabase.from('challenge_messages').select('condition_key, message_text');
      final Map<String, String> messages = {};
      for (var row in response) {
        messages[row['condition_key'] as String] = row['message_text'] as String;
      }
      _challengeMessages = messages;
      return messages;
    } catch (e) {
      print('Error fetching challenge messages: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getLeaderboard() async {
    try {
      final res = await _supabase.rpc('get_sarcastic_leaderboard');
      return res as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching leaderboard: $e');
      // Fallback/Mock for empty states or errors
      return {
        'most_active': {'name': 'Nessuno', 'value': 0, 'title': 'Il Fuggitivo'},
        'organizer': {'name': 'Nessuno', 'value': 0, 'title': 'Il Generale'},
        'laziest': {'name': 'Tutti voi', 'value': 0, 'title': 'Il Turista'},
      };
    }
  }

  Future<Map<String, dynamic>> getFullLeaderboard() async {
    try {
      final res = await _supabase.rpc('get_full_leaderboard');
      return res as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching full leaderboard: $e');
      return {
        'most_active': [],
        'organizers': [],
        'laziest': [],
      };
    }
  }

  // ==================== Biomechanics CRUD ====================

  Future<void> saveBiomechanicsAnalysis(BiomechanicsAnalysis analysis) async {
    final uid = _userId;
    if (uid == null) return;

    try {
      await _supabase.from('biomechanics_analyses').insert({
        'user_id': uid,
        'analysis_data': analysis.toJson(),
        'verdict': analysis.verdict ?? '',
        'bike_type': analysis.metadata.bikeTypeDetected.name.toUpperCase(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving biomechanics analysis: $e');
    }
  }

  Future<BiomechanicsAnalysis?> getLatestBiomechanicsAnalysis() async {
    final uid = _userId;
    if (uid == null) return null;

    try {
      final data = await _supabase
          .from('biomechanics_analyses')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;

      // Extract model from JSON
      final analysisData = data['analysis_data'] as Map<String, dynamic>;
      
      return BiomechanicsAnalysis.fromJson({
        ...analysisData,
        'verdict': data['verdict'],
        'created_at': data['created_at'],
        'id': data['id'],
      });
    } catch (e) {
      print('Error fetching latest biomechanics analysis: $e');
      return null;
    }
  }

  /// Clear message cache (e.g., on pull-to-refresh)
  void clearMessageCache() {
    _weatherMessages = null;
    _statsMessages = null;
    _maintenanceMessages = null;
    _challengeMessages = null;
  }

  // ==================== Daily Comic Prompts ====================

  Future<String?> getDailyComicImage(DateTime date) async {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    try {
      final data = await _supabase
          .from('daily_comic_prompts')
          .select('generated_image_url')
          .eq('date', dateStr)
          .maybeSingle();
      
      return data?['generated_image_url'] as String?;
    } catch (e) {
      print('Error fetching daily comic image: $e');
      return null;
    }
  }

  Future<void> saveDailyComicImage(DateTime date, String imageUrl, String scenario) async {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    try {
      await _supabase.from('daily_comic_prompts').upsert({
        'date': dateStr,
        'generated_image_url': imageUrl,
        'scenario': scenario,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving daily comic image: $e');
    }
  }

  Future<void> saveDailyComicPrompt(DateTime date, String prompt) async {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final uid = _userId;
    if (uid == null) return;

    try {
      await _supabase.from('daily_comic_prompts').upsert({
        'date': dateStr,
        'prompt': prompt,
        'author_id': uid,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving daily comic prompt: $e');
      rethrow;
    }
  }

  Future<String?> getDailyComicPrompt(DateTime date) async {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    try {
      final data = await _supabase
          .from('daily_comic_prompts')
          .select('prompt')
          .eq('date', dateStr)
          .maybeSingle();
      
      return data?['prompt'] as String?;
    } catch (e) {
      print('Error fetching daily comic prompt: $e');
      return null;
    }
  }

  // --- COMIC CHARACTERS ---

  Future<List<ComicCharacter>> getComicCharacters() async {
    try {
      final response = await _supabase
          .from('comic_characters')
          .select()
          .order('name', ascending: true);
      
      return (response as List)
          .map((json) => ComicCharacter.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching comic characters: $e');
      return [];
    }
  }

  Future<void> saveComicCharacter(ComicCharacter character) async {
    try {
      final json = character.toJson();
      if (character.id.isEmpty) {
        json.remove('id');
      }
      json['updated_at'] = DateTime.now().toIso8601String();
      
      await _supabase.from('comic_characters').upsert(json);
    } catch (e) {
      print('Error saving comic character: $e');
      rethrow;
    }
  }

  Future<void> deleteComicCharacter(String id) async {
    try {
      await _supabase.from('comic_characters').delete().eq('id', id);
    } catch (e) {
      print('Error deleting comic character: $e');
      rethrow;
    }
  }

  Future<String?> uploadCharacterAvatar(String charId, Uint8List bytes, String fileName) async {
    try {
      final path = 'avatars/$charId/$fileName';
      await _supabase.storage.from('comic_avatars').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
      
      final url = _supabase.storage.from('comic_avatars').getPublicUrl(path);
      return url;
    } catch (e) {
      print('Error uploading character avatar: $e');
      return null;
    }
  }
}
