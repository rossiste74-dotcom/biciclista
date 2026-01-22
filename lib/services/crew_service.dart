import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_ride.dart';
import 'supabase_config.dart';

/// Service for managing group rides (uscite di gruppo)
class CrewService {
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Get all public group rides
  Future<List<GroupRide>> getPublicGroupRides({
    String? status,
    DateTime? afterDate,
  }) async {
    try {
      var query = _supabase
          .from('group_rides')
          .select('*, group_ride_participants(*)')
          .eq('is_public', true);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (afterDate != null) {
        query = query.gte('meeting_time', afterDate.toIso8601String());
      }

      final response = await query.order('meeting_time', ascending: true);
      
      return (response as List)
          .map((json) => GroupRide.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching group rides: $e');
    }
  }

  /// Get my created group rides
  Future<List<GroupRide>> getMyGroupRides() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('group_rides')
          .select('*, group_ride_participants(*)')
          .eq('creator_id', user.id)
          .order('meeting_time', ascending: false);

      return (response as List)
          .map((json) => GroupRide.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching my rides: $e');
    }
  }

  /// Get group rides I'm participating in
  Future<List<GroupRide>> getMyParticipatingRides() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get ride IDs where I'm a participant
      final participations = await _supabase
          .from('group_ride_participants')
          .select('group_ride_id')
          .eq('user_id', user.id)
          .eq('status', 'confirmed');

      final rideIds = (participations as List)
          .map((p) => p['group_ride_id'] as String)
          .toList();

      if (rideIds.isEmpty) return [];

      final response = await _supabase
          .from('group_rides')
          .select('*, group_ride_participants(*)')
          .inFilter('id', rideIds)
          .order('meeting_time', ascending: true);

      return (response as List)
          .map((json) => GroupRide.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching participating rides: $e');
    }
  }

  /// Get unified activity agenda (created + joined)
  /// Returns all activities where user is creator OR participant, sorted chronologically
  Future<List<GroupRide>> getUnifiedActivityAgenda() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Fetch rides where user is creator
      final createdRides = await _supabase
          .from('group_rides')
          .select('*, group_ride_participants(*)')
          .eq('creator_id', user.id)
          .order('meeting_time', ascending: true);

      // Fetch rides where user is participant (but not creator)
      final participations = await _supabase
          .from('group_ride_participants')
          .select('group_ride_id')
          .eq('user_id', user.id)
          .eq('status', 'confirmed');

      final participantRideIds = (participations as List)
          .map((p) => p['group_ride_id'] as String)
          .toList();

      List<dynamic> joinedRides = [];
      if (participantRideIds.isNotEmpty) {
        joinedRides = await _supabase
            .from('group_rides')
            .select('*, group_ride_participants(*)')
            .inFilter('id', participantRideIds)
            .neq('creator_id', user.id) // Exclude rides where user is also creator
            .order('meeting_time', ascending: true);
      }

      // Combine all rides
      final allRidesData = [...createdRides, ...joinedRides];
      
      // Collect all unique user IDs from participants
      final Set<String> userIds = {};
      for (final rideData in allRidesData) {
        final participants = rideData['group_ride_participants'] as List?;
        if (participants != null) {
          for (final p in participants) {
            userIds.add(p['user_id'] as String);
          }
        }
      }

      // Fetch all profiles in one query
      Map<String, Map<String, dynamic>> profilesMap = {};
      if (userIds.isNotEmpty) {
        final profiles = await _supabase
            .from('public_profiles')
            .select('user_id, display_name, profile_image_url, avatar_data')
            .inFilter('user_id', userIds.toList());
        
        for (final profile in profiles as List) {
          profilesMap[profile['user_id'] as String] = profile;
        }
      }

      // Merge profile data into participants
      for (final rideData in allRidesData) {
        final participants = rideData['group_ride_participants'] as List?;
        if (participants != null) {
          for (final p in participants) {
            final userId = p['user_id'] as String;
            final profile = profilesMap[userId];
            if (profile != null) {
              p['display_name'] = profile['display_name'];
              p['profile_image_url'] = profile['profile_image_url'];
              p['avatar_data'] = profile['avatar_data'];
            }
          }
        }
      }

      // Convert to GroupRide objects
      final allRides = allRidesData
          .map((json) => GroupRide.fromJson(json))
          .toList();

      // Sort by meeting time
      allRides.sort((a, b) => a.meetingTime.compareTo(b.meetingTime));

      return allRides;
    } catch (e) {
      throw Exception('Error fetching unified agenda: $e');
    }
  }

  /// Get all public activities for discovery (global)
  Future<List<GroupRide>> getPublicActivitiesForDiscovery({
    int limit = 50,
    DateTime? afterDate,
  }) async {
    try {
      var query = _supabase
          .from('group_rides')
          .select('*, group_ride_participants(*)')
          .eq('is_public', true)
          .eq('status', 'planned');

      if (afterDate != null) {
        query = query.gte('meeting_time', afterDate.toIso8601String());
      }

      final response = await query
          .order('meeting_time', ascending: true)
          .limit(limit);

      return (response as List)
          .map((json) => GroupRide.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching discovery activities: $e');
    }
  }

  /// Create a new group ride
  Future<GroupRide> createGroupRide({
    required String rideName,
    String? description,
    Map<String, dynamic>? gpxData,
    String? gpxFileUrl,
    double? distance,
    double? elevation,
    required String meetingPoint,
    double? meetingLatitude,
    double? meetingLongitude,
    required DateTime meetingTime,
    String difficultyLevel = 'medium',
    int maxParticipants = 10,
    bool isPublic = true,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final data = {
        'creator_id': user.id,
        'ride_name': rideName,
        'description': description,
        'gpx_data': gpxData,
        'gpx_file_url': gpxFileUrl,
        'distance': distance,
        'elevation': elevation,
        'meeting_point': meetingPoint,
        'meeting_latitude': meetingLatitude,
        'meeting_longitude': meetingLongitude,
        'meeting_time': meetingTime.toIso8601String(),
        'difficulty_level': difficultyLevel,
        'max_participants': maxParticipants,
        'is_public': isPublic,
        'status': 'planned',
      };

      final response = await _supabase
          .from('group_rides')
          .insert(data)
          .select()
          .single();

      final rideId = response['id'];
      
      // Auto-join creator
      await _supabase.from('group_ride_participants').insert({
        'group_ride_id': rideId,
        'user_id': user.id,
        'status': 'confirmed',
      });
      // Is 'is_creator' in DB schema for participants? 
      // Checking schema... Schema: id, group_ride_id, user_id, status. NO is_creator.
      // So remove is_creator.

      
      // Refetch with participants
      final fullRide = await _supabase
          .from('group_rides')
          .select('*, group_ride_participants(*)')
          .eq('id', rideId)
          .single();

      return GroupRide.fromJson(fullRide);
    } catch (e) {
      throw Exception('Error creating group ride: $e');
    }
  }

  /// Join a group ride
  Future<void> joinGroupRide(String groupRideId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase.from('group_ride_participants').insert({
        'group_ride_id': groupRideId,
        'user_id': user.id,
        'status': 'confirmed',
      });
    } catch (e) {
      throw Exception('Error joining ride: $e');
    }
  }

  /// Leave a group ride
  Future<void> leaveGroupRide(String groupRideId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('group_ride_participants')
          .delete()
          .eq('group_ride_id', groupRideId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Error leaving ride: $e');
    }
  }

  /// Get participants count for a ride
  Future<int> getParticipantsCount(String groupRideId) async {
    try {
      final response = await _supabase
          .from('group_ride_participants')
          .select()
          .eq('group_ride_id', groupRideId)
          .eq('status', 'confirmed');

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Update group ride status
  Future<void> updateRideStatus(String rideId, String status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('group_rides')
          .update({'status': status})
          .eq('id', rideId)
          .eq('creator_id', user.id);
    } catch (e) {
      throw Exception('Error updating ride status: $e');
    }
  }

  /// Stream group rides (real-time)
  Stream<List<GroupRide>> streamPublicGroupRides() {
    return _supabase
        .from('group_rides')
        .stream(primaryKey: ['id'])
        .eq('is_public', true)
        .order('meeting_time')
        .map((data) => data.map((json) => GroupRide.fromJson(json)).toList());
  }

  /// Subscribe to realtime updates for a specific activity
  /// Returns a stream that emits the updated participant count
  Stream<int> subscribeToActivityUpdates(String rideId) {
    return _supabase
        .from('group_ride_participants')
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((p) => 
                p['group_ride_id'] == rideId && 
                p['status'] == 'confirmed')
            .length);
  }

  /// Delete a group ride (only creator)
  Future<void> deleteGroupRide(String rideId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('group_rides')
          .delete()
          .eq('id', rideId)
          .eq('creator_id', user.id);
    } catch (e) {
      throw Exception('Error deleting ride: $e');
    }
  }
}
