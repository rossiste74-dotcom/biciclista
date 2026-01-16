import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:gpx/gpx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/route_coordinates.dart';
import '../models/planned_ride.dart';
import '../models/climb.dart';
import 'database_service.dart';

/// Service for importing and parsing GPX files
class GpxService {
  /// Import a GPX file using file picker
  ///
  /// Returns the selected File or null if cancelled
  Future<File?> importGpxFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gpx'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }

    return null;
  }

  /// Parse a GPX file and extract route data
  ///
  /// Returns a Map containing:
  /// - 'coordinates': RouteCoordinates
  /// - 'elevation': double (in meters)
  /// - 'allPoints': List of Map
  /// - 'elevationProfile': List of Map 
  /// - 'climbs': List of Climb
  Future<Map<String, dynamic>> parseGpxFile(File gpxFile) async {
    final gpxString = await gpxFile.readAsString();
    final gpx = GpxReader().fromString(gpxString);

    if (gpx.trks.isEmpty || gpx.trks.first.trksegs.isEmpty) {
      throw Exception('GPX file contains no track data');
    }

    // Get all waypoints from the first track
    final waypoints = gpx.trks.first.trksegs.first.trkpts;

    if (waypoints.isEmpty) {
      throw Exception('GPX track contains no waypoints');
    }

    // Extract coordinates
    final coordinates = _extractCoordinates(waypoints);

    // Calculate distance
    final distance = _calculateDistance(waypoints);

    // Calculate elevation gain
    final elevation = _calculateElevation(waypoints);

    // Convert all waypoints to LatLng for map display
    final allPoints = waypoints
        .where((wpt) => wpt.lat != null && wpt.lon != null)
        .map((wpt) => {'lat': wpt.lat!, 'lng': wpt.lon!})
        .toList();

    final elevationProfile = _getElevationProfile(waypoints);
    final climbs = _detectToughClimbs(waypoints);

    return {
      'coordinates': coordinates,
      'distance': distance,
      'elevation': elevation,
      'allPoints': allPoints,
      'elevationProfile': elevationProfile,
      'climbs': climbs,
    };
  }

  /// Extract start, middle, and end coordinates from waypoints
  RouteCoordinates _extractCoordinates(List<Wpt> waypoints) {
    if (waypoints.isEmpty) {
      return const RouteCoordinates(
        startLat: 0, startLng: 0, middleLat: 0, middleLng: 0, endLat: 0, endLng: 0
      );
    }

    final start = waypoints.first;
    final middleIndex = waypoints.length ~/ 2;
    final middle = waypoints[middleIndex];
    final end = waypoints.last;

    // Find highest point and distances
    Wpt? highest;
    double maxEle = -double.maxFinite;
    double currentDist = 0;
    double midDist = 0;
    double highDist = 0;

    for (int i = 0; i < waypoints.length; i++) {
      final wpt = waypoints[i];
      
      if (i > 0) {
        final prev = waypoints[i-1];
        if (prev.lat != null && prev.lon != null && wpt.lat != null && wpt.lon != null) {
          currentDist += _haversineDistance(prev.lat!, prev.lon!, wpt.lat!, wpt.lon!);
        }
      }

      if (i == middleIndex) {
        midDist = currentDist;
      }

      if (wpt.ele != null && wpt.ele! > maxEle) {
        maxEle = wpt.ele!;
        highest = wpt;
        highDist = currentDist;
      }
    }

    return RouteCoordinates(
      startLat: start.lat ?? 0.0,
      startLng: start.lon ?? 0.0,
      middleLat: middle.lat ?? 0.0,
      middleLng: middle.lon ?? 0.0,
      endLat: end.lat ?? 0.0,
      endLng: end.lon ?? 0.0,
      highLat: highest?.lat,
      highLng: highest?.lon,
      highDistance: highDist,
      middleDistance: midDist,
    );
  }

  /// Calculate total distance using Haversine formula
  ///
  /// Returns distance in kilometers
  double _calculateDistance(List<Wpt> waypoints) {
    double totalDistance = 0.0;

    for (int i = 0; i < waypoints.length - 1; i++) {
      final current = waypoints[i];
      final next = waypoints[i + 1];

      if (current.lat != null &&
          current.lon != null &&
          next.lat != null &&
          next.lon != null) {
        totalDistance += _haversineDistance(
          current.lat!,
          current.lon!,
          next.lat!,
          next.lon!,
        );
      }
    }

    return totalDistance;
  }

  /// Calculate distance between two points using Haversine formula
  ///
  /// Returns distance in kilometers
  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // Earth's radius in kilometers

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Convert degrees to radians
  double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Calculate total elevation gain
  ///
  /// Returns elevation gain in meters
  double _calculateElevation(List<Wpt> waypoints) {
    double totalElevation = 0.0;
    double? previousElevation;

    for (final waypoint in waypoints) {
      if (waypoint.ele != null) {
        if (previousElevation != null) {
          final elevationChange = waypoint.ele! - previousElevation;
          if (elevationChange > 0) {
            totalElevation += elevationChange;
          }
        }
        previousElevation = waypoint.ele;
      }
    }

    return totalElevation;
  }

  /// Extracts elevation profile as list of (distance, elevation)
  List<Map<String, double>> _getElevationProfile(List<Wpt> waypoints) {
    List<Map<String, double>> profile = [];
    double currentDistance = 0.0;
    
    if (waypoints.isNotEmpty && waypoints.first.ele != null) {
      profile.add({'distance': 0.0, 'elevation': waypoints.first.ele!});
    }

    for (int i = 0; i < waypoints.length - 1; i++) {
        final current = waypoints[i];
        final next = waypoints[i + 1];

        if (current.lat != null && current.lon != null && next.lat != null && next.lon != null) {
          currentDistance += _haversineDistance(current.lat!, current.lon!, next.lat!, next.lon!);
          if (next.ele != null) {
            profile.add({'distance': currentDistance, 'elevation': next.ele!});
          }
        }
    }
    return profile;
  }

  /// Detects tough climbs based on user criteria:
  /// - Gradient > 8% (for significant stretches)
  /// - Length > 2km AND Gradient > 6%
  List<Climb> _detectToughClimbs(List<Wpt> waypoints) {
    List<Climb> climbs = [];
    if (waypoints.length < 2) return climbs;

    double currentKm = 0.0;
    
    // Process in segments of ~200m to smooth data and detect climbs
    const segmentLength = 0.2; // 200m
    
    int i = 0;
    while (i < waypoints.length - 1) {
      double startKm = currentKm;
      double startEle = waypoints[i].ele ?? 0.0;
      double segmentDist = 0.0;
      
      int j = i;
      while (j < waypoints.length - 1 && segmentDist < segmentLength) {
        final p1 = waypoints[j];
        final p2 = waypoints[j + 1];
        if (p1.lat != null && p1.lon != null && p2.lat != null && p2.lon != null) {
          segmentDist += _haversineDistance(p1.lat!, p1.lon!, p2.lat!, p2.lon!);
        }
        j++;
      }
      
      double endEle = waypoints[j].ele ?? startEle;
      double elevGain = endEle - startEle;
      double gradient = segmentDist > 0 ? (elevGain / (segmentDist * 1000)) * 100 : 0.0;

      // Check if this segment is the start of a climb
      if (gradient >= 6.0) {
        // Start tracking a climb
        double climbStartKm = startKm;
        double climbStartEle = startEle;
        double totalClimbDist = segmentDist;
        double maxGrad = gradient;
        
        // Continue adding segments while gradient is positive enough
        while (j < waypoints.length - 1) {
          double segStartEle = waypoints[j].ele ?? 0.0;
          double segDist = 0.0;
          int k = j;
          while (k < waypoints.length - 1 && segDist < segmentLength) {
             final p1 = waypoints[k];
             final p2 = waypoints[k + 1];
             if (p1.lat != null && p1.lon != null && p2.lat != null && p2.lon != null) {
               segDist += _haversineDistance(p1.lat!, p1.lon!, p2.lat!, p2.lon!);
             }
             k++;
          }
          double segEndEle = waypoints[k].ele ?? segStartEle;
          double segGrad = segDist > 0 ? ((segEndEle - segStartEle) / (segDist * 1000)) * 100 : 0.0;
          
          if (segGrad < 2.0) break; // End of significant climbing
          
          totalClimbDist += segDist;
          if (segGrad > maxGrad) maxGrad = segGrad;
          j = k;
        }
        
        double climbEndEle = waypoints[j].ele ?? climbStartEle;
        double totalElevGain = climbEndEle - climbStartEle;
        double avgGrad = (totalElevGain / (totalClimbDist * 1000)) * 100;

        // Apply filters
        bool isTough = (maxGrad > 8.0 && totalElevGain > 30) || // Steep enough and covers some height
                      (totalClimbDist > 2.0 && avgGrad > 6.0);
        
        if (isTough) {
          climbs.add(Climb(
            startKm: climbStartKm,
            endKm: climbStartKm + totalClimbDist,
            lengthKm: totalClimbDist,
            elevationGain: totalElevGain,
            averageGradient: avgGrad,
            maxGradient: maxGrad,
          ));
        }
        
        currentKm = climbStartKm + totalClimbDist;
        i = j;
      } else {
        currentKm += segmentDist;
        i = j;
      }
    }

    return climbs;
  }

  /// Save GPX file to local app directory
  ///
  /// Returns the local file path
  Future<String> saveGpxLocally(File gpxFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final gpxDir = Directory('${appDir.path}/gpx_files');

    // Create directory if it doesn't exist
    if (!await gpxDir.exists()) {
      await gpxDir.create(recursive: true);
    }

    // Generate unique filename with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final originalName = path.basenameWithoutExtension(gpxFile.path);
    final newFileName = '${originalName}_$timestamp.gpx';
    final newFilePath = '${gpxDir.path}/$newFileName';

    // Copy file to app directory
    await gpxFile.copy(newFilePath);

    return newFilePath;
  }

  /// Complete workflow: import, parse, save, and create PlannedRide
  ///
  /// Returns the created PlannedRide or null if cancelled/failed
  Future<PlannedRide?> createPlannedRideFromGpx({
    required DateTime rideDate,
    String forecastWeather = '{}',
  }) async {
    // Step 1: Import GPX file
    final gpxFile = await importGpxFile();
    if (gpxFile == null) {
      return null; // User cancelled
    }

    try {
      final gpxData = await parseGpxFile(gpxFile);
      final coords = gpxData['coordinates'] as RouteCoordinates;

      // Step 3: Save GPX file locally
      final localPath = await saveGpxLocally(gpxFile);

      // Step 4: Create PlannedRide object
      final plannedRide = PlannedRide()
        ..rideDate = rideDate
        ..rideName = path.basenameWithoutExtension(localPath)
        ..gpxFilePath = localPath
        ..forecastWeather = forecastWeather
        ..distance = gpxData['distance'] as double
        ..elevation = gpxData['elevation'] as double
        ..latitude = coords.middleLat
        ..longitude = coords.middleLng;

      // Step 5: Save to database
      final db = DatabaseService();
      await db.createPlannedRide(plannedRide);

      return plannedRide;
    } catch (e) {
      // Re-throw with more context
      throw Exception('Failed to process GPX file: $e');
    }
  }
}
