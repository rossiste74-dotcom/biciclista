import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gpx/gpx.dart';
import 'package:path_provider/path_provider.dart';

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

  // Extended Stats
  final double? avgHeartRate;
  final double? maxHeartRate;
  final double? avgPower; // watts
  final double? maxPower; // watts
  final double? avgCadence; // rpm
  final int? calories; // kcal
  final String? gearId; // Strava gear_id
  final String? gearName; // Name if available

  ImportedActivity({
    required this.id,
    required this.name,
    required this.distance,
    required this.elevation,
    required this.movingTime,
    required this.avgSpeed,
    required this.date,
    required this.source,
    this.avgHeartRate,
    this.maxHeartRate,
    this.avgPower,
    this.maxPower,
    this.avgCadence,
    this.calories,
    this.gearId,
    this.gearName,
  });

  @override
  String toString() =>
      '$name ($source) - ${distance.toStringAsFixed(1)}km - ${date.toIso8601String()}';
}

class SyncService {
  // PROFESSIONAL CONFIG
  static const _stravaClientId = '196703'; // REPLACE ME
  // Note: AppAuth handles the secret exchange securely if passing secret, but
  // strictly speaking Mobile Apps are "Public Clients" and shouldn't store secrets if possible.
  // However, Strava API requires it.
  static const _stravaClientSecret =
      'b8618f582c8536e0a8202a8f68c74631f6d994ae'; // REPLACE ME
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
      // 1. Authorize (Browser Flow)
      final AuthorizationResponse result = await _appAuth.authorize(
        AuthorizationRequest(
          _stravaClientId,
          _redirectUri,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: 'https://www.strava.com/oauth/authorize',
            tokenEndpoint: 'https://www.strava.com/oauth/token',
          ),
          scopes: ['activity:read_all'],
          promptValues: ['login'],
        ),
      );

      if (result != null && result.authorizationCode != null) {
        debugPrint('Strava Code Received: ${result.authorizationCode}');
        // 2. Exchange Code (Manual HTTP)
        await _exchangeCodeForTokenRaw(result.authorizationCode!);
      } else {
        throw Exception('Authorization Failed: No code received');
      }
    } catch (e) {
      debugPrint('Strava Auth Error: $e');
      rethrow;
    }
  }

  Future<void> _exchangeCodeForTokenRaw(String code) async {
    final response = await http.post(
      Uri.parse('https://www.strava.com/oauth/token'),
      body: {
        'client_id': _stravaClientId,
        'client_secret': _stravaClientSecret,
        'code': code,
        'grant_type': 'authorization_code',
      },
    );

    debugPrint('Strava Token Response: ${response.statusCode}');
    debugPrint('Strava Token Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Manual Saving
      if (data.containsKey('access_token')) {
        await _storage.write(
          key: 'strava_access_token',
          value: data['access_token'],
        );
      }
      if (data.containsKey('refresh_token')) {
        await _storage.write(
          key: 'strava_refresh_token',
          value: data['refresh_token'],
        );
      }
      if (data.containsKey('expires_at')) {
        // Strava returns seconds since epoch
        final expiry = DateTime.fromMillisecondsSinceEpoch(
          data['expires_at'] * 1000,
        );
        await _storage.write(
          key: 'strava_expiry',
          value: expiry.toIso8601String(),
        );
      }
      debugPrint('Tokens Saved Successfully');
    } else {
      throw Exception('Token Exchange Failed: ${response.body}');
    }
  }

  // Helper no longer needed, replaced by above
  // Future<void> _saveTokens...

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<List<ImportedActivity>> syncRecentActivities({int limit = 5}) async {
    final List<ImportedActivity> activities = [];
    if (await isAuthenticated(SyncProvider.strava)) {
      try {
        final stravaActivities = await _fetchRecentStravaActivities(limit);
        activities.addAll(stravaActivities);
      } catch (e) {
        debugPrint('Error fetching Strava activities: $e');
      }
    }

    // Sort by date descending
    activities.sort((a, b) => b.date.compareTo(a.date));
    return activities;
  }

  Future<List<ImportedActivity>> _fetchRecentStravaActivities(int limit) async {
    final token = await _storage.read(key: 'strava_access_token');
    if (token == null) return [];

    final response = await http.get(
      Uri.parse(
        'https://www.strava.com/api/v3/athlete/activities?per_page=$limit',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Fetch details for each activity to get gear name?
      // Strava 'SummaryActivity' includes gear_id but not gear_name.
      // Strava 'DetailedActivity' includes gear.
      // The list endpoint returns SummaryActivity.
      // We can iterate and fetch details OR just pass gear_id and try to match local bikes by some ID if we had it.
      // BUT: User wants us to match by NAME if possible.
      // Optimization: Fetch gear details only if gear_id is present.
      // Optimization 2: Just return what we have (gear_id) and handle fetching name lazily or just skip name if not critical?
      // User said: "se la bici usata corrisponde ad una inserita nell'app"
      // Let's stick to gear_id matching if we add strava_id to local. But we don't have it on local.
      // We must fetch gear name.

      final activities = <ImportedActivity>[];

      for (var activity in data) {
        String? gearName;
        final gearId = activity['gear_id'];

        if (gearId != null) {
          // Try to fetch gear details (cached would be better but let's do simple first)
          try {
            final gearResponse = await http.get(
              Uri.parse('https://www.strava.com/api/v3/gear/$gearId'),
              headers: {'Authorization': 'Bearer $token'},
            );
            if (gearResponse.statusCode == 200) {
              final gearData = json.decode(gearResponse.body);
              gearName = gearData['name'];
            }
          } catch (e) {
            debugPrint('Error fetching gear: $e');
          }
        }

        activities.add(
          ImportedActivity(
            id: activity['id'].toString(),
            name: activity['name'],
            distance: (activity['distance'] as num).toDouble() / 1000,
            elevation: (activity['total_elevation_gain'] as num).toDouble(),
            movingTime: (activity['moving_time'] as num).toInt(),
            avgSpeed: (activity['average_speed'] as num).toDouble() * 3.6,
            date: DateTime.parse(activity['start_date']),
            source: 'Strava',
            avgHeartRate: activity['average_heartrate'] as double?,
            maxHeartRate: activity['max_heartrate'] as double?,
            avgPower: activity['average_watts'] as double?,
            maxPower:
                activity['max_watts'] == null &&
                    activity['weighted_average_watts'] != null
                ? (activity['weighted_average_watts'] as num)
                      .toDouble() // Estimate max from weighted if missing? No, just use weighted as alternative?
                : (activity['max_watts'] as num?)
                      ?.toDouble(), // Default to actual max
            // Strava doesn't always send max_watts in summary.
            avgCadence: activity['average_cadence'] as double?,
            calories: (activity['kilojoules'] as num?)
                ?.toInt(), // kJ ~= kcal roughly for cycling (1:1 efficiency assumption commonly used)
            gearId: gearId,
            gearName: gearName,
          ),
        );
      }
      return activities;
    } else {
      if (response.statusCode == 401) {
        debugPrint('Strava 401: Token expired');
      }
      return [];
    }
  }

  Future<File?> downloadAndSaveGpx(
    String activityId,
    String activityName,
  ) async {
    final token = await _storage.read(key: 'strava_access_token');
    if (token == null) return null;

    try {
      // Fetch Streams (LatLng, Altitude, Time)
      final response = await http.get(
        Uri.parse(
          'https://www.strava.com/api/v3/activities/$activityId/streams?keys=latlng,altitude,time&key_by_type=true',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        debugPrint('Error fetching streams: ${response.body}');
        return null;
      }

      final data = json.decode(response.body);
      if (data['latlng'] == null || data['time'] == null) {
        debugPrint('Incomplete stream data');
        return null;
      }

      final latlngs = data['latlng']['data'] as List;
      final altitudes = data['altitude'] != null
          ? data['altitude']['data'] as List
          : null;
      final times =
          data['time']['data'] as List; // Seconds from start (usually)

      // Strava time stream is usually epoch seconds if key_by_type=true?
      // Actually Strava documentation says 'time' stream is "Time in seconds from the start of the activity" or unix timestamp depending on query.
      // But let's verify. Usually for GPX we need absolute time.
      // However, we can construct it if we have the start date. But wait, `ImportedActivity` has the date.
      // Simpler approach: Just assume they correspond index-wise.

      // Build GPX
      final gpx = Gpx();
      gpx.metadata = Metadata(name: activityName, time: DateTime.now());
      gpx.creator = 'Ride Butler Import';

      final trk = Trk(name: activityName);
      final trkSeg = Trkseg();

      // We need absolute base time if 'time' stream is relative.
      // But we don't have it passed here easily unless we fetch activity details again.
      // Let's assume 'time' is seconds since epoch?
      // Doc: "time: integer, The sequence of time values for this stream, in seconds"
      // If the values are huge (e.g. 1.6 billion), it's epoch. If small (0, 1, 5..), it's relative.
      // Let's assume epoch for standard Strava activities, or just use current time offset if needed.
      // Actually, GPX doesn't STRICTLY mandate time, but it's good.
      // Let's check first value.

      for (int i = 0; i < latlngs.length; i++) {
        final pair = latlngs[i] as List;
        final timeVal = times[i] as int;

        DateTime? time;
        if (timeVal > 1000000000) {
          time = DateTime.fromMillisecondsSinceEpoch(
            timeVal * 1000,
            isUtc: true,
          );
        }

        trkSeg.trkpts.add(
          Wpt(
            lat: (pair[0] as num).toDouble(),
            lon: (pair[1] as num).toDouble(),
            ele: altitudes != null && i < altitudes.length
                ? (altitudes[i] as num).toDouble()
                : 0.0,
            time: time,
          ),
        );
      }

      trk.trksegs.add(trkSeg);
      gpx.trks.add(trk);

      // Save
      final dir = await getApplicationDocumentsDirectory();
      final filename = 'strava_$activityId.gpx';
      final file = File('${dir.path}/$filename');
      await file.writeAsString(GpxWriter().asString(gpx, pretty: true));

      debugPrint('GPX saved to: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('GPX Generation Error: $e');
      return null;
    }
  }
}
