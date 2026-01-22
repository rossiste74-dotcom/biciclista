import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_preferences.dart';
import '../models/terrain_analysis.dart';

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
  final double elevationLossM;
  final RouteProfile profile;
  
  /// Elevation data for each point (in meters)
  /// Used for elevation profile visualization
  final List<double>? elevationProfile;
  
  /// Percentage of route on dedicated cycleways (0.0-100.0)
  /// Estimated from road class data when available
  final double? cyclewayPercentage;
  
  /// Detailed terrain breakdown (asphalt/gravel/path percentages)
  final TerrainBreakdown? terrainBreakdown;
  
  /// Technical difficulty rating (1-5)
  final DifficultyRating? difficulty;

  RouteSegment({
    required this.geometry,
    required this.distanceKm,
    required this.elevationGainM,
    this.elevationLossM = 0.0,
    required this.profile,
    this.elevationProfile,
    this.cyclewayPercentage,
    this.terrainBreakdown,
    this.difficulty,
  });
  
  /// Calculate slope between two consecutive points
  /// Returns slope in percentage (rise/run * 100)
  static double calculateSlope(double elevationDiff, double distanceM) {
    if (distanceM == 0) return 0.0;
    return (elevationDiff / distanceM) * 100.0;
  }
}

class RoutePlanningService {
  // BRouter Public API (Free, unlimited)
  static const String _brouterBaseUrl = 'https://brouter.de/brouter';
  
  // OSRM Public Server (Fallback only)
  static const String _osrmBaseUrl = 'http://router.project-osrm.org/route/v1';

  Future<RouteSegment?> getRouteSegment({
    required LatLng start,
    required LatLng end,
    required RouteProfile profile,
    String? graphHopperKey,
    RoutePreferences preferences = const RoutePreferences(),
  }) async {
    try {
      // Use BRouter for advanced bike routing (free, unlimited)
      // Falls back to OSRM if BRouter fails
      try {
        return await _fetchViaBRouter(start, end, profile, preferences);
      } catch (e) {
        debugPrint('BRouter failed, falling back to OSRM: $e');
        return _fetchOsrmRoute(start, end);
      }
    } catch (e) {
      debugPrint('Error fetching route segment: $e');
      return null;
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

  /// Generate an adventure route from start to destination
  /// Maximizes trails and scenic paths while avoiding busy roads
  Future<RouteSegment?> generateAdventureRoute({
    required LatLng start,
    required LatLng destination,
    double? maxDistanceKm,
    ElevationPreference elevation = ElevationPreference.balanced,
  }) async {
    try {
      // Use MTB profile with custom preferences for maximum trail usage
      final preferences = RoutePreferences(
        prioritizeCycleways: false, // Don't prioritize paved cycleways
        avoidSteepClimbs: elevation == ElevationPreference.flat,
      );
      
      // Generate route using BRouter with adventure-optimized profile
      final route = await _fetchAdventureRoute(
        start, 
        destination, 
        preferences,
        elevation,
      );
      
      // Check max distance constraint if specified
      if (maxDistanceKm != null && route.distanceKm > maxDistanceKm) {
        debugPrint('Adventure route exceeds max distance: ${route.distanceKm} > $maxDistanceKm');
        // Return null to indicate constraint violation
        return null;
      }
      
      return route;
    } catch (e) {
      debugPrint('Error generating adventure route: $e');
      return null;
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

  /// Fetch route via BRouter public API
  /// BRouter provides advanced bike routing with custom profiles
  Future<RouteSegment> _fetchViaBRouter(
    LatLng start,
    LatLng end,
    RouteProfile profile,
    RoutePreferences preferences,
  ) async {
    // Map profile to BRouter profile name
    final brouterProfile = _getBRouterProfile(profile);
    
    // BRouter uses lon,lat format (GeoJSON standard)
    final url = Uri.parse(
      '$_brouterBaseUrl?'
      'lonlats=${start.longitude},${start.latitude}|${end.longitude},${end.latitude}'
      '&profile=$brouterProfile'
      '&alternativeidx=0'
      '&format=geojson'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final geoJson = jsonDecode(response.body);
      
      if (geoJson['type'] == 'FeatureCollection' && 
          geoJson['features'] != null && 
          (geoJson['features'] as List).isNotEmpty) {
        
        final feature = geoJson['features'][0];
        final geometry = feature['geometry'];
        final properties = feature['properties'];
        
        if (geometry['type'] == 'LineString') {
          final coords = geometry['coordinates'] as List;
          
          // Parse coordinates (lon, lat, elevation) - handle potential strings
          final points = coords.map<LatLng>((coord) {
            final lon = _parseDouble(coord[0]) ?? 0.0;
            final lat = _parseDouble(coord[1]) ?? 0.0;
            return LatLng(lat, lon);
          }).toList();
          
          // Extract elevations
          final elevations = coords.map<double>((coord) {
            return coord.length > 2 ? (_parseDouble(coord[2]) ?? 0.0) : 0.0;
          }).toList();
          
          // Parse properties - BRouter may return strings or numbers
          final distanceM = _parseDouble(properties['track-length']) ?? 0.0;
          final distanceKm = distanceM / 1000.0;
          final ascendM = _parseDouble(properties['filtered ascend']) ?? 0.0;
          final descendM = _parseDouble(properties['filtered descend']) ?? 0.0;
          
          // Analyze terrain from messages
          final terrainBreakdown = _analyzeTerrainFromMessages(properties['messages']);
          
          // Calculate difficulty
          final difficulty = _calculateDifficulty(
            terrainBreakdown,
            ascendM,
            distanceKm,
          );
          
          return RouteSegment(
            geometry: points,
            distanceKm: distanceKm,
            elevationGainM: ascendM,
            elevationLossM: descendM,
            profile: profile,
            elevationProfile: elevations,
            terrainBreakdown: terrainBreakdown,
            difficulty: difficulty,
          );
        }
      }
    }
    throw Exception('BRouter Failed: ${response.statusCode} ${response.body}');
  }
  
  /// Map RouteProfile to BRouter profile name
  String _getBRouterProfile(RouteProfile profile) {
    switch (profile) {
      case RouteProfile.asphalt:
        return 'trekking'; // Optimized for paved cycleways
      case RouteProfile.gravel:
        return 'fastbike-lowtraffic'; // Balanced gravel/road
      case RouteProfile.mtb:
        return 'mtb'; // Off-road trails and paths
    }
  }
  
  /// Fetch adventure route via BRouter
  /// Optimized for maximum trail usage and scenic paths
  Future<RouteSegment> _fetchAdventureRoute(
    LatLng start,
    LatLng destination,
    RoutePreferences preferences,
    ElevationPreference elevation,
  ) async {
    // Use MTB profile for maximum off-road capability
    final profile = 'mtb';
    
    // BRouter uses lon,lat format (GeoJSON standard)
    // Add custom parameters to avoid busy roads
    final url = Uri.parse(
      '$_brouterBaseUrl?'
      'lonlats=${start.longitude},${start.latitude}|${destination.longitude},${destination.latitude}'
      '&profile=$profile'
      '&alternativeidx=0'
      '&format=geojson'
      // Adventure mode: prefer scenic routes
      '&timode=0' // No traffic mode (avoid busy roads)
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final geoJson = jsonDecode(response.body);
      
      if (geoJson['type'] == 'FeatureCollection' && 
          geoJson['features'] != null && 
          (geoJson['features'] as List).isNotEmpty) {
        
        final feature = geoJson['features'][0];
        final geometry = feature['geometry'];
        final properties = feature['properties'];
        
        if (geometry['type'] == 'LineString') {
          final coords = geometry['coordinates'] as List;
          
          // Parse coordinates (lon, lat, elevation)
          final points = coords.map<LatLng>((coord) {
            final lon = _parseDouble(coord[0]) ?? 0.0;
            final lat = _parseDouble(coord[1]) ?? 0.0;
            return LatLng(lat, lon);
          }).toList();
          
          // Extract elevations
          final elevations = coords.map<double>((coord) {
            return coord.length > 2 ? (_parseDouble(coord[2]) ?? 0.0) : 0.0;
          }).toList();
          
          // Parse properties
          final distanceM = _parseDouble(properties['track-length']) ?? 0.0;
          final distanceKm = distanceM / 1000.0;
          final ascendM = _parseDouble(properties['filtered ascend']) ?? 0.0;
          final descendM = _parseDouble(properties['filtered descend']) ?? 0.0;
          
          // Analyze terrain from messages
          final terrainBreakdown = _analyzeTerrainFromMessages(properties['messages']);
          
          // Calculate difficulty
          final difficulty = _calculateDifficulty(
            terrainBreakdown,
            ascendM,
            distanceKm,
          );
          
          return RouteSegment(
            geometry: points,
            distanceKm: distanceKm,
            elevationGainM: ascendM,
            elevationLossM: descendM,
            profile: RouteProfile.mtb, // Adventure routes use MTB profile
            elevationProfile: elevations,
            terrainBreakdown: terrainBreakdown,
            difficulty: difficulty,
          );
        }
      }
    }
    throw Exception('BRouter Adventure Route Failed: ${response.statusCode}');
  }
  
  /// Analyze terrain breakdown from BRouter messages
  /// BRouter includes surface/highway tags in route messages
  TerrainBreakdown _analyzeTerrainFromMessages(List? messages) {
    if (messages == null || messages.isEmpty) {
      return const TerrainBreakdown(
        asphaltPercent: 100.0,
        gravelPercent: 0.0,
        pathPercent: 0.0,
      );
    }
    
    double asphalt = 0, gravel = 0, path = 0;
    
    for (var msg in messages) {
      final msgStr = msg.toString().toLowerCase();
      
      // Check surface tags
      if (msgStr.contains('surface=asphalt') || 
          msgStr.contains('highway=cycleway') ||
          msgStr.contains('highway=residential')) {
        asphalt++;
      } else if (msgStr.contains('surface=gravel') || 
                 msgStr.contains('surface=compacted') ||
                 msgStr.contains('tracktype=grade1') ||
                 msgStr.contains('tracktype=grade2')) {
        gravel++;
      } else if (msgStr.contains('highway=path') || 
                 msgStr.contains('highway=track') ||
                 msgStr.contains('surface=ground') ||
                 msgStr.contains('surface=earth')) {
        path++;
      } else {
        // Default to asphalt for unknown
        asphalt++;
      }
    }
    
    final total = asphalt + gravel + path;
    if (total == 0) {
      return const TerrainBreakdown(
        asphaltPercent: 100.0,
        gravelPercent: 0.0,
        pathPercent: 0.0,
      );
    }
    
    return TerrainBreakdown(
      asphaltPercent: (asphalt / total) * 100,
      gravelPercent: (gravel / total) * 100,
      pathPercent: (path / total) * 100,
    );
  }
  
  /// Calculate difficulty rating based on terrain and elevation
  DifficultyRating _calculateDifficulty(
    TerrainBreakdown terrain,
    double elevationGainM,
    double distanceKm,
  ) {
    double score = 0;
    
    // Terrain weight (0-40 points)
    score += terrain.asphaltPercent * 0.1;
    score += terrain.gravelPercent * 0.3;
    score += terrain.pathPercent * 0.4;
    
    // Elevation weight (0-40 points)
    final elevPerKm = elevationGainM / (distanceKm > 0 ? distanceKm : 1);
    if (elevPerKm > 100) {
      score += 40;
    } else if (elevPerKm > 50) {
      score += 30;
    } else if (elevPerKm > 20) {
      score += 20;
    } else {
      score += 10;
    }
    
    // Distance weight (0-20 points)
    if (distanceKm > 80) {
      score += 20;
    } else if (distanceKm > 40) {
      score += 15;
    } else {
      score += 10;
    }
    
    // Map to rating (0-100 -> 1-5)
    if (score < 20) return DifficultyRating.beginner;
    if (score < 40) return DifficultyRating.easy;
    if (score < 60) return DifficultyRating.moderate;
    if (score < 80) return DifficultyRating.hard;
    return DifficultyRating.expert;
  }
  
  /// Parse double from dynamic value (handles both num and String)
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Future<RouteSegment> _fetchGraphHopperRoute(
    LatLng start, 
    LatLng end, 
    RouteProfile profile,
    String apiKey,
    RoutePreferences preferences,
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

    // Build query parameters
    final params = <String, String>{
      'point': '${start.latitude},${start.longitude}',
      'point': '${end.latitude},${end.longitude}',
      'vehicle': vehicle,
      'key': apiKey,
      'points_encoded': 'false',
      'elevation': 'true',
      'details': 'road_class', // Get road type info
    };
    
    // Add cycleway priority (if API supports)
    if (preferences.prioritizeCycleways) {
      params['avoid'] = 'motorway';
      params['weighting'] = 'fastest'; // Prefer faster routes (often cycleways)
    }
    
    // Note: Custom models for fine-grained priority require GraphHopper Pro
    // For free tier, we use basic avoid/weighting parameters
    // This method is kept as fallback but Edge Function is now preferred
    
    final url = Uri.parse('https://graphhopper.com/api/1/route').replace(queryParameters: params);

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
        
        // Extract elevation profile
        final elevations = coords.map<double>((p) {
          // Third element is elevation in meters
          return p.length > 2 ? (p[2] as num).toDouble() : 0.0;
        }).toList();

        final dist = (path['distance'] as num).toDouble() / 1000.0;
        final ascend = (path['ascend'] as num?)?.toDouble() ?? 0.0;
        final descend = (path['descend'] as num?)?.toDouble() ?? 0.0;
        
        // Estimate cycleway percentage from road_class details if available
        double? cyclewayPct;
        if (path['details'] != null && path['details']['road_class'] != null) {
          final roadClasses = path['details']['road_class'] as List;
          int cyclewaySegments = 0;
          for (var segment in roadClasses) {
            final roadType = segment[2] as String?;
            if (roadType != null && 
                (roadType.contains('cycleway') || roadType.contains('path'))) {
              cyclewaySegments++;
            }
          }
          cyclewayPct = roadClasses.isNotEmpty 
              ? (cyclewaySegments / roadClasses.length) * 100.0 
              : 0.0;
        }

        return RouteSegment(
          geometry: points,
          distanceKm: dist,
          elevationGainM: ascend,
          elevationLossM: descend,
          profile: profile,
          elevationProfile: elevations,
          cyclewayPercentage: cyclewayPct,
        );
      }
    }
    throw Exception('GraphHopper Failed: ${response.statusCode} ${response.body}');
  }
}
