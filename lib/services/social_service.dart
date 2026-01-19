import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/public_profile.dart';
import '../models/friendship.dart';
import 'supabase_config.dart';

/// Service for managing public profiles and friendships
class SocialService {
  SupabaseClient get _supabase => SupabaseConfig.client;

  // ==================== PUBLIC PROFILES ====================

  /// Get public profile for a user
  Future<PublicProfile?> getPublicProfile(String userId) async {
    try {
      final response = await _supabase
          .from('public_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return PublicProfile.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching public profile: $e');
    }
  }

  /// Get my public profile
  Future<PublicProfile?> getMyPublicProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      return await getPublicProfile(user.id);
    } catch (e) {
      return null;
    }
  }

  /// Create or update public profile
  Future<PublicProfile> upsertPublicProfile({
    required String displayName,
    String? bio,
    String? profileImageUrl,
    bool? isPrivate,
    bool? showGarage,
    bool? showStats,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final data = {
        'user_id': user.id,
        'display_name': displayName,
        if (bio != null) 'bio': bio,
        if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
        if (isPrivate != null) 'is_private': isPrivate,
        if (showGarage != null) 'show_garage': showGarage,
        if (showStats != null) 'show_stats': showStats,
      };

      final response = await _supabase
          .from('public_profiles')
          .upsert(data, onConflict: 'user_id')
          .select()
          .single();

      return PublicProfile.fromJson(response);
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  /// Toggle profile privacy
  Future<void> togglePrivacy(bool isPrivate) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('public_profiles')
          .update({'is_private': isPrivate})
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Error toggling privacy: $e');
    }
  }

  /// Update statistics from local data
  Future<void> updateStats({
    required double totalKm,
    required int totalRides,
    required double totalElevation,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('public_profiles')
          .update({
            'total_km': totalKm,
            'total_rides': totalRides,
            'total_elevation': totalElevation,
          })
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Error updating stats: $e');
    }
  }

  // ==================== FRIENDSHIPS ====================

  /// Send friend request
  Future<Friendship> sendFriendRequest(String friendId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      if (user.id == friendId) {
        throw Exception('Cannot send friend request to yourself');
      }

      final data = {
        'user_id': user.id,
        'friend_id': friendId,
        'status': 'pending',
      };

      final response = await _supabase
          .from('friendships')
          .insert(data)
          .select()
          .single();

      return Friendship.fromJson(response);
    } catch (e) {
      throw Exception('Error sending friend request: $e');
    }
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('friendships')
          .update({'status': 'accepted'})
          .eq('id', friendshipId)
          .eq('friend_id', user.id); // Only recipient can accept
    } catch (e) {
      throw Exception('Error accepting friend request: $e');
    }
  }

  /// Decline friend request
  Future<void> declineFriendRequest(String friendshipId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('friendships')
          .delete()
          .eq('id', friendshipId)
          .eq('friend_id', user.id);
    } catch (e) {
      throw Exception('Error declining friend request: $e');
    }
  }

  /// Remove friend
  Future<void> removeFriend(String friendshipId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('friendships')
          .delete()
          .eq('id', friendshipId);
    } catch (e) {
      throw Exception('Error removing friend: $e');
    }
  }

  /// Get my friends (accepted)
  Future<List<Friendship>> getMyFriends() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('friendships')
          .select()
          .or('user_id.eq.${user.id},friend_id.eq.${user.id}')
          .eq('status', 'accepted');

      return (response as List)
          .map((json) => Friendship.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get pending friend requests (sent by me)
  Future<List<Friendship>> getPendingRequests() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('friendships')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'pending');

      return (response as List)
          .map((json) => Friendship.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get incoming friend requests (received)
  Future<List<Friendship>> getIncomingRequests() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('friendships')
          .select()
          .eq('friend_id', user.id)
          .eq('status', 'pending');

      return (response as List)
          .map((json) => Friendship.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if users are friends
  Future<bool> areFriends(String friendId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('friendships')
          .select('id')
          .or('user_id.eq.${user.id},friend_id.eq.${user.id}')
          .or('user_id.eq.$friendId,friend_id.eq.$friendId')
          .eq('status', 'accepted')
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
