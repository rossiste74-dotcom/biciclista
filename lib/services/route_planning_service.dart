import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

enum RouteProfile {
  asphalt,
  gravel,
  mtb,
}

enum RouteType {
  loop,
  outAndBack,
}

enum ElevationPreference {
  flat,   // Minimize elevation
  balanced, // Average/Random
  hilly,   // Maximize elevation
}

class RouteSegment {
  final List<LatLng> geometry;
  final double distanceKm;
  final double elevationGainM;
  final double elevationLossM; // Added for correct Out-and-Back calculation
  final RouteProfile profile;

  RouteSegment({
    required this.geometry,
    required this.distanceKm,
    required this.elevationGainM,
    this.elevationLossM = 0.0,
    required this.profile,
  });
}

class RoutePlanningService {
  // TODO: Insert your GraphHopper API Key here or handle it securely
  static const String _graphHopperApiKey = 'YOUR_GRAPHHOPPER_API_KEY';
  
  // OSRM Public Server (Demo use only)
  static const String _osrmBaseUrl = 'http://router.project-osrm.org/route/v1';

  // GraphHopper API
  static const String _graphHopperBaseUrl = 'https://graphhopper.com/api/1/route';

  Future<RouteSegment?> getRouteSegment({
    required LatLng start,
    required LatLng end,
    required RouteProfile profile,
    String? graphHopperKey,
  }) async {
    final apiKey = graphHopperKey ?? _graphHopperApiKey;

    try {
      if (profile == RouteProfile.asphalt) {
        return _fetchOsrmRoute(start, end);
      } else {
        return _fetchGraphHopperRoute(start, end, profile, apiKey);
      }
    } catch (e) {
      debugPrint('Error fetching route segment: $e');
      return null; // or throw
    }
  }

  Future<RouteSegment?> generateRoute({
    required LatLng start,
    required double distanceKm,
    required RouteType type,
    required RouteProfile profile,
    ElevationPreference elevation = ElevationPreference.balanced,
    String? graphHopperKey,
  }) async {
    // Generate multiple candidates and pick the best matching elevation preference
    int attempts = elevation == ElevationPreference.balanced ? 1 : 3;
    List<RouteSegment> candidates = [];

    for (int i = 0; i < attempts; i++) {
        try {
          RouteSegment? candidate;
          if (type == RouteType.outAndBack) {
            candidate = await _generateOutAndBack(start, distanceKm, profile, graphHopperKey);
          } else {
            candidate = await _generateLoop(start, distanceKm, profile, graphHopperKey);
          }
          if (candidate != null) candidates.add(candidate);
        } catch (e) {
          debugPrint('Candidate gen error: $e');
        }
    }

    if (candidates.isEmpty) return null;

    // Sort by elevation gain
    candidates.sort((a, b) => a.elevationGainM.compareTo(b.elevationGainM));

    switch (elevation) {
      case ElevationPreference.flat:
        return candidates.first; // Lowest gain
      case ElevationPreference.hilly:
        return candidates.last; // Highest gain
      case ElevationPreference.balanced:
        // Return random or middle?
        // If we generated 1 (default for balanced), returns it.
        // If we generated 3 for balanced (maybe to avoid bad routes?), pick middle.
        // Current logic: balanced -> attempts=1. So returns first.
        return candidates[(candidates.length - 1) ~/ 2];
    }
  }

  Future<RouteSegment?> _generateOutAndBack(LatLng start, double distKm, RouteProfile profile, String? apiKey) async {
    final rng = Random();
    // Random bearing (0-360)
    final bearing = rng.nextDouble() * 360.0;
    
    // Destination is roughly half the distance
    // Using simple spherical calculation
    final dest = const Distance().offset(start, (distKm / 2.0) * 1000, bearing);

    // Leg 1: Start -> Dest
    final leg1 = await getRouteSegment(start: start, end: dest, profile: profile, graphHopperKey: apiKey);
    if (leg1 == null) return null;

    // Leg 2: Reverse geometry of Leg 1 (Backtracking exactly)
    // We reverse the points
    final backPoints = leg1.geometry.reversed.toList();
    
    // Gain of return trip = Loss of forward trip.
    final backGain = leg1.elevationLossM;
    final backLoss = leg1.elevationGainM;
    
    // Combine geometry (skip duplicate mid point)
    final fullGeom = [...leg1.geometry, ...backPoints.skip(1)];
    
    return RouteSegment(
      geometry: fullGeom,
      distanceKm: leg1.distanceKm * 2,
      elevationGainM: leg1.elevationGainM + backGain,
      elevationLossM: leg1.elevationLossM + backLoss,
      profile: profile,
    );
  }

  Future<RouteSegment?> _generateLoop(LatLng start, double distKm, RouteProfile profile, String? apiKey) async {
    final rng = Random();
    
    // Triangle Strategy
    // Perimeter ~ 3 * legDist. legDist = distKm / 3.
    final legDistM = (distKm / 3.0) * 1000;
    
    final bearing1 = rng.nextDouble() * 360.0;
    final p1 = const Distance().offset(start, legDistM, bearing1);
    
    final bearing2 = (bearing1 + 120) % 360;
    final p2 = const Distance().offset(p1, legDistM, bearing2);
    
    // Leg 1: Start -> P1
    final leg1 = await getRouteSegment(start: start, end: p1, profile: profile, graphHopperKey: apiKey);
    if (leg1 == null) return null;

    // Leg 2: P1 -> P2
    final leg2 = await getRouteSegment(start: p1, end: p2, profile: profile, graphHopperKey: apiKey);
    if (leg2 == null) return null;

    // Leg 3: P2 -> Start
    final leg3 = await getRouteSegment(start: p2, end: start, profile: profile, graphHopperKey: apiKey);
    if (leg3 == null) return null;

    return _combineSegments([leg1, leg2, leg3]);
  }

  RouteSegment _combineSegments(List<RouteSegment> segments) {
    if (segments.isEmpty) throw Exception('No segments');
    
    final fullGeom = <LatLng>[];
    double totalDist = 0;
    double totalEleGain = 0;
    double totalEleLoss = 0;
    
    for (int i = 0; i < segments.length; i++) {
        final seg = segments[i];
        if (i == 0) {
           fullGeom.addAll(seg.geometry);
        } else {
           // Skip first point to avoid duplication if perfectly continuous
           fullGeom.addAll(seg.geometry.skip(1));
        }
        totalDist += seg.distanceKm;
        totalEleGain += seg.elevationGainM;
        totalEleLoss += seg.elevationLossM;
    }
    
    return RouteSegment(
      geometry: fullGeom,
      distanceKm: totalDist,
      elevationGainM: totalEleGain,
      elevationLossM: totalEleLoss,
      profile: segments.first.profile,
    );
  }

  Future<RouteSegment> _fetchOsrmRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      '$_osrmBaseUrl/bicycle/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 'Ok' && (data['routes'] as List).isNotEmpty) {
        final route = data['routes'][0];
        final geometry = route['geometry'];
        final coords = geometry['coordinates'] as List;
        
        final points = coords.map<LatLng>((p) {
          // GeoJSON is [lon, lat]
          return LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble());
        }).toList();

        final dist = (route['distance'] as num).toDouble() / 1000.0;
        
        return RouteSegment(
          geometry: points,
          distanceKm: dist,
          elevationGainM: 0.0, 
          elevationLossM: 0.0,
          profile: RouteProfile.asphalt,
        );
      }
    }
    throw Exception('OSRM Failed: ${response.statusCode}');
  }

  Future<RouteSegment> _fetchGraphHopperRoute(
    LatLng start, 
    LatLng end, 
    RouteProfile profile,
    String apiKey,
  ) async {
    String vehicle;
    switch (profile) {
      case RouteProfile.mtb:
        vehicle = 'mtb';
        break;
      case RouteProfile.gravel:
        vehicle = 'mtb'; // Using mtb for gravel/offroad generic
        break;
      default:
        vehicle = 'bike';
    }

    // Ensure we ask for details 
    final url = Uri.parse(
      '$_graphHopperBaseUrl?point=${start.latitude},${start.longitude}&point=${end.latitude},${end.longitude}&vehicle=$vehicle&key=$apiKey&points_encoded=false&elevation=true'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['paths'] != null && (data['paths'] as List).isNotEmpty) {
        final path = data['paths'][0];
        final pointsData = path['points']; 
        final coords = pointsData['coordinates'] as List;

        final points = coords.map<LatLng>((p) {
          // [lon, lat, ele]
          return LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble());
        }).toList();

        final dist = (path['distance'] as num).toDouble() / 1000.0;
        final ascend = (path['ascend'] as num?)?.toDouble() ?? 0.0;
        final descend = (path['descend'] as num?)?.toDouble() ?? 0.0; 

        return RouteSegment(
          geometry: points,
          distanceKm: dist,
          elevationGainM: ascend,
          elevationLossM: descend,
          profile: profile,
        );
      }
    }
    throw Exception('GraphHopper Failed: ${response.statusCode} ${response.body}');
  }
}
