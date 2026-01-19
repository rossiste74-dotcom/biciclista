import 'dart:math';
import 'package:gpx/gpx.dart';

/// GPX Optimizer with Ramer-Douglas-Peucker algorithm
/// Reduces GPX file size by ~70% while maintaining track precision
class GpxOptimizer {
  /// Simplify GPX points using Ramer-Douglas-Peucker algorithm
  /// 
  /// [points] - List of GPX waypoints
  /// [epsilon] - Tolerance (default 0.0001 ≈ 11m precision)
  /// Returns simplified list of points
  static List<Wpt> simplifyPoints(List<Wpt> points, {double epsilon = 0.0001}) {
    if (points.length <= 2) return points;

    return _ramerDouglasPeucker(points, epsilon);
  }

  /// Core RDP algorithm implementation
  static List<Wpt> _ramerDouglasPeucker(List<Wpt> points, double epsilon) {
    if (points.length <= 2) return points;

    // Find point with maximum distance from line segment
    double maxDistance = 0;
    int maxIndex = 0;
    final end = points.length - 1;

    for (int i = 1; i < end; i++) {
      final distance = _perpendicularDistance(
        points[i],
        points[0],
        points[end],
      );

      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    // If max distance is greater than epsilon, recursively simplify
    if (maxDistance > epsilon) {
      // Recursive call
      final leftPoints = _ramerDouglasPeucker(
        points.sublist(0, maxIndex + 1),
        epsilon,
      );
      final rightPoints = _ramerDouglasPeucker(
        points.sublist(maxIndex),
        epsilon,
      );

      // Combine result (remove duplicate middle point)
      return [...leftPoints.sublist(0, leftPoints.length - 1), ...rightPoints];
    } else {
      // All points between first and last can be removed
      return [points.first, points.last];
    }
  }

  /// Calculate perpendicular distance from point to line segment
  static double _perpendicularDistance(Wpt point, Wpt lineStart, Wpt lineEnd) {
    final x0 = point.lat!;
    final y0 = point.lon!;
    final x1 = lineStart.lat!;
    final y1 = lineStart.lon!;
    final x2 = lineEnd.lat!;
    final y2 = lineEnd.lon!;

    final dx = x2 - x1;
    final dy = y2 - y1;

    // Normalize
    final mag = sqrt(dx * dx + dy * dy);
    if (mag > 0) {
      final u = ((x0 - x1) * dx + (y0 - y1) * dy) / (mag * mag);

      if (u < 0) {
        // Closest to start point
        return _distance(x0, y0, x1, y1);
      } else if (u > 1) {
        // Closest to end point
        return _distance(x0, y0, x2, y2);
      } else {
        // Perpendicular distance
        final ix = x1 + u * dx;
        final iy = y1 + u * dy;
        return _distance(x0, y0, ix, iy);
      }
    } else {
      // Start and end are the same
      return _distance(x0, y0, x1, y1);
    }
  }

  /// Calculate Euclidean distance between two points
  static double _distance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return sqrt(dx * dx + dy * dy);
  }

  /// Optimize entire GPX file
  /// 
  /// [gpx] - GPX object to optimize
  /// [epsilon] - Tolerance for simplification
  /// Returns optimized GPX object with stats
  static OptimizedGpx optimizeGpx(Gpx gpx, {double epsilon = 0.0001}) {
    int originalPoints = 0;
    int optimizedPoints = 0;

    // Process all tracks
    for (final track in gpx.trks) {
      for (final segment in track.trksegs) {
        originalPoints += segment.trkpts.length;
        
        // Simplify points
        final simplified = simplifyPoints(segment.trkpts, epsilon: epsilon);
        optimizedPoints += simplified.length;
        
        // Replace with simplified points
        segment.trkpts.clear();
        segment.trkpts.addAll(simplified);
      }
    }

    final reductionPercent = originalPoints > 0
        ? ((originalPoints - optimizedPoints) / originalPoints * 100).toDouble()
        : 0.0;

    return OptimizedGpx(
      gpx: gpx,
      originalPoints: originalPoints,
      optimizedPoints: optimizedPoints,
      reductionPercent: reductionPercent,
    );
  }

  /// Convert GPX to JSON for Supabase storage
  static Map<String, dynamic> gpxToJson(Gpx gpx) {
    final List<Map<String, dynamic>> points = [];

    for (final track in gpx.trks) {
      for (final segment in track.trksegs) {
        for (final point in segment.trkpts) {
          points.add({
            'lat': point.lat,
            'lon': point.lon,
            'ele': point.ele,
            'time': point.time?.toIso8601String(),
          });
        }
      }
    }

    return {
      'points': points,
      'metadata': {
        'name': gpx.metadata?.name,
        'desc': gpx.metadata?.desc,
        'time': gpx.metadata?.time?.toIso8601String(),
      },
    };
  }

  /// Convert JSON back to GPX
  static Gpx jsonToGpx(Map<String, dynamic> json) {
    final gpx = Gpx();
    gpx.version = '1.1';
    gpx.creator = 'Biciclistico';

    // Metadata
    if (json['metadata'] != null) {
      gpx.metadata = Metadata();
      gpx.metadata!.name = json['metadata']['name'];
      gpx.metadata!.desc = json['metadata']['desc'];
      if (json['metadata']['time'] != null) {
        gpx.metadata!.time = DateTime.parse(json['metadata']['time']);
      }
    }

    // Points
    final trk = Trk();
    final seg = Trkseg();

    if (json['points'] != null) {
      for (final pointData in json['points']) {
        final wpt = Wpt();
        wpt.lat = pointData['lat'];
        wpt.lon = pointData['lon'];
        wpt.ele = pointData['ele'];
        if (pointData['time'] != null) {
          wpt.time = DateTime.parse(pointData['time']);
        }
        seg.trkpts.add(wpt);
      }
    }

    trk.trksegs.add(seg);
    gpx.trks.add(trk);

    return gpx;
  }
}

/// Result of GPX optimization
class OptimizedGpx {
  final Gpx gpx;
  final int originalPoints;
  final int optimizedPoints;
  final double reductionPercent;

  OptimizedGpx({
    required this.gpx,
    required this.originalPoints,
    required this.optimizedPoints,
    required this.reductionPercent,
  });

  @override
  String toString() {
    return 'OptimizedGpx(original: $originalPoints, optimized: $optimizedPoints, reduction: ${reductionPercent.toStringAsFixed(1)}%)';
  }
}
