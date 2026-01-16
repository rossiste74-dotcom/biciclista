import 'package:latlong2/latlong.dart';

/// Model representing key coordinates along a route
class RouteCoordinates {
  /// Starting point latitude
  final double startLat;

  /// Starting point longitude
  final double startLng;

  /// Midpoint latitude
  final double middleLat;

  /// Midpoint longitude
  final double middleLng;

  /// Ending point latitude
  final double endLat;

  /// Ending point longitude
  final double endLng;

  /// High point latitude
  final double? highLat;

  /// High point longitude
  final double? highLng;

  /// Distance to high point (km)
  final double? highDistance;

  /// Distance to midpoint (km)
  final double? middleDistance;

  const RouteCoordinates({
    required this.startLat,
    required this.startLng,
    required this.middleLat,
    required this.middleLng,
    required this.endLat,
    required this.endLng,
    this.highLat,
    this.highLng,
    this.highDistance,
    this.middleDistance,
  });

  /// Get starting point as LatLng
  LatLng get start => LatLng(startLat, startLng);

  /// Get midpoint as LatLng
  LatLng get middle => LatLng(middleLat, middleLng);

  /// Get ending point as LatLng
  LatLng get end => LatLng(endLat, endLng);

  /// Get high point as LatLng
  LatLng? get high => highLat != null && highLng != null ? LatLng(highLat!, highLng!) : null;

  /// Get all key points as a list
  List<LatLng> get allPoints => [
    start, 
    middle, 
    end, 
    if (high != null) high!,
  ];

  @override
  String toString() {
    return 'RouteCoordinates(start: ($startLat, $startLng), middle: ($middleLat, $middleLng), end: ($endLat, $endLng))';
  }
}
