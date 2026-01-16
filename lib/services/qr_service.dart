import 'dart:convert';
import '../models/planned_ride.dart';

class QrService {
  /// Encodes a ride into a compact JSON for QR sharing.
  /// If [allPoints] is provided, it simplifies them to stay within QR limits.
  static String encodeRide(PlannedRide ride, List<Map<String, double>>? allPoints) {
    // Simplify points if they exist (max 50 points for QR capacity)
    List<List<double>>? simplifiedPoints;
    if (allPoints != null && allPoints.isNotEmpty) {
      simplifiedPoints = [];
      final int step = (allPoints.length / 40).ceil();
      for (int i = 0; i < allPoints.length; i += step) {
        final p = allPoints[i];
        simplifiedPoints.add([
          double.parse(p['lat']!.toStringAsFixed(5)),
          double.parse(p['lng']!.toStringAsFixed(5))
        ]);
      }
      // Always include the last point if not already added
      if (simplifiedPoints.last[0] != allPoints.last['lat'] || 
          simplifiedPoints.last[1] != allPoints.last['lng']) {
        simplifiedPoints.add([
          double.parse(allPoints.last['lat']!.toStringAsFixed(5)),
          double.parse(allPoints.last['lng']!.toStringAsFixed(5))
        ]);
      }
    }

    final data = {
      'v': 1, // Version of the format
      'n': ride.rideName ?? 'Giro in bici',
      'dt': ride.rideDate.toIso8601String(),
      'dist': double.parse(ride.distance.toStringAsFixed(2)),
      'elev': ride.elevation.toInt(),
      'lat': ride.latitude != null ? double.parse(ride.latitude!.toStringAsFixed(5)) : null,
      'lng': ride.longitude != null ? double.parse(ride.longitude!.toStringAsFixed(5)) : null,
      'notes': ride.notes,
      'pts': simplifiedPoints,
    };

    return jsonEncode(data);
  }

  /// Decodes a QR string back into a PlannedRide object and its simplified track.
  static Map<String, dynamic> decodeRide(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    
    if (data['v'] != 1) {
      throw Exception('Formato QR non supportato');
    }

    final ride = PlannedRide()
      ..rideName = data['n']
      ..rideDate = DateTime.parse(data['dt'])
      ..distance = (data['dist'] as num).toDouble()
      ..elevation = (data['elev'] as num).toDouble()
      ..latitude = data['lat'] != null ? (data['lat'] as num).toDouble() : null
      ..longitude = data['lng'] != null ? (data['lng'] as num).toDouble() : null
      ..notes = data['notes']
      ..createdAt = DateTime.now();

    final List<dynamic>? pts = data['pts'];
    List<Map<String, double>>? track;
    
    if (pts != null) {
      track = pts.map((p) => {
        'lat': (p[0] as num).toDouble(),
        'lng': (p[1] as num).toDouble(),
      }).toList();
    }

    return {
      'ride': ride,
      'track': track,
    };
  }
}
