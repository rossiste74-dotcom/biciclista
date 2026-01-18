import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum SyncProvider { strava, komoot }

class ImportedActivity {
  final String id;
  final String name;
  final double distance; // km
  final double elevation; // m
  final int movingTime; // seconds
  final double avgSpeed; // km/h
  final DateTime date;
  final String source; // "strava" or "komoot"

  ImportedActivity({
    required this.id,
    required this.name,
    required this.distance,
    required this.elevation,
    required this.movingTime,
    required this.avgSpeed,
    required this.date,
    required this.source,
  });

  @override
  String toString() => '$name ($source) - ${distance.toStringAsFixed(1)}km - ${date.toIso8601String()}';
}

class SyncService {
  // PROFESSIONAL CONFIG
  static const _stravaClientId = 'YOUR_STRAVA_CLIENT_ID'; // REPLACE ME
  // Note: AppAuth handles the secret exchange securely if passing secret, but 
  // strictly speaking Mobile Apps are "Public Clients" and shouldn't store secrets if possible.
  // However, Strava API requires it.
  static const _stravaClientSecret = 'YOUR_STRAVA_CLIENT_SECRET'; // REPLACE ME
  // User requested localhost as callback host (matches Strava default for some setups)
  static const _redirectUri = 'ridebutler://localhost'; 
  
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> init() async {}

  Future<bool> isAuthenticated(SyncProvider provider) async {
     final token = await _storage.read(key: '${provider.name}_access_token');
     return token != null;
  }

  Future<void> authenticate(SyncProvider provider) async {
    if (provider == SyncProvider.strava) {
      await _authenticateStrava();
    } 
    // Komoot TODO: Similar implementation
  }

  Future<void> _authenticateStrava() async {
    try {
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _stravaClientId,
          _redirectUri,
          clientSecret: _stravaClientSecret,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: 'https://www.strava.com/oauth/authorize',
            tokenEndpoint: 'https://www.strava.com/oauth/token',
          ),
          scopes: ['activity:read_all'],
          promptValues: ['login'], // Force login prompt if needed
        ),
      );

      if (result != null) {
        await _saveTokens(SyncProvider.strava, result);
      }
    } catch (e) {
      debugPrint('Strava Auth Error: $e');
      rethrow;
    }
  }

  Future<void> _saveTokens(SyncProvider provider, AuthorizationTokenResponse tokens) async {
     if (tokens.accessToken != null) {
       await _storage.write(key: '${provider.name}_access_token', value: tokens.accessToken);
     }
     if (tokens.refreshToken != null) {
       await _storage.write(key: '${provider.name}_refresh_token', value: tokens.refreshToken);
     }
     if (tokens.accessTokenExpirationDateTime != null) {
        await _storage.write(key: '${provider.name}_expiry', value: tokens.accessTokenExpirationDateTime!.toIso8601String());
     }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<ImportedActivity?> syncLastActivity() async {
    if (await isAuthenticated(SyncProvider.strava)) {
       try {
         return await _fetchLastStravaActivity();
       } catch (e) {
         debugPrint('Error fetching Strava activity: $e');
         // Verify Refresh logic here if needed (omitted for brevity but recommended)
       }
    }
    return null;
  }

  Future<ImportedActivity?> _fetchLastStravaActivity() async {
    final token = await _storage.read(key: 'strava_access_token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('https://www.strava.com/api/v3/athlete/activities?per_page=1'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final activity = data.first;
        return ImportedActivity(
          id: activity['id'].toString(),
          name: activity['name'],
          distance: (activity['distance'] as num).toDouble() / 1000, 
          elevation: (activity['total_elevation_gain'] as num).toDouble(),
          movingTime: activity['moving_time'],
          avgSpeed: (activity['average_speed'] as num).toDouble() * 3.6,
          date: DateTime.parse(activity['start_date']),
          source: 'Strava',
        );
      }
    } else {
       if (response.statusCode == 401) {
          // Token expired -> Call refresh logic (TODO)
          debugPrint('Strava 401: Token expired');
       }
    }
    return null;
  }
}
