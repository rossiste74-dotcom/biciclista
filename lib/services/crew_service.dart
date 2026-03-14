import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_ride.dart';
import '../models/ai_config.dart';
// Needed if we want profile for provider
import '../services/ai_service.dart';
import '../services/prompt_service.dart';
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
            .neq(
              'creator_id',
              user.id,
            ) // Exclude rides where user is also creator
            .order('meeting_time', ascending: true);
      }

      // Fetch public rides (discovery) - Only future ones to avoid clutter
      final publicRides = await _supabase
          .from('group_rides')
          .select('*, group_ride_participants(*)')
          .eq('is_public', true)
          .neq('creator_id', user.id) // Exclude my own
          .gte('meeting_time', DateTime.now().toIso8601String()) // Future only
          .order('meeting_time', ascending: true);

      // Combine all rides
      final allRidesData = [...createdRides, ...joinedRides, ...publicRides];

      // Deduplicate by ID (Public rides might already be in joinedRides)
      final uniqueRidesMap = <String, dynamic>{};
      for (var ride in allRidesData) {
        uniqueRidesMap[ride['id']] = ride;
      }
      final uniqueRidesList = uniqueRidesMap.values.toList();

      // Re-sort by date
      uniqueRidesList.sort((a, b) {
        final dateA = DateTime.parse(a['meeting_time']);
        final dateB = DateTime.parse(b['meeting_time']);
        return dateA.compareTo(dateB);
      });

      // Collect all unique user IDs from participants (using deduplicated list)
      final Set<String> userIds = {};
      for (final rideData in uniqueRidesList) {
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
      for (final rideData in uniqueRidesList) {
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
      final allRides = uniqueRidesList
          .map((json) => GroupRide.fromJson(json))
          .toList();

      // Sort by meeting time (already sorted but safe to re-sort or rely on DB order if needed)
      // Since we merged multiple lists, explicit sort is good.
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
        .map(
          (data) => data
              .where(
                (p) =>
                    p['group_ride_id'] == rideId && p['status'] == 'confirmed',
              )
              .length,
        );
  }

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

  /// Get motivational message for the local community from AI
  Future<String> getCommunityMotivation({double radiusKm = 20.0}) async {
    try {
      // 1. Get current location (mocked for now, or use last known)
      const lat = 45.4642; // Milan
      const lon = 9.1900;

      // 2. Call DB function to get stats
      Map<String, dynamic> stats;
      try {
        stats = await _supabase.rpc(
          'get_community_stats',
          params: {'lat': lat, 'lon': lon, 'radius_km': radiusKm},
        );
      } catch (_) {
        // Fallback mock
        stats = {'avg_km': 42.0, 'active_users': 8, 'popular_type': 'Strada'};
      }

      final statsStr =
          "Media Km/Uscita: ${stats['avg_km']}km. Utenti attivi: ${stats['active_users']}. Bici prevalente: ${stats['popular_type']}. Zona: Raggio $radiusKm km.";

      // 3. Get Prompt
      final promptService = PromptService();
      final systemPrompt = await promptService.getPrompt(
        AIConfig.keyCommunityMotivation,
        {'dati_aggregati_crew': statsStr},
      );

      // 4. Call AI
      // We need a temporary/default profile or provider since this is a "system" call not necessarily tied to user profile personalization
      // But AIService needs a profile to determine provider. We can cheat and use default.
      final aiService = AIService();
      // We can use a lower-level private method if exposed, or just allow AIService to handle it.
      // Since AIService.getAdvice() requires a user question, let's use a "System" question.

      // Wait, we refactored AIService. Let's see if we can use it.
      // We can create a dedicated method in AIService or just use a tricky call.
      // Ideally, CrewService shouldn't know about AI internals.
      // BUT, for now, let's assume we can call `aiService.getAdvice` or similar.
      // Creating a temporary profile-independent call would be best.
      // Let's try `testConnection` style call or `_callAI` if it was public.

      // Let's use `getAdvice` but with health context disabled, passing the PROMPT as the question?
      // No, the system prompt IS the persona.
      // The prompt we built IS the system prompt.
      // So we need a way to pass a CUSTOM system prompt to AIService.

      // Since I cannot easily change AIService API right now without breaking things,
      // I will invoke the Edge Function directly here or add a helper to AIService.
      // Adding helper to AIService is cleaner. For now, I will invoke Edge Function directly here to avoid breaking AIService API surface in this turn.

      final response = await _supabase.functions.invoke(
        'butler-ai-openrouter',
        body: {
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'Motivaci.'},
          ],
        },
      );

      final data = response.data;
      if (data != null &&
          data['choices'] != null &&
          (data['choices'] as List).isNotEmpty) {
        return data['choices'][0]['message']['content'];
      }
      return data['content'] ?? "Forza pedalare!";
    } catch (e) {
      return "La catena è arrugginita? Uscite a pedalare!";
    }
  }
}
