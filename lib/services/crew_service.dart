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
